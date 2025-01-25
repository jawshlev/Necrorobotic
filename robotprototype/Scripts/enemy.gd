extends CharacterBody2D

@export var target: Node2D

const SPEED = 20.0
const JUMP_VELOCITY = -200.0
const TIMER_MAX = 10.0

var direction = 1.0
var last_turn = 0.0
var last_jump = 0.0

func _ready():
	velocity.x = SPEED
	var now = Time.get_unix_time_from_system()
	last_turn = now
	last_jump = now

func _physics_process(delta):
	var now = Time.get_unix_time_from_system()
	
	# Follow target, if available
	if target:
		direction = 1.0 if (target.position.x - position.x) > 0.0 else -1.0
	# else, Turn every 1 second
	elif (now - last_turn) > 1.0:
		direction = -direction
		last_turn = now
	
	# Update horizontal velocity
	velocity.x = direction * SPEED
	
	# Jump every 3 seconds
	if is_on_floor() and (now - last_jump) > 3.0:
		velocity.y = JUMP_VELOCITY
		last_jump = now
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
