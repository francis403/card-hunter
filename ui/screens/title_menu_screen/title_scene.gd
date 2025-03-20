extends SceneManager
class_name TitleScreenScene

@onready var settings_screen: PanelContainer = $SettingsScreen
@onready var menu_container: Menu = $MenuContainer

func _ready() -> void:
	super._ready()
	

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_packed(Constants.pick_class_screen_scene)


## TODO
func _on_settings_pressed() -> void:
	get_tree().paused = true
	settings_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_screen.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()
