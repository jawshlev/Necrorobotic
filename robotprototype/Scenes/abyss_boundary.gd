extends Node2D

#@onready var game_Over_Menu = $"../GameOver"
@export var game_Over : Control
var player
var window : Node2D
var respawn
var parent_node # variable that is used to access the main Scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_node = get_parent()
	game_Over = parent_node.get_parent().game_Over

func _process(delta: float) -> void:
	if game_Over == null:
		game_Over = parent_node.get_parent().game_Over

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hitBox"):
		#print("Player exited", area.get_parent())
		game_Over.show()
		Engine.time_scale = 0
		player = area.get_parent()
		player.hide()
