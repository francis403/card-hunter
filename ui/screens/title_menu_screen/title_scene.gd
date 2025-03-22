extends SceneManager
class_name TitleScreenScene

@onready var settings_screen: PanelContainer = $SettingsScreen
@onready var menu_container: Menu = $MenuContainer

func _ready() -> void:
	super._ready()
	

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_packed(Constants.pick_class_screen_scene)


func _on_settings_pressed() -> void:
	ScreenUtils.open_settings_screen(get_parent())

func _on_exit_pressed() -> void:
	get_tree().quit()
