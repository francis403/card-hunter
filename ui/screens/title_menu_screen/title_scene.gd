extends SceneManager
class_name TitleScreenScene

@onready var settings_screen: PanelContainer = $SettingsScreen
@onready var menu_container: Menu = $MenuContainer
@onready var continue_button: SoundButton = %Continue

func _ready() -> void:
	super._ready()
	if not File.has_save_file():
		continue_button.disabled = true

func _on_new_game_pressed() -> void:
	File.delete_save()
	get_tree().change_scene_to_packed(Constants.pick_class_screen_scene)

func _on_unlockable_content_pressed() -> void:
	print("TODO: implement")

func _on_settings_pressed() -> void:
	ScreenUtils.open_settings_screen(get_parent())

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_continue_pressed() -> void:
	File.load_save_file()
	get_tree().change_scene_to_packed(Constants.main_world_scroll_scene)

func _on_credits_pressed() -> void:
	pass # Replace with function body.
