extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitBox"):
		var player = area.get_parent()
		player.has_helmet01 = true
		queue_free()
		#print("Helmet State ", player.has_helmet01)
