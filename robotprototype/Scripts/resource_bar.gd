extends TextureProgressBar

func _on_robot_drain(drain):
	value -= drain
