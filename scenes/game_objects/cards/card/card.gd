extends PanelContainer
class_name Card

@export var card_resource: CardResource

@onready var card_title: Label = %CardTitle
@onready var card_description: Label = %CardDescription


func _ready() -> void:
	if card_resource:
		_initialize_card()


func _initialize_card():
	card_title.text = card_resource.title
	card_description.text = card_resource.description
