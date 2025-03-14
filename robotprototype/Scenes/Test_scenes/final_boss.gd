extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var health = 50
var attacking = false;
var enabled = false;
var immobile = false
var offset
signal on_death
const energy = 0



func _process(delta: float) -> void:
	if(!attacking && enabled):
		print("warmup")
		attacking = true;
		var player = get_tree().get_nodes_in_group("Player")[0];
		var warning = player.get_node("WarningSprite")
		var bonus_actions = 0;
		if(player.energy >= 5):
			if (player.robot_parts[0]):
				bonus_actions += 1;
			if (player.robot_parts[1]):
				bonus_actions +=1;
		var action = floor(RandomNumberGenerator.new().randi() % (3 + min(2, 2 * floor(player.energy / 5))));
		match action:
			0:
				#single lightning
				$Lightning.rotation = (0)
				$Lightning.scale = Vector2(1, 8.25)
				$Lightning.set_position(Vector2(min(max(-926, player.position.x - position.x), 910), -192))
				$Lightning.strike()
				print("Strike")
			1:
				$Lightning.rotation = (0)
				$Lightning.scale = Vector2(1, 8.25)
				$Lightning.set_position(Vector2(min(max(-926, player.position.x - position.x), 910), -192))
				$Lightning.strike()
				await get_tree().create_timer(1.0).timeout
				$Lightning2.set_position(Vector2(min(max(-926, player.position.x - position.x), 910), -192))
				$Lightning2.strike()
				await get_tree().create_timer(1.0).timeout
				$Lightning3.set_position(Vector2(min(max(-926, player.position.x - position.x), 910), -192))
				$Lightning3.strike()
				print("Triple")
			2:
				#horizontal lightning
				$Lightning.rotation = (-PI/2)
				$Lightning.scale = Vector2(1, 23.5)
				$Lightning.set_position(Vector2(-928, min(max(-174, player.position.y - position.y), 446)))
				$Lightning.strike()
				print("Slash")
			3:
				if(player.facing_right):
					warning.rotation = -PI/2
				else:
					warning.rotation = PI/2
				warning.visible = true
				warning.play("warning")
				$Lightning.rotation = (0)
				$Lightning.scale = Vector2(1, 8.25)
				#single lightning
				$Lightning.set_position(Vector2(player.position.x - position.x + 100 * player.facing_right, -192))
				$Lightning.strike()
				get_tree().create_timer(1.0).timeout.connect(func():
					warning.visible = false
					player.dash()
					)
				print("Dash")

				#dash attack
			4:
				warning.rotation = 0
				warning.visible = true
				warning.play("warning")
				$Lightning.rotation = (-PI/2)
				$Lightning.scale = Vector2(1, 23.5)
				$Lightning.set_position(Vector2(-928, player.position.y - position.y - 100))
				$Lightning.strike()
				get_tree().create_timer(1.0).timeout.connect(func():
					warning.visible = false
					player.jump()
					)
				print("Jump")
				pass;
		get_tree().create_timer(1 + floor(health / 50) * 4).timeout.connect(func(): attacking = false)

func take_damage(damage, knockback):
	health -= damage
	if health <= 0:
		#ending
		queue_free()
	var player = get_tree().get_nodes_in_group("Player")[0];
	player.enter_hurtbox(0, 50)


func _on_boss_trigger(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("Player"):
		enabled = true;
