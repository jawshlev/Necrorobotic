extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitBox"):
		var player = area.get_parent()
		player.robot_parts[3] = 1
		queue_free()
		#print("Helmet State ", player.has_helmet01)
