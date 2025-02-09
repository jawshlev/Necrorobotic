extends CharacterBody2D

signal on_death

@export var speed: float = 30.0
@export var gravity: float = 800.0
@export var jump_velocity: float = -200.0
@export var shoot_interval: float = 2.0
@export var detection_range: float = 200.0
@export var jump_range: float = 80.0
@export var projectile_scene: PackedScene
@export var player: NodePath
@export var sprite: Sprite2D

var shoot_timer: float = 0.0
var jump_timer: float = 0.0
var is_jumping: bool = false
var health: int = 3

func _ready():
	if player == null or get_node_or_null(player) == null:
		print("Player is not assigned. Please assign a player node.")

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

	if is_on_floor():
		is_jumping = false
	elif !is_jumping:
		velocity.y = max(velocity.y, gravity)

	var player_node = get_node_or_null(player)
	if player_node:
		var distance_to_player = global_position.distance_to(player_node.global_position)

		if distance_to_player <= detection_range:
			if player_node.global_position.x > global_position.x:
				velocity.x = speed
			elif player_node.global_position.x < global_position.x:
				velocity.x = -speed
		else:
			velocity.x = 0

		if distance_to_player <= jump_range and is_on_floor() and jump_timer <= 0.0:
			jump()
			jump_timer = 1.0
		else:
			jump_timer = 0.0

		if distance_to_player <= detection_range:
			shoot_timer -= delta
			if shoot_timer <= 0.0:
				shoot_at_player()
				shoot_timer = shoot_interval

	jump_timer = max(jump_timer - delta, 0)

	if sprite:
		if velocity.x > 0:
			sprite.flip_h = false
		elif velocity.x < 0:
			sprite.flip_h = true

	move_and_slide()

func jump():
	is_jumping = true
	velocity.y = jump_velocity
	await get_tree().create_timer(0.5).timeout
	is_jumping = false

func shoot_at_player():
	if projectile_scene == null:
		print("Projectile scene is not assigned!")
		return

	var shoot_direction = Vector2(1, 0) if velocity.x > 0 else Vector2(-1, 0)
	var spawn_position = global_position
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = spawn_position
	projectile.velocity.x = shoot_direction.x * projectile.speed

	print("Shooting in direction:", shoot_direction, " from position:", spawn_position)
