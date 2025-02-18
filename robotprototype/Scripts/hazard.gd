extends Area2D

const contact_damage = 1

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.enter_hurtbox(contact_damage)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.exit_hurtbox()
