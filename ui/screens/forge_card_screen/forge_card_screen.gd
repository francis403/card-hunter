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

var _built_card: Card

func _init() -> void:
	_built_card = Card.new()

func _ready() -> void:
	card_modules_container_component.set_grid_elems(
		PlayerController.get_card_modules()
	)
	for child: CardModuleComponent in card_modules_container_component.get_children_nodes():
		_add_signals_when_clicked(child, _on_available_card_module_clicked_signal)
	
	# Connect input signals for real-time validation
	card_title_input.text_changed.connect(_on_title_input_changed)
	
	# Initialize UI feedback
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
	if not _validate_card_modules(display_card.card_resource):
		module_count_label.modulate = Color(1, 0.3, 0.3, 1)
		_valid = false
	
	# Update title length
	var title_length = card_title_input.text.length()
	title_length_label.text = "Title: %d/%d characters" % [title_length, MAX_TITLE_LENGTH] 
	title_length_label.modulate = Color(0.3, 1, 0.3, 1)
	if not _validate_title(card_title_input.text):
		title_length_label.modulate = Color(1, 0.3, 0.3, 1)
		_valid = false

	forge_button.disabled = not _valid
	forge_button.modulate = Color.WHITE if _valid else Color(0.7, 0.7, 0.7, 1)
	
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
	var nbr_card_modules: int = _card_resource.get_card_modules().size()
	return nbr_card_modules >= MIN_AMOUNT_OF_MODULES and nbr_card_modules <= MAX_AMOUNT_OF_MODULES
		
func _generate_card_description() -> String:
	var result: String = ""
	var _card_resource: CardResourceV2 = display_card.card_resource
	for play_action in _card_resource.play_actions:
		result += play_action.title + " "
	result += "\n"
	for special_effect in _card_resource.special_effects:
		result += special_effect.title + " "
	return result
