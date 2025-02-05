extends Node2D

var parent_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_node = get_parent()
	spawn_player()
	spawn_followCam()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_player():
	
	#Adds player to gameWorld
	var player = preload("res://Prefabs/player.tscn")  # Preload the scene
	var instance = player.instantiate()  # Create a copy of the scene
	parent_node.add_child(instance)

func spawn_followCam():
	#Adds camera that follows player
	var camera = Camera2D.new()
	print(camera)
	camera.make_current()
	# Attach a script to the Camera2D
	var camera_script = preload("res://Scripts/camera_controller.gd")
	camera.set_script(camera_script)  # Attach the script to the camera node
	# Add the Camera2D to the scene (this makes it part of the scene tree)
	parent_node.add_child(camera)
