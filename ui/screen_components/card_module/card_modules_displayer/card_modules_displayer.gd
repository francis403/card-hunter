extends PanelContainer
class_name CardModuleDisplayer

const CARD_MODULE_COMPONENT_SCENE: PackedScene = preload(
	"res://ui/screen_components/card_module/card_module_component/card_module_component.tscn"
)

const ARROW_FONT_SIZE: int = 32
const ARROW_TEXT: String = "━━━▶"
const ARROW_MIN_WIDTH: int = 60

@export var card_resource: CardResourceV2

@export_group("Card Module Definitions")
@export var start_card_module_type: PackedScene
@export var card_module_layer_type: PackedScene

@onready var h_card_module_container: HBoxContainer = %HCardModuleContainer

func _ready() -> void:
	_clean_preview()
	populate_from_card_resource(card_resource)

func _clean_preview():
	for _child in h_card_module_container.get_children():
		_child.queue_free()

## TODO: improve this code
func populate_from_card_resource(_card_resource: CardResourceV2) -> void:
	if not _card_resource:
		return
	clear_modules()

	if not _card_resource.start_card_module:
		var modules := _card_resource.get_card_modules()
		for module in modules:
			_add_card_module(module)
		return

	# Build layers level by level
	var current_layer_modules: Array[CardModule] = [_card_resource.start_card_module]

	while not current_layer_modules.is_empty():
		# Create layer and add all modules at this level
		var layer: CardModuleLayer = card_module_layer_type.instantiate()
		for module in current_layer_modules:
			var component: CardModuleComponent = _create_card_module_component(module)
			layer.add_module(component)
		_add_component_to_container(layer)

		# Collect next_modules from all nodes in current layer
		var next_layer_modules: Array[CardModule] = []
		for module in current_layer_modules:
			if module.next_modules:
				for next_module in module.next_modules:
					if not next_layer_modules.has(next_module):
						next_layer_modules.append(next_module)

		current_layer_modules = next_layer_modules

func _create_card_module_component(module: CardModule) -> CardModuleComponent:
	var component: Control
	if module.module_type == "START" and start_card_module_type:
		component = start_card_module_type.instantiate()
		if component.has_method("set_card_module"):
			component.set_card_module(module)
		elif "card_module" in component:
			component.card_module = module
	else:
		component = CARD_MODULE_COMPONENT_SCENE.instantiate()
		component.card_module = module
	return component


func _add_card_module(module: CardModule) -> void:
	var component:CardModuleComponent = _create_card_module_component(module)
	_add_component_to_container(component)


func add_card_module_component(component: CardModuleComponent) -> void:
	_add_component_to_container(component)


func _add_component_to_container(component: Control) -> void:
	if _get_module_count() > 0:
		var arrow := _create_arrow()
		h_card_module_container.add_child(arrow)
	h_card_module_container.add_child(component)


func clear_modules() -> void:
	for child in h_card_module_container.get_children():
		child.queue_free()


func get_card_modules() -> Array[CardModuleComponent]:
	var modules: Array[CardModuleComponent] = []
	for child in h_card_module_container.get_children():
		if child is CardModuleComponent:
			modules.append(child)
	return modules


func _get_card_module_count() -> int:
	return get_card_modules().size()


func _get_module_count() -> int:
	var count := 0
	for child in h_card_module_container.get_children():
		if not child is Label:  # Exclude arrows
			count += 1
	return count

func _create_arrow() -> Label:
	var arrow := Label.new()
	arrow.text = ARROW_TEXT
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arrow.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	arrow.custom_minimum_size.x = ARROW_MIN_WIDTH
	arrow.add_theme_font_size_override("font_size", ARROW_FONT_SIZE)
	return arrow
