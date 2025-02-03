extends CharacterBody2D


var speed = 150.0 #Player's speed
var jump_velocity = -300.0 #Player's Jump Height
var robot_parts = [0, 0, 0, 0] #Which robo-parts the player has. Order is Legs, Arms, Chest, Head
var facing_right = 1 #Which way the player is facing
var can_dash = false #Tracks cooldown on dash
var double_jump = false #Tracks double jumps
var energy = 100 #Player's energy
var health = 100 #Player's health
var invincible = false #Is player invincible
var in_hurtbox = 0 #How many overlapping hurtboxes is the player in
var contact_damage = 0 #How much contact damage should they take
var drain_rate = 0 #How much energy drains per second
const dash_drain = 5 #How much energy the dash drains
const jump_drain = 5 #How much energy the player loses double jumping
const iseconds = 1 #How long the player is invincible for
signal lose_energy
signal take_damage

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	
	if energy <= 0:
		speed = 70
		jump_velocity = -150
		
	# Apply contact damage
	if(in_hurtbox >= 1):
		hurt(contact_damage)
	
	# Enable double jump
	if robot_parts[0] == 1 and is_on_floor():
		double_jump = true
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

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
			velocity.x += direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


func _on_energy_drain_timeout() -> void:
	if energy > 0:
		if energy < drain_rate:
			lose_energy.emit(energy)
			energy = 0
		else:
			lose_energy.emit(drain_rate)
			energy -= drain_rate

func hurt(amount) -> void:
	if(!invincible):
		health -= amount
		take_damage.emit(amount)
		invincible = true
		get_tree().create_timer(1).timeout.connect(func(): invincible = false)

func enter_hurtbox(damage):
	in_hurtbox += 1
	contact_damage = damage

func exit_hurtbox():
	in_hurtbox -= 1
	
func get_upgrade(id, upgrade_drain_rate, upgrade_speed, upgrade_jump):
	robot_parts[id] = 1
	drain_rate += upgrade_drain_rate
	speed += upgrade_speed
	jump_velocity += upgrade_jump
	
