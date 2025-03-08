extends CharacterBody2D

@onready var space_state = get_world_2d().direct_space_state
@onready var animations: AnimationPlayer = $MeshInstance2D/AnimationPlayer
@onready var default_anims = $DefaultAnimationTree
@onready var bootAnimations = $BootAnimationTree
@onready var bootOverlay = $Boots
@onready var gameOver_menu = preload("res://Scenes/game_over.tscn").instantiate()

const pos = Vector2(0,0)

var pl_animations
var boot_animations
var speed = 145.0 #Player's speed
var DEFAULT_SPEED = 145.0
var DEFAULT_JUMP = -350
var jump_velocity = -350.0 #Player's Jump Height
var FOV_scalar = 2*PI/90 # the rendered field of view for the Area of Attack
var robot_parts = [0, 0, 0, 0] #Which robo-parts the player has. Order is Legs, Arms, Chest, Head
var facing_right = 1 #Which way the player is facing
var rendered = false #check if radius is rendered
var can_dash = false #Tracks cooldown on dash
var double_jump = false #Tracks double jumps
var energy = 100.0 #Player's energy
var MAX_NRG = 100.0
var health = 100 #Player's health
var invincible = false #Is player invincible
var immobile = false #Can the player move
var focused = false #Can the player move
var contact_damage = 0 #How much contact damage should they take
var drain_rate = 0 #How much energy drains per second
const dash_drain = 5 #How much energy the dash drains
const jump_drain = 5 #How much energy the player loses double jumping
const focus_drain = 0.4 #How much energy the player loses on focus
const iseconds = 1 #How long the player is invincible for
signal lose_energy
signal take_damage

func _ready() -> void:
	pl_animations = default_anims.get("parameters/playback")
	bootOverlay.visible = false
	$HelmetSprite.visible = false
	pass
	
func _physics_process(delta: float) -> void:
	#print(energy)
	if energy <= 0:
		speed = 80
		jump_velocity = -200
	elif robot_parts[0]==1:
		speed = DEFAULT_SPEED+50
		jump_velocity = DEFAULT_JUMP-50
	else:
		speed = DEFAULT_SPEED
		jump_velocity = DEFAULT_JUMP
	
	if robot_parts[0] == 1:
		if (bootOverlay.visible == false):
			
			bootOverlay.visible = true
			#print(bootOverlay.visible)
			boot_animations = bootAnimations.get("parameters/playback")
		
	# Enable double jump
	if robot_parts[0] == 1 and is_on_floor():
		double_jump = true
	
	#if robot_parts[3] == 1:
	#	$HelmetSprite.visible = true
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not immobile:

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
#			print(velocity)
#			print(facing_right)
			var face_dir = Vector2(facing_right, 0)
			if(is_on_floor()):
				pl_animations.travel("Walk")
				default_anims.set("parameters/Walk/blend_position", face_dir)
				if robot_parts[0] == 1:
					boot_animations.travel("Walk")
					bootAnimations.set("parameters/Walk/blend_position", face_dir)
			if abs(velocity.x) > abs(speed):
				if velocity.x < 0:
					velocity.x += 100
				else:
					velocity.x -= 100
			else:
				velocity.x += direction * speed
		else:
			var face_dir = Vector2(facing_right, 0)
			pl_animations.travel("Idle")
			default_anims.set("parameters/Idle/blend_position", face_dir)
			if robot_parts[0] == 1:
				boot_animations.travel("Idle")
				bootAnimations.set("parameters/Idle/blend_position", face_dir)
			velocity.x = move_toward(velocity.x, 0, speed)
			
		# Handle jump.
		if Input.is_action_just_pressed("jump") and (is_on_floor() or (double_jump and energy >= jump_drain)):
			var face_dir = Vector2(facing_right, 0)
			#if(!focused):
			pl_animations.travel("Jump")
			default_anims.set("parameters/Jump/blend_position", face_dir)
			if robot_parts[0] == 1:
				boot_animations.travel("Jump")
				bootAnimations.set("parameters/Jump/blend_position", face_dir)
			if(not is_on_floor()):
				energy -= jump_drain
				lose_energy.emit(jump_drain)
				double_jump = false
			velocity.y = jump_velocity	
		
	move_and_slide()
	melee_attack()
	targetAreaCast()
	game_Over()

func game_Over():
	if health <= 0:
		gameOver_menu.z_index = 1
		add_child(gameOver_menu)
		#self.queue_free()

func melee_attack():
	#checks for a regular melee attack if no head is equipped
	if Input.is_action_just_pressed("attack") :
		if((robot_parts[3]==0 or energy == 0)):
			pl_animations.travel("Punch")
			var face_dir = Vector2(facing_right, 0)
			default_anims.set("parameters/Punch/blend_position", face_dir)
			if robot_parts[0] == 1:
				boot_animations.travel("Punch")
				bootAnimations.set("parameters/Punch/blend_position", face_dir)

			
func targetAreaCast():
	if robot_parts[3]!=0:
		if Input.is_action_pressed("slow-mo") and energy >= 1:
			#attackable = 0
			set_target_area(get_FOV_circle(position, 60))
			lose_energy.emit(focus_drain)
			Engine.time_scale = 0.5
		else:
			if rendered:
				clear_target_area()
		
func get_FOV_circle(from:Vector2, radius):
	
	var angle = FOV_scalar
	var points = PackedVector2Array()
	var difference = pos - from
	invincible = false
	$targetArea.color = Color(129, 129, 129, 0.6)
	while angle < 2*PI:
		var offset = Vector2(radius, 0).rotated(angle)
		var to = from + offset
		var query = PhysicsRayQueryParameters2D.create(from, to)
		query.exclude = [self]
		var result = space_state.intersect_ray(query)
		if result:
			if result.collider is TileMapLayer: #checks for walls
				points.append(result.position+difference)
			else:
				#print("something is in attack range", result)
				
				if(result.collider.is_in_group("Enemy")):
					#var direction = Vector2(0,0)
					$targetArea.color = Color(1, 0, 0, 0.6)
					if Input.is_action_just_pressed("attack"):
						
						
						pl_animations.travel("flash_attack")
					if Input.is_action_pressed("attack"):
						bootOverlay.visible = false
						focused = true
						invincible = true
						
						# Get the direction vector towards the attraction point
						var direction = (result.position - position).normalized()
						#print(direction)
						if(direction.y > 0):
							if position.distance_to(result.position) < (radius-40):
								result.collider.take_damage(50, 10)
						#print(position.distance_to(result.position))
						if position.distance_to(result.position) < (radius-55):
							#print("Attraction complete!")
							#print(result)
							position = result.position  # Snap to the target
							result.collider.take_damage(20, 10)
						else:
							# Move the sprite towards the attraction point
							focused = false
							position += direction * 30 * get_process_delta_time()
				points.append(to+difference)
				
		else:
			points.append(to+difference)
		angle += FOV_scalar
	return points

func set_target_area(points:PackedVector2Array):
	$targetArea.polygon = points
	rendered = true
	
func clear_target_area():
	Engine.time_scale = 1
	set_target_area(PackedVector2Array())
	rendered = false

func _on_energy_drain_timeout() -> void:
	if energy > 0:
		if energy < drain_rate:
			lose_energy.emit(energy)
			energy = 0
		else:
			lose_energy.emit(drain_rate)
			energy -= drain_rate
	else:
		energy = 0
	
	if energy >= MAX_NRG:
		energy = MAX_NRG

func hurt(amount) -> void:
	if(!invincible):
		health -= amount
		take_damage.emit(amount)
		invincible = true
		get_tree().create_timer(1).timeout.connect(func(): invincible = false)

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


func _on_fist_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body.take_damage(5, 100 * facing_right)
