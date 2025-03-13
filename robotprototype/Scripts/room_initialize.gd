extends Node2D

var checking_map = false
# Track the time when the button was last pressed
#var last_pressed_time = 0.0
#var delay_time = 1000.0  # Delay time in milliseconds (1 second)
@onready var pause_menu = preload("res://Scenes/pause_screen.tscn").instantiate()
var player
var resume_time = 0
var pressed_time = 0
var resumed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("Player")
	player.take_damage.connect(get_node("UI/Health Bar")._on_robot_drain)
	player.lose_energy.connect(get_node("UI/Energy Bar")._on_robot_drain)
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		enemy.on_death.connect(player.gain_energy)
	load_game()

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var save_data = json.data
		# Now we set the remaining variables.
		for value in save_data.keys():
			if value == "robot_parts":
				player.robot_parts = value;
			elif value == "locationID":
				player.locationID == value
				player.position = get_tree().get_node(value).position
				
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#update the resume timer value when the player resumes
	if(resumed == true):
		resume_time = Time.get_ticks_msec() / 1000.0 - pressed_time
	
	if Input.is_action_just_pressed("ui_cancel"):  # Default mapping for Escape key
		print("Pausing")
		
		$Player.immobile = true
		Engine.time_scale = 0
		add_child(pause_menu)
		
	if Input.is_action_just_pressed("inventory_toggle"):
		
		checking_map = !checking_map
		if(checking_map):
			print("Checking map")
			$Player.immobile = true
			Engine.time_scale = 0
			player.get_node("Camera2D").zoom = Vector2(0.65, 0.65)
			#player.add_child(map_menu)
			#map_menu.rect_
		else:
			print("Exiting map")
			Engine.time_scale = 1
			$Player.immobile = false
			player.get_node("Camera2D").zoom = Vector2(3, 3)
			#player.remove_child(map_menu)
	
	if(resume_time >= 3):
		resumed = false
		Engine.time_scale = 1
		$Player.immobile = false
		resume_time = 0

func hide_pause_UI():
	
	resumed = true
	# Create an instance of AudioStreamPlayer
	var audio_player = AudioStreamPlayer.new()

	# Add the player to the scene
	add_child(audio_player)

	# Load the audio stream (replace "res://path_to_audio_file.ogg" with your audio file path)
	var audio_clip = preload("res://Assets/Audio/countdown.wav")

	# Assign the audio clip to the AudioStreamPlayer
	audio_player.stream = audio_clip

	# Play the audio
	audio_player.play()
	# get the time the resume button was pressed to get the difference in seconds
	pressed_time = Time.get_ticks_msec() / 1000.0
	print(resume_time)
	remove_child(pause_menu)
