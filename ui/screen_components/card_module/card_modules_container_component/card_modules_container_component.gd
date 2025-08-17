extends Control

## Takes in CardModuleComponent and turns it into a grid
class_name CardModulesContainerComponent

const CARD_MODULE_COMPONENT_SCENE: PackedScene = preload("res://ui/screen_components/card_module/card_module_component/card_module_component.tscn")

@export_group("Appearance")
@export var columns: int = 3
@export var h_separation: int = 15
@export var v_separation: int = 15

@onready var grid_container: GridContainer = %GridContainer

var _card_modules_displayed: Array[CardModule] = []

func _ready() -> void:
	self._clean_current_grid_elems()
	grid_container.columns = self.columns
	grid_container.add_theme_constant_override("h_separation", h_separation)
	grid_container.add_theme_constant_override("v_separation", v_separation)

func _clean_current_grid_elems():
	_card_modules_displayed.clear()
	for child in grid_container.get_children():
		child.queue_free()

func add_grim_elems(
	card_modules: Array[CardModule]
) -> Array[CardModuleComponent]:
	var result: Array[CardModuleComponent] = []
	for card_module in card_modules:
		var card_module_component: CardModuleComponent = add_grid_elem(card_module)
		result.append(card_module_component)
	return result

func add_grid_elem(
	card_module: CardModule,
) -> CardModuleComponent:
	if not card_module:
		print(set_grid_elems_by_card, " ERROR: null card_module provided")
	var card_module_instance: CardModuleComponent = CARD_MODULE_COMPONENT_SCENE.instantiate()
	card_module_instance.flat = true
	grid_container.add_child(card_module_instance)
	_card_modules_displayed.append(card_module)
	if card_module_instance.has_method("set_card_module"):
		card_module_instance.set_card_module(card_module)
	return card_module_instance

func set_grid_elems(
	_card_modules: Array[CardModule]
):
	self._clean_current_grid_elems()
	for card_module: CardModule in _card_modules:
		add_grid_elem(card_module)

func set_grid_elems_by_card(
	_card_resource: CardResourceV2
):
	self._clean_current_grid_elems()
	add_grim_elems(
		_card_resource.get_card_modules()
	)
	
func get_displayed_card_modules() -> Array[CardModule]:
	return _card_modules_displayed

func get_children_nodes() -> Array[Node]:
	return grid_container.get_children()
