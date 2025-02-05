extends CharacterBody2D

@onready var space_state = get_world_2d().direct_space_state
@onready var animations: AnimationPlayer = $Area2D/MeshInstance2D/AnimationPlayer
@onready var main = $".."
@onready var pl_animations = $AnimationTree.get("parameters/playback")

var speed = 150.0  # Player's speed
var jump_velocity = -400.0  # Player's Jump Height
const pos = Vector2(0, 0)
var robot_parts = [0, 0, 0, 0]  # Order: Legs, Arms, Chest, Head
var facing_right = 1  # Which way the player is facing
var can_dash = false  # Tracks cooldown on dash
var double_jump = false  # Tracks double jumps
var show_range = false  # Show the range or not
const max_health = 100
const max_energy = 100
const fov_scalar = 2 * PI / 90

var max_distance: float = 100.0
var energy = 100  # Player's energy
var health = 100  # Player's health
var invincible = false  # Is player invincible
var immobile = false  # Is player control disabled
var drain_rate = 0  # How much energy drains per second
const dash_drain = 5  # Energy drained by dashing
const jump_drain = 5  # Energy drained by double jumping
const iseconds = 1  # How long the player is invincible for

signal lose_energy
signal take_damage
signal punch

var time_elapsed = 0.0
var attackable = 0

func _ready():
	pass

func _process(delta: float) -> void:
	time_elapsed += delta  # Increment elapsed time

	if time_elapsed >= 1.0:  # Every second, drain energy slightly
		energy -= (energy * 0.01)
		time_elapsed = 0.0  # Reset time counter
	
	if energy <= 0:
		speed = 70
		jump_velocity = -150

func _physics_process(delta: float) -> void:
	# Enable double jump
	if robot_parts[0] == 1 and is_on_floor():
		double_jump = true

	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if !immobile:
		# Handle jump
		if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or (double_jump and energy >= jump_drain)):
			if not is_on_floor():
				energy -= jump_drain
				lose_energy.emit(jump_drain)
				double_jump = false
			velocity.y = jump_velocity

		if Input.is_action_just_pressed("ui_dash") and can_dash and energy >= dash_drain:
			can_dash = false
			energy -= dash_drain
			lose_energy.emit(dash_drain)
			velocity.x = facing_right * 1500
			get_tree().create_timer(0.01).timeout.connect(func(): can_dash = true)

		# Handle movement
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			facing_right = direction
			velocity.x += direction * speed
		else:
			pl_animations.travel("Idle")
			velocity.x = move_toward(velocity.x, 0, speed)

		# Attack logic
		if Input.is_action_pressed("attack") and not robot_parts[3]:
			pl_animations.travel("Punch")
			$AnimationTree.set("parameters/Punch/blend_position", facing_right)

		# Slow-mo mechanic
		if Input.is_action_pressed("slow-mo") and robot_parts[3] and energy >= 1:
			set_target_area(get_FOV_circle(position, 60))
			drain_rate += 5
			Engine.time_scale = 0.5

		if Input.is_action_just_released("slow-mo") and Engine.time_scale == 0.5:
			drain_rate -= 5
			Engine.time_scale = 1
			set_target_area(PackedVector2Array())
			show_range = false

	move_and_slide()
	targetAreaCast()

func targetAreaCast():
	if Input.is_action_pressed("slow-mo") and energy >= 1:
		attackable = 0
		set_target_area(get_FOV_circle(position, 60))
		Engine.time_scale = 0.5
	else:
		clear_target_area()
		Engine.time_scale = 1

func get_FOV_circle(from: Vector2, radius):
	var angle = fov_scalar
	var points = PackedVector2Array()
	var difference = pos - from
	
	while angle < 2 * PI:
		var offset = Vector2(radius, 0).rotated(angle)
		var to = from + offset
		var query = PhysicsRayQueryParameters2D.create(from, to)
		query.exclude = [self]
		var result = space_state.intersect_ray(query)

		if result:
			if result.collider is StaticBody2D:
				points.append(result.position + difference)
			else:
				attackable += 1
				if Input.is_action_pressed("attack") and attackable > 0:
					invincible = true
					var direction = (result.position - pos).normalized()
					if position.distance_to(result.position) < (radius - 25):
						position = result.position  # Snap to target
					else:
						position += direction * 30 * get_process_delta_time()
				points.append(to + difference)
		else:
			points.append(to + difference)
		
		angle += fov_scalar
	
	if attackable > 0:
		$targetArea.color = Color(1, 0, 0, 0.6)
	else:
		$targetArea.color = Color(129, 129, 129, 0.6)
	
	return points

func set_target_area(points: PackedVector2Array):
	$targetArea.polygon = points
	show_range = true

func clear_target_area():
	set_target_area(PackedVector2Array())

func enter_hurtbox(damage, knockback):
	if not invincible:
		health -= damage
		if health <= 0:
			self.queue_free()
		take_damage.emit(damage)
		invincible = true
		get_tree().create_timer(1).timeout.connect(func(): invincible = false)

func get_upgrade(id, upgrade_drain_rate, upgrade_speed, upgrade_jump):
	robot_parts[id] = 1
	drain_rate += upgrade_drain_rate
	speed += upgrade_speed
	jump_velocity += upgrade_jump

func gain_energy(amount):
	energy += amount
	lose_energy.emit(-amount)
