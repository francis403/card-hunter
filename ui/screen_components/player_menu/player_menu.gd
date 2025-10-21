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


func _on_deforge_card_button_pressed() -> void:
	if !get_parent() is DeforgeCardScreen:
		var scene: DeforgeCardScreen = Constants.deforge_card_screen_scene.instantiate()
		#get_tree().change_scene_to_packed(Constants.deforge_card_screen_scene)
		get_tree().root.add_child(scene)


func _on_forge_card_button_pressed() -> void:
	if !get_parent() is ForgeCardScreen:
		var scene: ForgeCardScreen = Constants.forge_card_screen_scene.instantiate()
		get_tree().root.add_child(scene)


func _on_expand_world_pressed() -> void:
	BattlemapSignals.expand_world.emit()
