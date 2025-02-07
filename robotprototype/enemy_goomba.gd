extends CharacterBody2D

@export var speed: float = 30.0  # Movement speed
@export var gravity: float = 800.0  # Gravity applied to the enemy
@export var sprite: Sprite2D  # Assign this manually in the Inspector
@export var start_flipped: bool = false  # Set this in the Inspector to flip initially

var direction: int = 1  # 1 moves right, -1 moves left

func _ready():
	await get_tree().process_frame  # Ensure everything is fully initialized
	if sprite:
		sprite.flip_h = start_flipped  # Set initial flip based on Inspector value
		print("Initial sprite flip:", sprite.flip_h)

func _physics_process(delta: float) -> void:
	# Apply gravity
	velocity.y += gravity * delta

	# Reverse direction if colliding with a wall
	if is_on_wall():
		direction *= -1  # Flip movement direction
		if sprite:
			sprite.flip_h = not sprite.flip_h  # Flip sprite when hitting a wall
		print("Hit wall! Changing direction to:", direction, " Sprite flip:", sprite.flip_h)

	# Apply horizontal movement
	velocity.x = direction * speed

	# Move the enemy
	move_and_slide()
