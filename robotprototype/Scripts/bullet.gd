extends CharacterBody2D

@export var speed: float = 300.0
@export var lifetime: float = 3.0
var direction: Vector2 = Vector2.ZERO

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	velocity = direction * speed
	move_and_slide()

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()
