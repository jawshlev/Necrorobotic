extends Node2D

# Track the time when the button was last pressed
#var last_pressed_time = 0.0
#var delay_time = 1000.0  # Delay time in milliseconds (1 second)
@onready var pause_menu = preload("res://Scenes/pause_screen.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_node("Player")
	player.take_damage.connect(get_node("UI/Health Bar")._on_robot_take_damage)
	player.lose_energy.connect(get_node("UI/Energy Bar")._on_robot_lose_energy)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("ui_cancel"):  # Default mapping for Escape key
		print("Pausing")
		Engine.time_scale = 0
		add_child(pause_menu)

func hide_pause_UI():
	Engine.time_scale =1
	remove_child(pause_menu)
	
	
#func timer():
	#var current_time = OS.get_ticks_msec()
	# Check if enough time has passed since the last press
	#if current_time - last_pressed_time >= delay_time:
		# Perform the action when the button is pressed
	#    print("Button pressed!")

		# Update the last pressed time
  #      last_pressed_time = current_time
	#else:
   #     print("Please wait before pressing again.")
