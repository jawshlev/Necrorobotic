extends Node2D

# Track the time when the button was last pressed
#var last_pressed_time = 0.0
#var delay_time = 1000.0  # Delay time in milliseconds (1 second)

var paused = false
var inv_access = false
var stop_control = false
var game_scene = false

var title_menu_scene : PackedScene
@export var pause_menu : Control
@export var inventory_menu : Control
@export var game_Over : Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load the PackedScene (either drag the scene into the editor or load it dynamically)
	title_menu_scene = preload("res://Scenes/title_screen.tscn")  # or load() if dynamically
	instantiate_scene(title_menu_scene)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if game_scene:
	if Input.is_action_just_pressed("ui_cancel"):  # Default mapping for Escape key
		pause_action()
	if Input.is_action_just_pressed("inventory"):  # Default mapping for Escape key
		if(!paused):
			inventory_action()

func instantiate_scene(scene: PackedScene):
	# Instantiate the scene
	var instance = scene.instantiate()
	# Add the instance to the current scene (root node)
	add_child(instance)
	# Optionally, set the position or other properties of the instance
	instance.position = Vector2(0, 0)  # Example for 2D scenes
		
func pause_action():
	
	var color_bckg = pause_menu.get_node("ColorRect")
	color_bckg.size.x = get_viewport().size.x
	color_bckg.size.y = get_viewport().size.y
	print(color_bckg.position)
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	paused = !paused
	stop_control = !stop_control
	
func inventory_action():
	if inv_access:
		inventory_menu.hide()
		Engine.time_scale = 1
	else:
		inventory_menu.show()
		Engine.time_scale = 0
	inv_access = !inv_access
	stop_control = !stop_control

	
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
