extends Control
## Used to display card_modules in a vertical container
class_name CardModuleLayer

@onready var v_box_container: VBoxContainer = $VBoxContainer

var _modules_to_add: Array[Control] = []

func _ready() -> void:
	_clear_test_data()
	_add_modules_to_add()
	
func _clear_test_data():
	for _child in v_box_container.get_children():
		_child.queue_free()
		

func _add_modules_to_add():
	for _module in _modules_to_add:
		v_box_container.add_child(_module)
	_modules_to_add.clear()

func add_module(card_module: Control):
	if not card_module:
		return
	if not v_box_container:
		_modules_to_add.append(card_module)
		return
	v_box_container.add_child(card_module)
