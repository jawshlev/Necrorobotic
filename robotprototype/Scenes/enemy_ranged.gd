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
@export var ray_length: float = 15.0  
@export var ray_forward_offset: float = 5.0  
@onready var floor_check: RayCast2D = $Sprite2D/RayCast2D

const knockback = 200
const contact_damage = 5	
var shoot_timer: float = 0.0
var jump_timer: float = 0.0
var is_jumping: bool = false
var health: int = 30
var energy: int = 50
var immobile = true
var direction: int = 1
var flip_cooldown: float = 3  # prevents instant flipping
var flip_timer: float = 0.0

func _ready():
	if player == null or get_node_or_null(player) == null:
		print("Player is not assigned. Please assign a player node.")

func _physics_process(delta: float) -> void:
	if !immobile:
		velocity.y += gravity * delta
		velocity.x = direction * speed

		flip_timer -= delta  # reduce cooldown timer

		# !!!Only flip if cooldown has passed
		if flip_timer <= 0:
			if is_on_wall() or !is_ground_ahead():
				flip_direction()
				flip_timer = flip_cooldown  # this resets cooldown

		move_and_slide()

		if is_on_floor():
			is_jumping = false
		elif !is_jumping:
			velocity.y = max(velocity.y, gravity)

		var player_node = get_node_or_null(player)
		if player_node:
			var distance_to_player = global_position.distance_to(player_node.global_position)

			# Move towards player if within detection range
			if distance_to_player <= detection_range:
				if player_node.global_position.x > global_position.x:
					velocity.x = speed
				elif player_node.global_position.x < global_position.x:
					velocity.x = -speed
			else:
				velocity.x = 0

			# Jump if close enough to the player (kinda gets stuck I need to fix)
			if distance_to_player <= jump_range and is_on_floor() and jump_timer <= 0.0:
				jump()
				jump_timer = 1.0
			else:
				jump_timer = 0.0

			# Shoot at player
			if distance_to_player <= detection_range:
				shoot_timer -= delta
				if shoot_timer <= 0.0:
					shoot_at_player()
					shoot_timer = shoot_interval

		jump_timer = max(jump_timer - delta, 0)

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

func take_damage(damage, knockback):
	health -= damage
	if health <= 0:
		on_death.emit(energy)
		queue_free()
	immobile = true
	velocity.x = knockback
	velocity.y = -100
	move_and_slide()
	get_tree().create_timer(0.25).timeout.connect(func(): immobile = false)

func is_ground_ahead() -> bool:
	var space_state = get_world_2d().direct_space_state
	var ray_start = global_position + Vector2(direction * ray_forward_offset, 5)
	var ray_end = ray_start + Vector2(0, ray_length)
	var query = PhysicsRayQueryParameters2D.create(ray_start, ray_end)
	query.collision_mask = 1  
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	return result.has("collider")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var knockback_directional = knockback
		if body.global_position.x <= global_position.x:
			knockback_directional *= -1
		body.enter_hurtbox(contact_damage, knockback_directional)
		if is_player_in_front(body):
			flip_direction()

func flip_direction():
	direction *= -1
	velocity.x = direction * speed # movement continues after flipping
	self.scale.x *= -1

func is_player_in_front(player: Node2D) -> bool:
	var player_left = player.global_position.x < global_position.x and direction == -1
	var player_right = player.global_position.x > global_position.x and direction == 1
	return player_left or player_right
