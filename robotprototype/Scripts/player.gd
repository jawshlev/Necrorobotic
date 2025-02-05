extends CharacterBody2D

@onready var space_state = get_world_2d().direct_space_state
@onready var animations: AnimationPlayer = $Area2D/MeshInstance2D/AnimationPlayer
@onready var game_Over_Menu = $"../GameOver"
@onready var pl_animations = $AnimationTree.get("parameters/playback")

# Constants
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const pos = Vector2(0, 0)
const max_health: float = 100.0
const max_energy: float = 100.0
const fov_scalar = 2 * PI / 90

# Variables
var max_distance: float = 100.0
var curr_health: float = 100.0
var curr_energy: float = 100.0
var energy_reduction_rate: float = 0.01
var time_elapsed = 0.0
var attackable = 0
var invincible = false
var damaged = false
var has_helmet01 = false
var rendered = false
var enemy
var drain_rate = 0
var facing_right = 1
var immobile = false
var double_jump = false

signal lose_energy
signal take_damage
signal punch

func _ready():
	main = get_parent()

func _process(delta: float) -> void:
	time_elapsed += delta
	if time_elapsed >= 1.0:
		curr_energy -= (curr_energy * 0.01)
		time_elapsed = 0.0

	if curr_energy <= 0:
		speed = 70
		jump_velocity = -150

func _physics_process(delta: float) -> void:
	if not immobile:
		# Handle movement and gravity
		if not is_on_floor():
			velocity += get_gravity() * delta

		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			facing_right = direction
			velocity.x += direction * SPEED
		else:
			pl_animations.travel("Idle")
			velocity.x = move_toward(velocity.x, 0, SPEED)

		# Handle jump
		if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or (double_jump and curr_energy >= 5)):
			if not is_on_floor():
				curr_energy -= 5
				lose_energy.emit(5)
				double_jump = false
			velocity.y = JUMP_VELOCITY

		# Double jump activation
		if has_helmet01 and is_on_floor():
			double_jump = true

		# Handle dash
		if Input.is_action_just_pressed("ui_dash") and curr_energy >= 5:
			curr_energy -= 5
			lose_energy.emit(5)
			velocity.x = facing_right * 1500

		# Attack logic
		if Input.is_action_pressed("attack") and not has_helmet01:
			pl_animations.travel("Punch")
			$AnimationTree.set("parameters/Punch/blend_position", velocity)

		# Slow-mo mechanic
		if Input.is_action_pressed("slow-mo") and has_helmet01 and curr_energy >= 1:
			set_target_area(get_FOV_circle(position, 60))
			drain_rate += 5
			Engine.time_scale = 0.5
		elif Engine.time_scale == 0.5:
			drain_rate -= 5
			Engine.time_scale = 1
			set_target_area(PackedVector2Array())
			rendered = false

	move_and_slide()
	targetAreaCast()

func game_Over():
	if curr_health <= 0:
		game_Over_Menu.show()
		self.queue_free()

func targetAreaCast():
	if has_helmet01 and Input.is_action_pressed("slow-mo"):
		attackable = 0
		set_target_area(get_FOV_circle(position, 60))
		Engine.time_scale = 0.5
	else:
		if rendered:
			clear_target_area()
		Engine.time_scale = 1

func get_FOV_circle(from: Vector2, radius):
	var angle = fov_scalar
	var points = PackedVector2Array()
	var difference = pos - from
	invincible = false
	$targetArea.color = Color(129, 129, 129, 0.6)

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
				$targetArea.color = Color(1, 0, 0, 0.6)
				if Input.is_action_pressed("attack"):
					invincible = true
					var direction = (result.position - pos).normalized()
					if position.distance_to(result.position) < (radius - 25):
						position = result.position
					else:
						position += direction * 30 * get_process_delta_time()
				points.append(to + difference)
		else:
			points.append(to + difference)
		angle += fov_scalar

	return points

func set_target_area(points: PackedVector2Array):
	$targetArea.polygon = points
	rendered = true

func clear_target_area():
	Engine.time_scale = 1
	set_target_area(PackedVector2Array())
	rendered = false

func damage_Controller(enemy: RigidBody2D):
	curr_health -= 10
	pl_animations.travel("flash_dmg")
	print("Collided with an enemy", curr_health)
	damaged = false
	game_Over()

func _on_area_2d_area_entered(area: Area2D) -> void:
	enemy = area.get_parent()
	if area.is_in_group("enemy") and not invincible:
		damaged = true
	elif area.is_in_group("enemy") and invincible:
		var orbScene = load("res://Prefabs/orb.tscn")
		var orbInst = orbScene.instantiate()
		self.get_parent().add_child(orbInst)
		orbInst.global_position = area.global_position
		enemy.queue_free()
