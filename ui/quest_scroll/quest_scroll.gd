extends MarginContainer
class_name QuestScroll

@export var _title: String = "Title"
@export_multiline var _description: String = "Description description description"
@export var battle_scene: PackedScene

@onready var title: Label = %Title
@onready var description: Label = %Description


func _ready() -> void:
	title.text = _title
	description.text = _description


func _on_margin_container_gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		load_battle_scene()
			
func load_battle_scene():
	print(load_battle_scene)
	if battle_scene:
		get_tree().change_scene_to_packed(battle_scene)
