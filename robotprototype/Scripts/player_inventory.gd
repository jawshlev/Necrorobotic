extends Control

var window : Node2D
var parent_node # variable that is used to access the main Scene
var set_location
var player_cam

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_node = get_parent()
	window = find_camera2d_in_tree(parent_node)
	
	var main = parent_node.get_parent()
	print(parent_node)
	set_location = position
	player_cam = main.get_node("Player").get_node("Camera2D")
	#player_cam.enabled = false
	#print("Enter", player_cam)
	#print(parent_node.get_children())
	#window =  $"../Camera2D2" #Adjust path as necessary

func _process(delta):
	#position = get_parent().position
	parent_node.global_position = player_cam.position
	pass
	
# Recursive function to search for a Camera2D node
func find_camera2d_in_tree(start_node: Node) -> Camera2D:
	if start_node is Camera2D:
		return start_node as Camera2D  # Return the first found Camera2D
	for child in start_node.get_children():
		var found_camera = find_camera2d_in_tree(child)
		if found_camera:
			return found_camera  # Return the found Camera2D node
	return null  # Return null if no Camera2D is found
