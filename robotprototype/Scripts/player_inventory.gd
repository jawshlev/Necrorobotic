extends Control

var window : Node2D
var parent_node # variable that is used to access the main Scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_node = get_parent()
	window = find_camera2d_in_tree(parent_node)
	#print(parent_node.get_children())
	#window =  $"../Camera2D2" #Adjust path as necessary

func _process(delta):
	# Smoothly move the camera toward the target's position
	if window != null:
		global_position = window.global_position


func _on_texture_button_pressed() -> void:
	print("Head Pressed")
	pass # Replace with function body.


func _on_chest_pressed() -> void:
	print("Chest Pressed")
	pass # Replace with function body.


func _on_legs_pressed() -> void:
	print("Legs Pressed")
	pass # Replace with function body.


func _on_r_arm_pressed() -> void:
	print("R arm Pressed")
	pass # Replace with function body.


func _on_l_arm_pressed() -> void:
	print("L arm Pressed")
	pass # Replace with function body.

# Recursive function to search for a Camera2D node
func find_camera2d_in_tree(start_node: Node) -> Camera2D:
	if start_node is Camera2D:
		return start_node as Camera2D  # Return the first found Camera2D
	for child in start_node.get_children():
		var found_camera = find_camera2d_in_tree(child)
		if found_camera:
			return found_camera  # Return the found Camera2D node
	return null  # Return null if no Camera2D is found
