extends GenericMenu
class_name MenuRoot

@onready var menu_list_h_container: HBoxContainer = %MenuListHContainer

## Reference to all menus in the generic_menu
var _menu_array: Array[GenericMenu] = []

#func _ready() -> void:
	#_move_menus_to_list_container()

func _on_ready_per_generic_menu(_child: GenericMenu):
	add_to_menu(_child)

func add_to_menu(
	_child: Node,
	_add_to_the_top: bool = false
):
	if _child.get_parent():
		self.remove_child(_child)
	menu_list_h_container.add_child(_child)
	if _add_to_the_top:
		menu_list_h_container.move_child(_child, 0)
	_menu_array.append(_child)

#func _move_menus_to_list_container():
	#for _child in self.get_children():
		#if _child is GenericMenu:
			#_menu_array.append(_child)
			#self.remove_child(_child)
			#menu_list_h_container.add_child(_child)
