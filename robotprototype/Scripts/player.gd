extends CharacterBody2D

@onready var space_state = get_world_2d().direct_space_state
#@onready var mesh_instance_2d: Sprite2D = $Area2D/MeshInstance2D
@onready var animations: AnimationPlayer = $Area2D/MeshInstance2D/AnimationPlayer
@onready var main = $".."
@onready var pl_animations = $AnimationTree.get("parameters/playback")


var speed = 150.0 #Player's speed
var jump_velocity = -400.0 #Player's Jump Height
const pos = Vector2(0,0)
var robot_parts = [0, 0, 0, 0] #Which robo-parts the player has. Order is Legs, Arms, Chest, Head
var facing_right = 1 #Which way the player is facing
var can_dash = false #Tracks cooldown on dash
var double_jump = false #Tracks double jumps
var show_range = false #Show the range or not
const max_health = 100
const max_energy = 100
const fov_scalar = 2 * PI / 90

var max_distance : float = 100.0
var energy = 100 #Player's energy
var health = 100 #Player's health
var invincible = false #Is player invincible
var immobile = false #Is player control disabled
var drain_rate = 0 #How much energy drains per second
const dash_drain = 5 #How much energy the dash drains
const jump_drain = 5 #How much energy the player loses double jumping
const iseconds = 1 #How long the player is invincible for
signal lose_energy
signal take_damage
signal punch

func _ready():
	pass
	
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	
	if energy <= 0:
		speed = 70
		jump_velocity = -150

	# Enable double jump
	if robot_parts[0] == 1 and is_on_floor():
		double_jump = true
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if !immobile:
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or (double_jump and energy >= jump_drain)):
			if(not is_on_floor()):
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

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			facing_right = direction
			if abs(velocity.x) > abs(speed):
				if velocity.x < 0:
					velocity.x += 100
				else:
					velocity.x -= 100
			else:
				#$AnimationTree.get("parameters/playback").travel("Walk")
				$AnimationTree.set("parameters/Idle/blend_position", velocity)
				velocity.x += direction * speed
		else:
			pl_animations.travel("Idle")
			velocity.x = move_toward(velocity.x, 0, speed)

		if Input.is_action_pressed("attack") and !(robot_parts[3]):
			pl_animations.travel("Punch")
			$AnimationTree.set("parameters/Punch/blend_position", facing_right)

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

func get_FOV_circle(from:Vector2, radius):
	var targets = 0
	var angle = fov_scalar
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
				
				targets += 1
				#print("something is in attack range", attackable)
				if Input.is_action_pressed("attack") and targets>0:
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
		angle += fov_scalar
	
	if targets > 0:
		$targetArea.color = Color(1, 0, 0, 0.6)
	else:
		$targetArea.color = Color(129, 129, 129, 0.6)
	
	return points

	

func set_target_area(points:PackedVector2Array):
	$targetArea.polygon = points
	show_range = true
	
func enemy_knockbackfx(enemy: Area2D, strength: float):
	pl_animations.travel("flash_dmg")
	
	# Issue with how the normals are obtained
	#var knock_dir = enemy.global_position.direction_to(global_position)
	#print("Collision normal:", knock_dir)
	#var impulse = knock_dir * strength
	#velocity += impulse
	

func _on_area_2d_area_entered(area: Area2D) -> void:
	
#	var enemy = area.get_parent()
#	if area.is_in_group("enemy") and !invincible:
#		curr_health -= 10
#		enemy_knockbackfx(area, 500)
#		print("Collided with a enemy ", curr_health)
#	elif area.is_in_group("enemy") and invincible:
#		#print("I should not recieve dmg", max_health)
#		var orbPos = area.global_position
#		enemy.queue_free()
#		var orbScene = load("res://orb.tscn")
#		var orbInst = orbScene.instantiate()
#		self.get_parent().call_deferred("add_child", orbInst)
#		orbInst.global_position = orbPos
	pass # Replace with function body.


func _on_energy_drain_timeout() -> void:
	if energy > 0:
		if energy < drain_rate:
			lose_energy.emit(energy)
			energy = 0
		else:
			lose_energy.emit(drain_rate)
			energy -= drain_rate

func enter_hurtbox(damage, knockback):
	if(!invincible):
		health -= damage
		if health <= 0:
			self.queue_free()
		take_damage.emit(damage)
		invincible = true
		get_tree().create_timer(1).timeout.connect(func(): invincible = false)
	velocity.x = knockback
	velocity.y = -100
	immobile = true
	move_and_slide()
	get_tree().create_timer(0.25).timeout.connect(func(): immobile = false)

func get_upgrade(id, upgrade_drain_rate, upgrade_speed, upgrade_jump):
	robot_parts[id] = 1
	drain_rate += upgrade_drain_rate
	speed += upgrade_speed
	jump_velocity += upgrade_jump

func gain_energy(amount):
	energy += amount
	lose_energy.emit(-amount)
