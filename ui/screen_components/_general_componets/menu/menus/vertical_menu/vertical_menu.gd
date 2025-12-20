extends GenericMenu
class_name VerticalMenu

@export var _fill_expand_menu_item: bool = true

@onready var vertical_menu_container: VBoxContainer = $VerticalMenuContainer

func _on_ready_per_menu_item(
	_child: MenuItem
):
	self.remove_child(_child)
	vertical_menu_container.add_child(_child)
	if _fill_expand_menu_item:
		_child.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func close_menu():
	super.close_menu()
	for _child in vertical_menu_container.get_children():
		if _child is MenuItem:
			_child.close_content()
