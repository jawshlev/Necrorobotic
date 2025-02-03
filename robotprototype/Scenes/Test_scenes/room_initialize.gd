extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_node("Player")
	player.take_damage.connect(get_node("UI/Health Bar")._on_robot_take_damage)
	player.lose_energy.connect(get_node("UI/Energy Bar")._on_robot_lose_energy)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
