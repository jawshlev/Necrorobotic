extends CharacterBody2D

@export var speed: float = 200.0
@export var gravity_force: float = 800.0
@export var lifetime: float = 3.0
@export var vertical_boost: float = -270.0
@export var collision_enable_delay: float = 0.1  # Delay before enabling collision
var direction: Vector2 = Vector2.ZERO

func _ready():
	$CollisionShape2D.set_deferred("disabled", true)  # Temporarily disable collision
	await get_tree().create_timer(collision_enable_delay).timeout
	$CollisionShape2D.disabled = false  # Re-enable collision after delay
	velocity.y = vertical_boost
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	velocity.y += gravity_force * delta
	velocity.x = direction.x * speed
	move_and_slide()

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()
