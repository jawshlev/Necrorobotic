extends CharacterBody2D

@export var speed: float = 30.0
@export var gravity: float = 800.0
@export var sprite: Sprite2D
@export var start_flipped: bool = false
const contact_damage = 5	
const knockback = 200
const energy = 5
var health = 20
signal on_death


var direction: int = 1

func _ready():
	await get_tree().process_frame
	sprite = $CollisionShape2D/Sprite2D
	if sprite:
		sprite.flip_h = start_flipped
#		print("Initial sprite flip:", sprite.flip_h)

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

	if is_on_wall():
		direction *= -1
		if sprite:
			sprite.flip_h = not sprite.flip_h
#		print("Hit wall! Changing direction to:", direction, " Sprite flip:", sprite.flip_h)

	velocity.x = direction * speed
	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	print("Entered ", body)
	if body.is_in_group("Player"):
		var knockback_directional = knockback
		if(body.global_position[0] <= global_position[0]):
			knockback_directional *= -1
		body.enter_hurtbox(contact_damage, knockback_directional)
		
func take_damage(damage, _knockback):
	print("Take ", damage, " damage")
	health -= damage
	print(health, " Health")
	if health <= 0:
		on_death.emit(energy)
		queue_free()
