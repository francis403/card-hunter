extends MarginContainer
class_name GenericMenu

var _menu_items_count: int = 0
var _generic_menus_count: int = 0

func _ready() -> void:
	_process_menu_items()
	
func _process_menu_items():
	for _child in self.get_children():
		if _child is MenuItem:
			_on_ready_per_menu_item(_child)
			self._menu_items_count += 1
		if _child is GenericMenu:
			_on_ready_per_generic_menu(_child)
			_generic_menus_count += 1
			
	_process_warning_messages()

## Override this function
func _on_ready_per_menu_item(_child: MenuItem):
	pass

func _on_ready_per_generic_menu(_child: GenericMenu):
	pass

## Requires MenuItem or GenericMenu
func add_to_menu(
	_child: Node,
	_add_to_the_top: bool = false
):
	pass

func _process_warning_messages():
	if (_menu_items_count + _generic_menus_count) == 0:
		push_warning("No menu items or menus found for a Menu.")

func close_menu():
	self.visible = false
	
func open_menu():
	self.visible = true
