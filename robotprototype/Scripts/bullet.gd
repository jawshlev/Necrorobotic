extends CharacterBody2D

@export var speed: float = 70.0  # Horizontal speed of the projectile
@export var gravity_force: float = 400.0  # Gravity pulling the bullet down
@export var lifetime: float = 3.0  # Time before the bullet disappears
@export var vertical_boost: float = -150.0  # Initial upward velocity for the arc
var direction: Vector2 = Vector2(1, 0)  # Always shoot right

func _ready():
	# Set the horizontal velocity for forward motion
	velocity.x = direction.x * speed

	# Apply the initial vertical boost for an upward arc
	velocity.y = vertical_boost

	# Schedule the projectile to disappear after its lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	# Apply gravity to curve the arc downward
	velocity.y += gravity_force * delta

	# Move the bullet and detect collisions
	var collision = move_and_collide(velocity * delta)
	if collision:
		_on_collision(collision)

	move_and_slide()

func _on_collision(collision):
	var body = collision.get_collider()
	if body:
		print("Projectile hit:", body.name)
		queue_free()  # Destroy the bullet on impact
