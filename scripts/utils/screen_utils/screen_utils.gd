extends Node

const settings_screen_scene = preload("res://ui/screens/settings_menu_screen/settings_screen.tscn")

var settings_screen_instance: SettingsScreen

func open_settings_screen(parent_node: Node):
	if settings_screen_instance:
		close_settings_screen()
	else:
		settings_screen_instance = settings_screen_scene.instantiate()
		settings_screen_instance.open_screen(parent_node)
	
func close_settings_screen():
	if not settings_screen_instance:
		return
	settings_screen_instance.close_screen()
	settings_screen_instance = null
