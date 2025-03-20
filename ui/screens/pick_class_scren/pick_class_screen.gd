extends Control
class_name PickClassScreen

@onready var grid_container: GridContainer = $MarginContainer/VBoxContainer/MarginContainer/GridContainer

@export var class_choices: Array[PlayerClass] = []

var class_pick_component_scene: PackedScene =\
	preload("res://ui/screen_components/class_picker_component/class_picker_component.tscn")

func _ready() -> void:
	_hide_preview_content()
	_populate_actual_content()


func _hide_preview_content():
	for item in grid_container.get_children():
		item.queue_free()

func _populate_actual_content():
	for player_class in class_choices:
		var class_pick_instance: ClassPickerComponent =\
			class_pick_component_scene.instantiate()
		class_pick_instance.title = player_class.player_class_name
		class_pick_instance.player_class = player_class
		class_pick_instance.card_back_texture = player_class.player_class_icon
		grid_container.add_child(class_pick_instance)
