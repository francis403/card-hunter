extends WorldNodeScreen
## Show a list of cards
## Player picks a card and then the modules appear.
## The player then picks the module(s) that he wants and gets added to their available inventory
## Show success message
class_name DeforgeCardScreen

signal back_button_pressed

@onready var deck_container_component: DeckContainerComponent = %DeckContainerComponent
@onready var card_modules_container_component: CardModulesContainerComponent = %CardModulesContainerComponent
@onready var card: Card = %Card
@onready var deforge_button: SoundButton = $PanelContainer/VBoxContainer/HBoxContainer/CardToDeforge/VBoxContainer/DeforgeButton
@onready var back_button: SoundButton = %BackButton


func _ready() -> void:
	deck_container_component.card_clicked.connect(_on_card_selected_for_deforge)
	back_button.pressed.connect(_on_back_button_pressed)
	deforge_button.pressed.connect(_on_deforge_button_pressed)
	_remove_preview()


func _remove_preview():
	if PlayerController.get_deck():
		deck_container_component.init_deck_container_component(
			PlayerController.get_deck()._deck
		)

func _on_card_selected_for_deforge(_card: Card):
	var card_resource: CardResourceV2 = _card.card_resource
	print(_on_card_selected_for_deforge, ": ", card_resource.id)
	card.card_resource = card_resource.duplicate()
	card.initialize_card()
	card_modules_container_component.set_grid_elems_by_card(card.card_resource)


func _on_back_button_pressed() -> void:
	back_button_pressed.emit()
	self.queue_free()


func _on_deforge_button_pressed() -> void:
	if not card or not card.card_resource:
		return
	PlayerController.add_card_modules(
		card_modules_container_component.get_displayed_card_modules()
	)
	PlayerController.remove_card_from_deck(
		card.card_resource.id
	)
	if card.card_resource.is_forged:
		PlayerController.remove_forged_card(card.card_resource.id)
	self.world_node_screen_completed.emit(true)
	self.queue_free()
