extends CharacterBody2D

@export var speed: float = 15.0
@export var gravity: float = 800.0
@export var jump_velocity: float = -200.0
@export var shoot_interval: float = 2.0
@export var detection_range: float = 200.0
@export var jump_range: float = 80.0
@export var projectile_scene: PackedScene
@export var player: NodePath

var shoot_timer: float = 0.0
var jump_timer: float = 0.0
var is_jumping: bool = false

func _ready():
	if player == null or get_node_or_null(player) == null:
		print("assign player")

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

	if is_on_floor():
		is_jumping = false
	elif !is_jumping:
		velocity.y = max(velocity.y, gravity)

	var player_node = get_node_or_null(player)
	if player_node:
		var distance_to_player = global_position.distance_to(player_node.global_position)

		# moves toward the player ONLY IF BOTH in range and no gap detected
		if distance_to_player <= detection_range and is_safe_to_move():
			if player_node.global_position.x > global_position.x:
				velocity.x = speed
			elif player_node.global_position.x < global_position.x:
				velocity.x = -speed
		else:
			speed = 0

		if distance_to_player <= jump_range:
			if is_on_floor() and jump_timer <= 0.0:
				jump()
				jump_timer = 1.0
		else:
			jump_timer = 0.0

		if distance_to_player <= detection_range:
			shoot_timer -= delta
			if shoot_timer <= 0.0:
				shoot_at_player()
				shoot_timer = shoot_interval  # resets the shoot timer

	jump_timer = max(jump_timer - delta, 0)
	move_and_slide()


func is_safe_to_move() -> bool:
	var direction = Vector2(1 if velocity.x > 0 else -1, 0)
	var ray_start = global_position + direction * 25
	var ray_end = ray_start + Vector2(0, 60)

	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(ray_start, ray_end)
	query.exclude = [self]
	query.collision_mask = 1

	var result = space_state.intersect_ray(query)

	#print("gap ahead:", result != null)

	return result != null

func jump():
	#print("jumping")
	is_jumping = true
	velocity.y = jump_velocity
	await get_tree().create_timer(0.5).timeout
	is_jumping = false

func shoot_at_player():
	if projectile_scene == null:
		print("assign projectile")
		return

	var player_node = get_node_or_null(player)
	if not player_node:
		return

	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = global_position

	var direction = (player_node.global_position - global_position).normalized()
	projectile.set_direction(direction)

	# easier in the code than to do it manually
	projectile.collision_layer = 2 
	projectile.collision_mask = 4

	print("shooting")
