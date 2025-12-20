extends MenuItem

## Create a SubMenu of menu items
class_name MenuItemWithSubMenu

@export_group("Node to add menu item to")
@export var _parent_node: Control = null
@export var _add_menu_to_the_left: bool = true

@export_group("Extra Menu Items to add")
## Extra items to add as menu_items
@export var _extra_menu_items: Array[MenuItem]

## REQUIRES MENU ITEM SCENE.
@export var _menu_item_scene: PackedScene

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
	_add_extra_menu_items()
	_hide_child_menu_items()

func _add_extra_menu_items():
	pass

## Do we want this to trigger on click or on ready
## Receives a dictionary array of packedScene - display_name
func add_extra_menu_items_scenes(
	_extra_scenes: Array[Dictionary]
):
	if not _menu_item_scene or not _menu_item_scene.can_instantiate():
		push_warning("No Menu Item scene set.")
		return
	for _extra_scene: Dictionary in _extra_scenes:
		var _menu_item_instance: MenuItem = _menu_item_scene.instantiate()
		_menu_item_instance._display_name = "Test"
		if _extra_scene.has("display_name"):
			_menu_item_instance._display_name = _extra_scene["display_name"]
		var _packed_scene: PackedScene = _extra_scene["scene"]
		if _menu_item_instance is MenuItemWithScene:
			_menu_item_instance._scene = _packed_scene
			self.add_child(_menu_item_instance)

func _hide_child_menu_items():
	for _child in self.get_children():
		if _child is MenuItem:
			_child.visible = false

func _on_menu_item_clicked():
	if not _sub_menu_instance:
		_add_sub_menu()
	elif _sub_menu_instance is GenericMenu:
		if not _is_open:
			_sub_menu_instance.open_menu()
			_is_open = true
		else:
			self.close_content()

func _add_sub_menu():
	if not _parent_node or not _sub_menu_scene:
		push_warning("Validation Faild for SubMenu Menu Item.")
		return
	if not _sub_menu_scene.can_instantiate():
		push_warning("Sub Menu Scene cannot be instantiated")
		return
	_sub_menu_instance = _sub_menu_scene.instantiate()
	
	for _menu_item in _node_with_sub_items.get_children():
		if _menu_item is MenuItem:
			_menu_item.get_parent().remove_child(_menu_item)
			_sub_menu_instance.add_child(_menu_item)
			_menu_item.visible = true
			
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
	
func close_content():
	super.close_content()
	if _sub_menu_instance:
		_sub_menu_instance.close_menu()
	_is_open = false
