extends PanelContainer
class_name CardModuleDisplayer

const ARROW_FONT_SIZE: int = 32
const ARROW_TEXT: String = "━━━▶"
const ARROW_MIN_WIDTH: int = 60

@export var card_resource: CardResourceV2

@export_group("Card Module Definitions")
@export var start_card_module_type: PackedScene
@export var effect_card_module_type: PackedScene
@export var end_card_module_type: PackedScene
@export var card_module_layer_type: PackedScene

@onready var h_card_module_container: HBoxContainer = %HCardModuleContainer

func _ready() -> void:
	clear_modules()
	populate_from_card_resource(card_resource)


func populate_from_card_resource(_card_resource: CardResourceV2) -> void:
	if not _card_resource:
		return
	clear_modules()

	if not _card_resource.start_card_module:
		_add_modules_individually(_card_resource.get_card_modules())
		return

	_add_modules_as_layers(_card_resource.start_card_module)
	_add_end_layer()


func _add_modules_individually(modules: Array[CardModule]) -> void:
	for module in modules:
		_add_card_module(module)


func _add_modules_as_layers(start_module: CardModule) -> void:
	var current_layer: Array[CardModule] = [start_module]

	while not current_layer.is_empty():
		_add_layer(current_layer)
		current_layer = _get_next_layer(current_layer)


func _add_layer(modules: Array[CardModule]) -> void:
	var layer: CardModuleLayer = card_module_layer_type.instantiate()
	for module in modules:
		layer.add_module(_create_card_module_component(module))
	_add_component_to_container(layer)


func _add_end_layer() -> void:
	if not end_card_module_type:
		return
	var layer: CardModuleLayer = card_module_layer_type.instantiate()
	var end_component: Control = end_card_module_type.instantiate()
	layer.add_module(end_component)
	_add_component_to_container(layer)


func _get_next_layer(current_layer: Array[CardModule]) -> Array[CardModule]:
	var next_layer: Array[CardModule] = []
	for module in current_layer:
		for next_module in module.next_modules:
			if not next_layer.has(next_module):
				next_layer.append(next_module)
	return next_layer

func _create_card_module_component(module: CardModule) -> CardModuleComponent:
	var component: Control
	if module.module_type == "START" and start_card_module_type:
		component = start_card_module_type.instantiate()
	else:
		component = effect_card_module_type.instantiate()

	if component.has_method("set_card_module"):
		component.set_card_module(module)
	elif "card_module" in component:
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
