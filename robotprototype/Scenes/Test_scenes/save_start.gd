extends Area2D

var player_in_range = false
var save_timer = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(player_in_range && Input.is_action_pressed("ui_save")):
		save_timer -= delta
		if(save_timer <= 0):
			print("saved")
			save()
			save_timer = 3
	else:
		save_timer = 3

func save():
	var players = get_tree().get_nodes_in_group("Player")
	if(players):
		players[0].locationID = name
		if(!DirAccess.open("user://Nectobotic")):
			DirAccess.make_dir_absolute("user://Necrobotic")
		var save_file = FileAccess.open("user://Necrobotic/savegame.save", FileAccess.WRITE)
		if (!save_file):
			print("ERROR: Save File does not exist")
			return
		var save_data = {
			"robot_part" : players[0].robot_parts,
			"locationID" : players[0].locationID
		}
		var json_string = JSON.stringify(save_data)
		save_file.store_line(json_string)
		


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
