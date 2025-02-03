extends Camera2D

var player : Node2D
var smoothing_speed : float = 5.0 # Adjust speed as needed

func _ready():
	# Assign the target to the node you want to follow
	#player =  $"../robot" #Adjust path as necessary
	var player_node = get_tree().get_nodes_in_group("player")
	
	if player_node:
		for col in player_node:
			#print("Found a Player!", col.position)
			player = col

func _process(delta):
	#print(player)
	# Smoothly move the camera toward the target's position
	if player.visible:
		#print(player.visible)
		global_position = global_position.lerp(player.global_position, smoothing_speed * delta)
