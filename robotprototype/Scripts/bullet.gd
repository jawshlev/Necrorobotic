extends CharacterBody2D

@export var speed: float = 70.0
@export var gravity_force: float = 400.0
@export var lifetime: float = 3.0
@export var vertical_boost: float = -150.0
var direction: Vector2 = Vector2(1, 0)

func _ready():
	velocity.x = direction.x * speed
	velocity.y = vertical_boost
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	velocity.y += gravity_force * delta

	var collision = move_and_collide(velocity * delta)
	if collision:
		_on_collision(collision)

	move_and_slide()

func _on_collision(collision):
	var body = collision.get_collider()
	if body:
		print("Projectile hit:", body.name)
		queue_free()
