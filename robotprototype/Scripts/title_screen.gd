extends Control

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Test_scenes/Room1.tscn")



func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_controls_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/controls_screen.tscn")


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/credits_screen.tscn")
