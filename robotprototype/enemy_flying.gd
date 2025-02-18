extends CharacterBody2D

@export var patrol_speed: float = 80.0
@export var swoop_speed: float = 200.0
@export var patrol_distance: float = 150.0
@export var return_speed: float = 120.0
@onready var swoop_timer: Timer = $Timer

@export var player_path: NodePath

var starting_position: Vector2
var direction: int = 1
var is_swooping: bool = false
var player_detected: bool = false
var player: Node2D = null

func _ready():
	starting_position = global_position
	if not player and player_path:
		player = get_node(player_path)

func _physics_process(delta: float):
	detect_player()

	if is_swooping:
		handle_swoop(delta)
	else:
		patrol()

func detect_player():
	if player and $Area2D.get_overlapping_bodies().has(player):
		if not player_detected:
			player_detected = true
			start_swoop()

func patrol():
	velocity.x = direction * patrol_speed
	move_and_slide()

	if abs(global_position.x - starting_position.x) >= patrol_distance:
		direction *= -1

	if player_detected and player:
		start_swoop()

func start_swoop():
	is_swooping = true
	swoop_timer.start()

func _on_swoop_timer_timeout():
	is_swooping = false
	velocity = Vector2.ZERO

func handle_swoop(delta: float):
	if player:
		var direction_to_target = (player.global_position - global_position).normalized()
		velocity = direction_to_target * swoop_speed
		move_and_slide()

		if global_position.distance_to(player.global_position) < 5:
			is_swooping = false

	if not is_swooping and abs(global_position.y - starting_position.y) > 5:
		velocity = Vector2(0, -return_speed if global_position.y > starting_position.y else return_speed)
		move_and_slide()

func _on_damage_area_body_entered(body: Node2D):
	if body == player:
		player.enter_hurtbox(5, 200)

func _on_area_2d_body_exited(body: Node2D):
	if body == player:
		player_detected = false
		is_swooping = false
