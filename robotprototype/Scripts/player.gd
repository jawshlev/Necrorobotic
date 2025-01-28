extends CharacterBody2D

@onready var space_state = get_world_2d().direct_space_state
#@onready var mesh_instance_2d: Sprite2D = $Area2D/MeshInstance2D
@onready var animations: AnimationPlayer = $Area2D/MeshInstance2D/AnimationPlayer
@onready var main = $".."


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const pos = Vector2(0,0)
const max_health : float = 100.0
const max_energy : float = 100.0

var max_distance : float = 100.0
var curr_health : float = 100.0
var curr_energy : float = 100.0
var energy_reduction_rate : float = 0.01
var FOV_scalar = 2*PI/90
var time_elapsed = 0.0 
var attackable = 0
var invincible = false
var rendered = false
var has_helmet01 = false
var pl_animations
var dir_velocity

func _ready():
	pl_animations = $AnimationTree.get("parameters/playback")

func _process(delta: float) -> void:
	if self != null:
		if curr_health == 0:
			self.queue_free()
	time_elapsed += delta  # Increment the time elapsed by the frame time

	if time_elapsed >= 1.0:  # If a second has passed
		curr_energy -= energy_reduction_rate
		time_elapsed = 0.0  # Reset the time counter
	#print(curr_energy)
	#print(has_helmet01)

func _physics_process(delta: float) -> void:
	
	if(!(main.paused)):
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			#$AnimationTree.get("parameters/playback").travel("Walk")
			dir_velocity = velocity
			$AnimationTree.set("parameters/Idle/blend_position", velocity)
			velocity.x = direction * SPEED
		else:
			pl_animations.travel("Idle")
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()
		melee_attack()
		targetAreaCast()

func melee_attack():
	if Input.is_action_pressed("attack") and !(has_helmet01):
		pl_animations.travel("Punch")
		$AnimationTree.set("parameters/Punch/blend_position", dir_velocity)

func targetAreaCast():
	if has_helmet01:
		if Input.is_action_pressed("slow-mo") and curr_energy >= 1:
			attackable = 0
			set_target_area(get_FOV_circle(position, 60))
			energy_reduction_rate = 5
			Engine.time_scale = 0.5
		else:
			if rendered:
				clear_target_area()
			energy_reduction_rate = 0.1
		
func get_FOV_circle(from:Vector2, radius):
	var angle = FOV_scalar
	var points = PackedVector2Array()
	var difference = pos - from
	while angle < 2*PI:
		var offset = Vector2(radius, 0).rotated(angle)
		var to = from + offset
		var query = PhysicsRayQueryParameters2D.create(from, to)
		query.exclude = [self]
		var result = space_state.intersect_ray(query)
		if result:
			if result.collider is StaticBody2D: #checks for walls
				points.append(result.position+difference)
			else: #assumes a hostile NPC
				
				attackable += 1
				#print("something is in attack range", attackable)
				if Input.is_action_pressed("attack") and attackable>0:
					invincible = true
					# Get the direction vector towards the attraction point
					var direction = (result.position - pos).normalized()
					if position.distance_to(result.position) < (radius-25):
						#print("Attraction complete!")
						position = result.position  # Snap to the target
					else:
						# Move the sprite towards the attraction point
						position += direction * 30 * get_process_delta_time()
				points.append(to+difference)
		else:
			points.append(to+difference)
		angle += FOV_scalar
	
	if attackable > 0:
		$targetArea.color = Color(1, 0, 0, 0.6)
	else:
		$targetArea.color = Color(129, 129, 129, 0.6)
	
	return points

	

func set_target_area(points:PackedVector2Array):
	$targetArea.polygon = points
	rendered = true
	
func clear_target_area():
	Engine.time_scale = 1
	set_target_area(PackedVector2Array())
	rendered = false

func enemy_knockbackfx(enemy: Area2D, strength: float):
	pl_animations.travel("flash_dmg")
	
	# Issue with how the normals are obtained
	#var knock_dir = enemy.global_position.direction_to(global_position)
	#print("Collision normal:", knock_dir)
	#var impulse = knock_dir * strength
	#velocity += impulse
	

func _on_area_2d_area_entered(area: Area2D) -> void:
	
	var enemy = area.get_parent()
	if area.is_in_group("enemy") and !invincible:
		curr_health -= 10
		enemy_knockbackfx(area, 500)
		print("Collided with a enemy ", curr_health)
	elif area.is_in_group("enemy") and invincible:
		#print("I should not recieve dmg", max_health)
		var orbPos = area.global_position
		enemy.queue_free()
		var orbScene = load("res://orb.tscn")
		var orbInst = orbScene.instantiate()
		self.get_parent().call_deferred("add_child", orbInst)
		orbInst.global_position = orbPos
	pass # Replace with function body.
