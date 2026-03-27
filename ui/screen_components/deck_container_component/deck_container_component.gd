extends ScrollContainer
class_name DeckContainerComponent

signal card_clicked(card: Card)

const card_scene: PackedScene = preload("res://scenes/game_objects/cards/card/card.tscn")

@onready var grid_container: GridContainer = %GridContainer

@export var listen_for_card_clicks: bool = false
@export var deck: Array[CardResourceV2] = []
@export var grid_column_size = 3

func _ready() -> void:
	if deck:
		_add_cards_to_grid()
	grid_container.columns = grid_column_size

func init_deck_container_component(_deck: Array[CardResourceV2]):
	for child in grid_container.get_children():
		child.queue_free()
	self.deck = _deck
	_add_cards_to_grid()

func _add_cards_to_grid():
	for card_resource in deck:
		_instantiate_card(card_resource)

func _instantiate_card(card_resource: CardResourceV2):
	if not card_resource:
		return
	var card_instance: Card = card_scene.instantiate()
	card_instance.card_resource = card_resource.dup()
	card_instance.card_can_be_discarded = false
	card_instance.card_can_hover = false
	card_instance._card_can_be_played = false
	grid_container.add_child(card_instance)
	card_instance.initialize_card()
	if listen_for_card_clicks:
		card_instance.card_picked.connect(_on_card_picked_signal)


func _on_card_picked_signal(card: Card):
	self.card_clicked.emit(card)
