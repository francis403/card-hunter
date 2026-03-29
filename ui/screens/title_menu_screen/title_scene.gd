extends SceneManager
class_name TitleScreenScene

@onready var settings_screen: PanelContainer = $SettingsScreen
@onready var menu_container: Menu = $MenuContainer
@onready var continue_button: SoundButton = %Continue
@onready var card_pedia_button: SoundButton = $MenuContainer/CardPedia
@onready var delete_save_button: SoundButton = $MenuContainer/DeleteSave

func _ready() -> void:
	super._ready()
	# CardPedia is now live – no longer disabled
	File.load_save_file()
	if not File.has_save_file():
		delete_save_button.visible = false
	if not File.has_run_in_progress():
		continue_button.disabled = true

func _on_new_game_pressed() -> void:
	File.delete_current_run_progress()
	get_tree().change_scene_to_packed(Constants.pick_class_screen_scene)

func _on_unlockable_content_pressed() -> void:
	# Navigate to the Cardpedia hub screen
	get_tree().change_scene_to_packed(Constants.cardpedia_screen_scene)

func _on_settings_pressed() -> void:
	ScreenUtils.open_settings_screen(get_parent())

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_packed(Constants.main_world_scroll_scene)

func _on_credits_pressed() -> void:
	pass # Replace with function body.

func _on_delete_save_pressed() -> void:
	File.delete_save()
	delete_save_button.visible = false
	continue_button.disabled = true
	print("Save deleted successfully")