extends MenuItem

## A menu button that just opens a new page
class_name SceneMenuItem

@export var _scene: PackedScene = null

func _ready() -> void:
	super._ready()
	menu_item_clicked.connect(_on_menu_item_clicked)

func _on_menu_item_clicked():
	if not _scene or not _scene.can_instantiate():
		push_warning("Menu item scene can not be instantiated.")
		return
	get_tree().root.add_child(_scene.instantiate())
