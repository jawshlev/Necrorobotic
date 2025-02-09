extends CharacterBody2D

@export var speed: float = 30.0
@export var gravity: float = 800.0
@export var sprite: Sprite2D
@export var start_flipped: bool = false

var direction: int = 1

func _ready():
	await get_tree().process_frame
	sprite = $CollisionShape2D/Sprite2D
	if sprite:
		sprite.flip_h = start_flipped
		print("Initial sprite flip:", sprite.flip_h)

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

	if is_on_wall():
		direction *= -1
		if sprite:
			sprite.flip_h = not sprite.flip_h
		print("Hit wall! Changing direction to:", direction, " Sprite flip:", sprite.flip_h)

	velocity.x = direction * speed
	move_and_slide()
