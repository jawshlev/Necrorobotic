extends CharacterBody2D

@export var patrol_speed: float = 80.0
@export var swoop_speed: float = 250.0
@export var patrol_distance: float = 150.0
@export var return_speed: float = 120.0
@export var swoop_duration: float = 1.0
@onready var swoop_timer: Timer = $SwoopTimer
@onready var sprite: Sprite2D = $CollisionShape2D/Sprite2D
@onready var default_anims = $AnimationTree

var starting_position: Vector2
var direction: int = 1
var is_swooping: bool = false
var is_returning: bool = false
var player_detected: bool = false
var player
var swoop_start_position: Vector2
var swoop_target_position: Vector2
var swoop_elapsed_time: float = 0.0
var bat_animations

const contact_damage = 5	
const knockback = 200
const energy = 100
var health = 20
var immobile = true
signal on_death



func _ready():
	await get_tree().process_frame
	bat_animations = default_anims.get("parameters/playback")
	starting_position = global_position

func _physics_process(delta: float):
	if !immobile:
		if is_on_wall():
			flip_direction()

		if is_swooping:
			handle_swoop(delta)
		elif is_returning:
			return_to_patrol(delta)
		else:
			if(player):
				if $DetectionArea.get_overlapping_bodies().has(player) and not is_returning:
					if not player_detected:
						player_detected = true
						start_swoop()
			patrol()
	
	
func flip_direction():
	direction *= -1
	if sprite:
		sprite.flip_h = not sprite.flip_h


func patrol():
	
	velocity.x = direction * patrol_speed
	move_and_slide()
	for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if(collision.get_collider() is TileMapLayer):
				$CollisionShape2D.disabled = true
				print(collision.get_collider())
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

	bat_animations.travel("Attack")
	default_anims.set("parameters/Attack/blend_position", direction)
	swoop_timer.wait_time = swoop_duration
	swoop_timer.start()

func handle_swoop(delta: float):
	swoop_elapsed_time += delta
	var t = swoop_elapsed_time / swoop_duration
	
	
		#if collision.get_collider():
			#print
			#if collision.get_collider().name=="player":
				#queue_free()
	
	if t >= 1.0:
		is_swooping = false
		is_returning = true
		return
	bat_animations.travel("hostile_flying")
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
	if(body.is_in_group("Player")):
		var knockback_direction = -200 if player.global_position.x > global_position.x else 200
		body.enter_hurtbox(5, knockback_direction)

func _on_area_2d_body_exited(body: Node2D):
	if(body.is_in_group("Player")):
		player_detected = false



func _on_detection_area_body_entered(body: Node2D) -> void:

	if body.is_in_group("Player") and not is_returning:
		player = body
		
		if not player_detected:
			player_detected = true
			start_swoop()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var knockback_directional = knockback
		if body.global_position.x <= global_position.x:
			knockback_directional *= -1
		body.enter_hurtbox(contact_damage, knockback_directional)
		if is_player_in_front(body):
			flip_direction()


func is_player_in_front(player: Node2D) -> bool:
	var player_left = player.global_position.x < global_position.x and direction == -1
	var player_right = player.global_position.x > global_position.x and direction == 1
	return player_left or player_right

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


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Curtain"):
		#print(area)
		if(!area.player_present):
			#print(area, " ",area.player_present)
			flip_direction()
			#immobile = true
		
	pass # Replace with function body.
