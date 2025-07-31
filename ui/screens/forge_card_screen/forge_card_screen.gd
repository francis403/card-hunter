extends Control
## 1. Show a list of available card modules
## 2. Player picks a module, it gets added to the card
## 3. Go back to step 2 until done
## 4. Player clicks forge and the card is done
## Show success message
class_name ForgeCardScreen

const MIN_AMOUNT_OF_MODULES: int = 1
const MAX_AMOUNT_OF_MODULES: int = 4

@onready var card_modules_container_component: CardModulesContainerComponent = %CardModulesContainerComponent
@onready var added_card_modules: CardModulesContainerComponent = %AddedCardModules
@onready var display_card: Card = %Card
@onready var card_title_input: LineEdit = %CardTitleInput
@onready var forge_button: SoundButton = %ForgeButton

var _built_card: Card

func _init() -> void:
	_built_card = Card.new()

func _ready() -> void:
	card_modules_container_component.set_grid_elems(
		PlayerController.get_card_modules()
	)
	for child: CardModuleComponent in card_modules_container_component.get_children_nodes():
		_add_signals_when_clicked(child, _on_available_card_module_clicked_signal)

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
	if _card_module is CardEffect:
		display_card.card_resource.add_play_card_effect(
			_card_module
		)
	elif _card_module is SpecialCardEffectResource:
		pass
	display_card.add_stamina_cost(_card_module.stamina_cost)
	display_card.card_resource.description = _generate_card_description()
	display_card.initialize_card()
	
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
	display_card.card_resource.remove_play_card_effect(
		_card_module
	)
	display_card.add_stamina_cost( -1 * _card_module.stamina_cost)
	display_card.card_resource.description = _generate_card_description()
	display_card.initialize_card()
	
func _on_back_button_pressed() -> void:
	self.queue_free()

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

func _is_valid_card_forge() -> bool:
	var title: String = card_title_input.text
	if title.length() == 0 || title.length() > 60:
		return false
	var _forged_card_resource: CardResourceV2 = display_card.card_resource 
	if not _forged_card_resource:
		return false
	var amount_of_play_actions_modules: int = _forged_card_resource.play_actions.size()
	if amount_of_play_actions_modules < MIN_AMOUNT_OF_MODULES or amount_of_play_actions_modules > MAX_AMOUNT_OF_MODULES:
		return false
	## TODO: for every card module validate each one
	return true

func _generate_card_description() -> String:
	var result: String = ""
	var _card_resource: CardResourceV2 = display_card.card_resource
	for play_action in _card_resource.play_actions:
		result += play_action.title + " "
	return result
