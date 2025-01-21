extends CharacterBody2D

@onready var space_state = get_world_2d().direct_space_state

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const pos = Vector2(0,0)

var max_distance : float = 100.0
var max_health : float = 100.0
var max_energy : float = 100.0
var energy_reduction_rate : float = 0.01
var FOV_scalar = 2*PI/90
var time_elapsed = 0.0 
var attackable = 0
var invincible = false

func _process(delta: float) -> void:
	if self != null:
		if max_health == 0:
			self.queue_free()
	time_elapsed += delta  # Increment the time elapsed by the frame time

	if time_elapsed >= 1.0:  # If a second has passed
		max_energy -= (max_energy*energy_reduction_rate)
		time_elapsed = 0.0  # Reset the time counter
		print(max_energy)
	

func _physics_process(delta: float) -> void:
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
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	targetAreaCast()


func targetAreaCast():
	if Input.is_action_pressed("slow-mo") and max_energy >= 1:
		attackable = 0
		set_target_area(get_FOV_circle(position, 60))
		energy_reduction_rate = 0.2
		Engine.time_scale = 0.5
	else:
		clear_target_area()
		energy_reduction_rate = 0.1
		Engine.time_scale = 1
		
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
	
func clear_target_area():
	set_target_area(PackedVector2Array())

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and !invincible:
		max_health -= 10
		print("Collided with a enemy ", max_health)
	elif area.is_in_group("enemy") and invincible:
		print("I should not recieve dmg", max_health)
		area.get_parent().queue_free()
	pass # Replace with function body.
