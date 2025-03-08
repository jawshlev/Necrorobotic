extends TextureProgressBar

func _on_robot_drain(drain):
	if (value > 10 && (value - drain) <= 10):
		print("10%")
		if($LowEnergyWarning):
			$LowEnergyWarning.play()
	value -= drain
