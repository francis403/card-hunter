extends MenuItem

## Create a SubMenu of menu items
class_name SubMenuMenuItem

@export_group("Node to add menu item to")
@export var _parent_node: Control = null
@export var _add_menu_to_the_left: bool = true

@export_group("Menu Items to add")
## Items for the sub_menu item
#@export var _menu_items: Array[MenuItem]

@export_group("SubMenu Scene")
@export var _sub_menu_scene: PackedScene = null

## Provide a node with menu_items underneath it.
var _node_with_sub_items: Node = null
var _is_open: bool = false
var _sub_menu_instance: Node = null

func _ready() -> void:
	super._ready()
	menu_item_clicked.connect(_on_menu_item_clicked)
	if not _node_with_sub_items:
		_node_with_sub_items = self

func _on_menu_item_clicked():
	if not _sub_menu_instance:
		_add_sub_menu()
	elif _sub_menu_instance is GenericMenu:
		if not _is_open:
			_sub_menu_instance.open_menu()
			_is_open = true
		else:
			_sub_menu_instance.close_menu()
			_is_open = false

func _add_sub_menu():
	if not _parent_node or not _sub_menu_scene:
		push_warning("Validation Field for SubMenu Menu Item.")
		return
	if not _sub_menu_scene.can_instantiate():
		push_warning("Sub Menu Scene cannot be instantiated")
		return
	_sub_menu_instance = _sub_menu_scene.instantiate()
	
	for _menu_item in _node_with_sub_items.get_children():
		if _menu_item is MenuItem:
			_menu_item.get_parent().remove_child(_menu_item)
			_sub_menu_instance.add_child(_menu_item)
			
	#_parent_node.add_child(_sub_menu_instance)
	if _add_menu_to_the_left:
		if _parent_node is GenericMenu:
			_parent_node.add_to_menu(_sub_menu_instance, true)
		else:
			_parent_node.add_child(_sub_menu_instance)
			_parent_node.move_child(_sub_menu_instance, 0)
	_parent_node.queue_redraw()
	_sub_menu_instance.queue_redraw()
	_is_open = true
