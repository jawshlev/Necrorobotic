extends Area2D

const id = 0
const speed = 50
const jump = -50
const drain = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body):
	if(body.is_in_group("Player")):
		body.get_upgrade(id, drain, speed, jump)
		print("Boots Get!")
		queue_free()
