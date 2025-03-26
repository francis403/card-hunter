extends MarginContainer

## TODO: need to add a generic screen that also has this menu

class_name PlayerMenu


func _on_quest_picker_button_pressed() -> void:
	if !get_parent() is QuestPickerScreen:
		get_tree().change_scene_to_packed(Constants.quest_picker_screen_scroll_scene)

func _on_world_view_button_pressed() -> void:
	if !get_parent() is MainWorldScreen:
		get_tree().change_scene_to_packed(Constants.main_world_scroll_scene)


func _on_change_weapon_button_pressed() -> void:
	if !get_parent() is PickClassScreen:
		get_tree().change_scene_to_packed(Constants.pick_class_screen_scene)
