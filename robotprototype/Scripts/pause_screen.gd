extends Control

# Function to hide the pause menu
func hide_pause_menu():
	#self.visible = false
	#get_tree().paused = false  # Resumes the game
	# Get a reference to NodeA (assuming NodeA is a sibling or in the same scene)
	var pause_screen = get_tree().get_current_scene()
	# Call the function from ScriptA on NodeA
	pause_screen.hide_pause_UI()

func show_pause_menu():  # Show the pause menu
	print("Break Time")
	self.visible = true
	get_tree().paused = true  # Resumes the game

func _on_start_button_pressed() -> void:
	hide_pause_menu()
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_restart_pressed() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
