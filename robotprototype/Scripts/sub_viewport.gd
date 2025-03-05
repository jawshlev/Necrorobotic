extends SubViewport

var parent_node # variable that is used to access the main Scene
var main_node # variable that is used to access the main Scene
var player_cam

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_2d = get_tree().root.world_2d
	parent_node = get_parent()
	var inventory_menu = parent_node.get_parent()
	print("inv",inventory_menu)
	main_node = inventory_menu.get_parent()
	player_cam = main_node.get_node("Camera2D")
	print("main",main_node)
	
	
	#print(player_cam)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	#parent_node.global_position = player_cam.position

	
	#player_cam.enabled = false
	#print(main)
	#$Camera2D.position = main_node.position
	
	pass
