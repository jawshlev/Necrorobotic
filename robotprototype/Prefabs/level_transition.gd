extends Node2D

# Path to the new scene you want to load
@export var next_scene_path: String = "res://Prefabs/lvl2.tscn"
var parent_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_node = get_parent() # gets the level scene
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitBox"):  # You can also check for the player's tag or type
		#print("Player entered the area! Loading new scene...")
		var new_scene = load(next_scene_path)
		var instance = new_scene.instantiate()
		#print(next_entrance(instance, "spawnPoint"))
		area.get_parent().position = next_entrance(instance, "spawnPoint")
		parent_node.get_parent().add_child(instance)
		get_parent().queue_free()
		
func next_entrance(parent_node: Node, group_name: String) -> Vector2:
	for child in parent_node.get_children():
		if child.is_in_group(group_name):
			return child.position
	return Vector2.ZERO
