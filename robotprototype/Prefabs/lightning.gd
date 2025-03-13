extends Node2D
const knockback = 100
const contact_damage = 5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func strike():
	$AnimatedSprite2D.set_visible(true)
	$AnimatedSprite2D.play("warning")
	await get_tree().create_timer(1.0).timeout
	$AnimatedSprite2D.play("default")
	$Hitbox1/CollisionShape2D.set_disabled(false)
	get_tree().create_timer(0.05).timeout.connect(func(): $Hitbox2/CollisionShape2D.set_disabled(false))
	get_tree().create_timer(0.1).timeout.connect(func(): $Hitbox3/CollisionShape2D.set_disabled(false))
	get_tree().create_timer(0.15).timeout.connect(func(): $Hitbox4/CollisionShape2D.set_disabled(false))
	get_tree().create_timer(1).timeout.connect(func(): clear())

func clear():
	$Hitbox1/CollisionShape2D.set_disabled(true)
	$Hitbox2/CollisionShape2D.set_disabled(true)
	$Hitbox3/CollisionShape2D.set_disabled(true)
	$Hitbox4/CollisionShape2D.set_disabled(true)
	$AnimatedSprite2D.set_visible(false)



func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var knockback_directional = knockback
		if body.global_position.x <= global_position.x:
			knockback_directional *= -1
		body.enter_hurtbox(contact_damage, knockback_directional)
		body.gain_energy(25)
