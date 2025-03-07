extends Area2D

@export var heal_amount: int = 10

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.health < 100:
			body.health = min(body.health + heal_amount, 100)
			body.take_damage.emit(-heal_amount)
			queue_free()
