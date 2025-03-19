extends Control
class_name TitleScreenScene



func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_packed(Constants.pick_class_screen_scene)


## TODO
func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_exit_pressed() -> void:
	get_tree().quit()
