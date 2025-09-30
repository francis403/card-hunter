extends Control
## 1. Show a list of available card modules
## 2. Player picks a module, it gets added to the card
## 3. Go back to step 2 until done
## 4. Player clicks forge and the card is done
## Show success message
class_name ForgeCardScreen

const MIN_AMOUNT_OF_MODULES: int = 1
const MAX_AMOUNT_OF_MODULES: int = 4
const MIN_TITLE_LENGTH: int = 1
const MAX_TITLE_LENGTH: int = 30

@onready var card_modules_container_component: CardModulesContainerComponent = %CardModulesContainerComponent
@onready var added_card_modules: CardModulesContainerComponent = %AddedCardModules
@onready var display_card: Card = %Card
@onready var card_title_input: LineEdit = %CardTitleInput
@onready var forge_button: SoundButton = %ForgeButton
@onready var module_count_label: Label = %ModuleCountLabel
@onready var title_length_label: Label = %TitleLengthLabel
@onready var validation_error_label: Label = %ValidationErrorLabel

var _built_card: Card
var _built_card_errors: Array[String] = []

func _init() -> void:
	_built_card = Card.new()

func _ready() -> void:
	if display_card and display_card.card_resource:
		display_card.card_resource = CardResourceV2.new()
	card_modules_container_component.set_grid_elems(
		PlayerController.get_card_modules()
	)
	for child: CardModuleComponent in card_modules_container_component.get_children_nodes():
		_add_signals_when_clicked(child, _on_available_card_module_clicked_signal)
	
	card_title_input.text_changed.connect(_on_title_input_changed)
	_update_validation_display()

func _on_forge_button_pressed() -> void:
	if not _is_valid_card_forge():
		print(_on_forge_button_pressed, ": invalid")
		return
	_built_card.card_resource = display_card.card_resource.duplicate()
	_built_card.card_resource.title = card_title_input.text
	_built_card.card_resource.id = card_title_input.text.replace(" ", "")
	_built_card.card_resource.is_forged = true
	PlayerController.add_card_to_deck(_built_card.card_resource)
	PlayerController.add_forged_card(_built_card.card_resource)
	for _module: CardModuleComponent in added_card_modules.get_children_nodes():
		PlayerController.remove_card_module(_module.card_module)
	_on_back_button_pressed()

func _add_signals_when_clicked(
	card_module_component: CardModuleComponent,
	_callable: Callable
):
	card_module_component.enable_clicking()
	card_module_component.clicked.connect(_callable)

func _on_available_card_module_clicked_signal(
	_card_module_component: CardModuleComponent
):
	var _card_module: CardModule = _card_module_component.card_module
	if not _card_module:
		return
	
	# Check if adding this module would create an invalid combination
	if not _can_add_module(_card_module):
		_show_module_placement_warning(_card_module)
		return
	
	_add_card_module_to_new_card(_card_module_component, _card_module)
	if not display_card.card_resource:
		display_card.card_resource = CardResourceV2.new()
	display_card.card_resource.add_card_module(
		_card_module
	)
	display_card.add_stamina_cost(_card_module.stamina_cost)
	display_card.card_resource.description = _generate_card_description()
	display_card.initialize_card()
	
	# Update validation display when modules change
	_update_validation_display()

func _can_add_module(new_module: CardModule) -> bool:
	if not display_card.card_resource:
		return true
	
	var current_modules = display_card.card_resource.get_card_modules()
	
	# Check if we're at the module limit
	if current_modules.size() >= MAX_AMOUNT_OF_MODULES:
		return false
	
	# Test if adding this module would create a valid combination
	var test_modules = current_modules.duplicate()
	test_modules.append(new_module)
	
	var validation_result = CardModuleValidator.validate_card_modules(test_modules)
	return validation_result.is_valid

func _show_module_placement_warning(module: CardModule):
	# For now, we'll just print the warning
	# In a full implementation, this could show a tooltip or popup
	var current_modules = display_card.card_resource.get_card_modules() if display_card.card_resource else []
	var test_modules = current_modules.duplicate()
	test_modules.append(module)
	
	var validation_result = CardModuleValidator.validate_card_modules(test_modules)
	var _error: String = "Cannot add '%s': %s" % [module.title, ", ".join(validation_result.errors)]
	_built_card_errors.append(_error)
	_add_error_to_validation_label()
	#print("Cannot add '%s': %s" % [module.title, ", ".join(validation_result.errors)])
	
func _add_card_module_to_new_card(
	_card_module_component: CardModuleComponent,
	_card_module: CardModule
):
	_card_module_component.queue_free()
	var _added_module: CardModuleComponent = added_card_modules.add_grid_elem(
		_card_module
	)
	_add_signals_when_clicked(_added_module, _on_click_remove_from_new_card)

func _on_click_remove_from_new_card(card_module: CardModuleComponent):
	_add_card_module_to_available_options(card_module, card_module.card_module)

func _add_card_module_to_available_options(
	_card_module_component: CardModuleComponent,
	_card_module: CardModule
):
	_card_module_component.queue_free()
	var component: CardModuleComponent = card_modules_container_component.add_grid_elem(
		_card_module
	)
	_add_signals_when_clicked(component, _on_available_card_module_clicked_signal)
	display_card.card_resource.remove_card_module(
		_card_module
	)
	display_card.add_stamina_cost( -1 * _card_module.stamina_cost)
	display_card.card_resource.description = _generate_card_description()
	display_card.initialize_card()
	
	# Update validation display when modules change
	_update_validation_display()

func _on_title_input_changed(_new_text: String) -> void:
	_update_validation_display()

func _update_validation_display() -> void:
	var _valid: bool = true
	var module_count = 0
	
	if display_card.card_resource:
		module_count = display_card.card_resource.get_card_modules().size()
	
	module_count_label.text = "Modules: %d/%d" % [module_count, MAX_AMOUNT_OF_MODULES]
	module_count_label.modulate = Color(0.3, 1, 0.3, 1)
	var modules_valid = _validate_card_modules(display_card.card_resource)
	if not modules_valid:
		module_count_label.modulate = Color(1, 0.3, 0.3, 1)
		_valid = false
	
	# Update title length display
	var title_length = card_title_input.text.length()
	title_length_label.text = "Title: %d/%d characters" % [title_length, MAX_TITLE_LENGTH] 
	title_length_label.modulate = Color(0.3, 1, 0.3, 1)
	if not _validate_title(card_title_input.text):
		title_length_label.modulate = Color(1, 0.3, 0.3, 1)
		_valid = false
	
	# Update validation errors display
	_built_card_errors.clear()
	if not modules_valid:
		_built_card_errors.append_array(_get_validation_errors(display_card.card_resource))
	
	_add_error_to_validation_label()
	
	# Update visual feedback for invalid modules
	_update_module_visual_feedback()

	forge_button.disabled = not _valid
	forge_button.modulate = Color.WHITE if _valid else Color(0.7, 0.7, 0.7, 1)

func _add_error_to_validation_label(
):
	if _built_card_errors.size() > 0:
		validation_error_label.text = "Issues:\n• " + "\n• ".join(_built_card_errors)
		validation_error_label.visible = true
	else:
		validation_error_label.visible = false

func _update_module_visual_feedback():
	if not display_card.card_resource:
		return
	
	var validation_result = CardModuleValidator.validate_card_modules(display_card.card_resource.get_card_modules())
	
	# Reset all module visuals to normal
	for child: CardModuleComponent in added_card_modules.get_children_nodes():
		child.modulate = Color.WHITE
	
	# Highlight invalid modules
	for invalid_module in validation_result.invalid_modules:
		for child: CardModuleComponent in added_card_modules.get_children_nodes():
			if child.card_module and child.card_module.equals(invalid_module):
				child.modulate = Color(1, 0.6, 0.6, 1)  # Light red tint
	
func _on_back_button_pressed() -> void:
	self.queue_free()

func _is_valid_card_forge() -> bool:
	var title: String = card_title_input.text
	if not _validate_title(title):
		return false
	var _forged_card_resource: CardResourceV2 = display_card.card_resource 
	if not _forged_card_resource:
		return false
	if not _validate_card_modules(_forged_card_resource):
		return false
	## TODO: for every card module validate each one
	return true

func _validate_title(_title: String) -> bool:
	return _title.length() >= MIN_TITLE_LENGTH and _title.length() <= MAX_TITLE_LENGTH

func _validate_card_modules(_card_resource: CardResourceV2) -> bool:
	if not _card_resource:
		return false
	
	var modules = _card_resource.get_card_modules()
	var nbr_card_modules: int = modules.size()
	
	# Check basic count limits
	if nbr_card_modules < MIN_AMOUNT_OF_MODULES or nbr_card_modules > MAX_AMOUNT_OF_MODULES:
		return false
	
	# Use comprehensive module validation
	var validation_result = CardModuleValidator.validate_card_modules(modules)
	return validation_result.is_valid

func _get_validation_errors(_card_resource: CardResourceV2) -> Array[String]:
	if not _card_resource:
		return ["No card resource available"]
	
	var modules = _card_resource.get_card_modules()
	var errors: Array[String] = []
	
	# Get detailed validation errors
	var validation_result = CardModuleValidator.validate_card_modules(modules)
	errors.append_array(validation_result.errors)
	
	return errors
		
func _generate_card_description() -> String:
	var result: String = ""
	var _card_resource: CardResourceV2 = display_card.card_resource
	for play_action in _card_resource.play_actions:
		result += play_action.title + " "
	result += "\n"
	for special_effect in _card_resource.special_effects:
		result += special_effect.title + " "
	return result
