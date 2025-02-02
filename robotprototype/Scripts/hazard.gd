extends Area2D

const contact_damage = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body):
	if body.has_method("enter_hurtbox"):
		body.enter_hurtbox(contact_damage)


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("exit_hurtbox"):
		body.exit_hurtbox() # Replace with function body.
