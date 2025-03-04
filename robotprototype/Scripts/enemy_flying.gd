extends CharacterBody2D

@export var patrol_speed: float = 80.0
@export var swoop_speed: float = 250.0
@export var patrol_distance: float = 150.0
@export var return_speed: float = 120.0
@export var swoop_duration: float = 1.0
@onready var swoop_timer: Timer = $SwoopTimer

@export var player_path: NodePath

var starting_position: Vector2
var direction: int = 1
var is_swooping: bool = false
var is_returning: bool = false
var player_detected: bool = false
var player: Node2D = null
var swoop_start_position: Vector2
var swoop_target_position: Vector2
var swoop_elapsed_time: float = 0.0

func _ready():
	starting_position = global_position
	if not player and player_path:
		player = get_node(player_path)

func _physics_process(delta: float):
	if is_swooping:
		handle_swoop(delta)
	elif is_returning:
		return_to_patrol(delta)
	else:
		detect_player()
		patrol()

	for body in $DamageArea.get_overlapping_bodies():
		if body == player:
			print("Player detected in range!")

func detect_player():
	if player and $DetectionArea.get_overlapping_bodies().has(player) and not is_returning:
		if not player_detected:
			player_detected = true
			start_swoop()

func patrol():
	velocity.x = direction * patrol_speed
	move_and_slide()

	if abs(global_position.x - starting_position.x) >= patrol_distance:
		direction *= -1

func start_swoop():
	is_swooping = true
	is_returning = false
	swoop_elapsed_time = 0.0
	swoop_start_position = global_position

	var min_swoop_y = starting_position.y + 30
	swoop_target_position = player.global_position + Vector2(0, 50)

	if swoop_target_position.y > min_swoop_y:
		swoop_target_position.y = min_swoop_y

	swoop_timer.wait_time = swoop_duration
	swoop_timer.start()

func handle_swoop(delta: float):
	swoop_elapsed_time += delta
	var t = swoop_elapsed_time / swoop_duration

	if t >= 1.0:
		is_swooping = false
		is_returning = true
		return

	var arc_height = 75
	var x_progress = lerp(swoop_start_position.x, swoop_target_position.x, t)
	var y_offset = -4 * arc_height * (t - 0.5) * (t - 0.5) + arc_height
	var y_progress = lerp(swoop_start_position.y, swoop_target_position.y, t) + y_offset

	var swoop_position = Vector2(x_progress, y_progress)
	velocity = (swoop_position - global_position) * swoop_speed * delta
	move_and_slide()

func return_to_patrol(delta: float):
	velocity.y = -return_speed if global_position.y > starting_position.y else return_speed
	move_and_slide()

	if abs(global_position.y - starting_position.y) <= 5:
		is_returning = false
		velocity.y = 0
		player_detected = false

func _on_swoop_timer_timeout():
	is_swooping = false
	is_returning = true
	swoop_elapsed_time = 0.0

func _on_damage_area_body_entered(body: Node2D):
	if body == player:
		var knockback_direction = -200 if player.global_position.x > global_position.x else 200
		player.enter_hurtbox(5, knockback_direction)

func _on_area_2d_body_exited(body: Node2D):
	if body == player:
		player_detected = false
