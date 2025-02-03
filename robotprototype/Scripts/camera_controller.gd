extends Camera2D

@export var player: Node2D

func _process(delta):
	global_position = player.position
