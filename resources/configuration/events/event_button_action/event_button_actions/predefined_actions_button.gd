extends EventButtonAction
class_name PredefinedActionButton

enum PredefinedAction {
	generate_new_world,
	open_deforge_screen,
	open_main_world,
	open_tutorial_battle,
	finish_tutorial_battle,
	mark_tutorial_complete,
	close_game_and_remove_progression
}

@export var predefined_action: PredefinedAction
@export var _generate_new_world_after: bool = false


func execute(
	_event_sub_screen: EventSubScreen
) -> bool:
	match predefined_action:
		PredefinedAction.generate_new_world:
			BattleSignals.world_generation_triggered.emit()
		PredefinedAction.open_deforge_screen:
			if _generate_new_world_after:
				BattleSignals.world_generation_triggered.emit()
			_event_sub_screen.get_tree().root.add_child(Refs.deforge_card_screen_scene.instantiate())
		PredefinedAction.open_main_world:
			_event_sub_screen.get_tree().change_scene_to_packed(Constants.main_world_scroll_scene)
		PredefinedAction.open_tutorial_battle:
			TutorialController.generate_tutorial_battle()
		PredefinedAction.finish_tutorial_battle:
			_event_sub_screen.get_parent().queue_free()
			_event_sub_screen.get_tree().change_scene_to_packed(Constants.main_world_scroll_scene)
		PredefinedAction.mark_tutorial_complete:
			TutorialController.mark_tutorial_completed()
		PredefinedAction.close_game_and_remove_progression:
			File.delete_current_run_progress()
			File.save()
			_event_sub_screen.get_tree().quit()
	return true
