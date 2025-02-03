extends RigidBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		print("Collided with a player ", area.get_parent())
		
		pass # Replace with function body.
	
	if area.is_in_group("meleeRange"):
		var knock_dir = area.global_position.direction_to(global_position)
		print("Collision normal:", knock_dir)
		#var impulse = knock_dir * strength
		#print("Collided with player fist")
		var knockX = knock_dir.x *400
		apply_central_impulse(Vector2(knockX,0))
		pass # Replace with function body.

	
	if area.is_in_group("targetArc"):
		print("Collided with a circle")
		pass # Replace with function body.
 
