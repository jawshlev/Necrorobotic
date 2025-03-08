extends Area2D

const id = 3
const speed = 50
const jump = -50
const drain = 2

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		#body.robot_parts[3] = 1
		body.get_upgrade(id, drain, speed, jump)
		queue_free()
