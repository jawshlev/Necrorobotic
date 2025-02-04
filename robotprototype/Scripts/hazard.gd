extends Area2D

const contact_damage = 1
const knockback = 0

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.enter_hurtbox(contact_damage, knockback)
