extends Node

const settings_screen_scene = preload("res://ui/screens/settings_menu_screen/settings_screen.tscn")
const event_screen_scene = preload("res://ui/screens/event_screen/event_screen.tscn")

var settings_screen_instance: SettingsScreen
var event_screen_instance: EventScreen

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

func open_event_screen(parent_node: Node, event: EventScreen):
	if event_screen_instance:
		close_event_screen()
	else:
		event_screen_instance = event_screen_scene.instantiate()
		if event:
			event_screen_instance.clone(event)
		event_screen_instance.open_screen(parent_node)
	
func close_event_screen():
	if not event_screen_instance:
		return
	event_screen_instance.close_screen()
	event_screen_instance = null

func initiate_battle_scene(battle_scene: BattleGenericScene):
	get_tree().root.add_child(battle_scene)	
