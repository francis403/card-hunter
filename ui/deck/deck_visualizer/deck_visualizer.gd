extends Control
class_name DeckVisualizer

const card_scene: PackedScene = preload("res://scenes/game_objects/cards/card/card.tscn")

@export var deck: Array[CardResource] = []

@onready var grid_container: GridContainer = %GridContainer

func _ready() -> void:
	print(_ready)
	_add_cards_to_grid()
	

func _add_cards_to_grid():
	for card_resource in deck:
		_instantiate_card(card_resource)


func _instantiate_card(card_resource: CardResource):
	if not card_resource:
		return
	var card_instance: Card = card_scene.instantiate()
	card_instance.card_can_be_discarded = false
	card_instance.card_can_hover = false
	grid_container.add_child(card_instance)
	card_instance.card_resource = card_resource
	card_instance.initialize_card()


## TODO: is this the best way?
func _on_back_button_pressed() -> void:
	self.queue_free()
