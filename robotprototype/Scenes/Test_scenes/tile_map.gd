extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _on_boss_trigger(body: Node2D) -> void:
	if body.is_in_group("Player"):
		for ctr in range(382, 398):
			set_cell(0, Vector2i(ctr, 213), 0, Vector2i(1, 0))
			set_cell(0, Vector2i(ctr, 214), 0, Vector2i(1, 1))
			set_cell(0, Vector2i(ctr, 215), 0, Vector2i(1, 2))
