extends CharacterBody2D


var speed = 150.0 #Player's speed
var jump_velocity = -250.0 #Player's Jump Height
var robot_parts = [0, 0, 0, 0] #Which robo-parts the player has. Order is Legs, Arms, Chest, Head
var facing_right = 1 #Which way the player is facing
var can_dash = true #Tracks cooldown on dash
var energy = 100
var drain_rate = 1 #How much energy drains per second
signal lose_energy
signal take_damage

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		
	if Input.is_action_just_pressed("ui_dash") and can_dash and energy >= 5:
		can_dash = false
		energy -= 5
		lose_energy.emit(5)
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
	energy -= drain_rate
	lose_energy.emit(drain_rate)
	
