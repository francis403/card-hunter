extends PanelContainer
class_name Card

@export var card_resource: CardResource

@onready var card_title: Label = %CardTitle
@onready var card_description: Label = %CardDescription
@onready var stamina_cost_label: Label = %StaminaCostLabel
@onready var discard_button: Button = %DiscardButton

var card_category_dictionary: CardCategoryDictionary

# TODO: this should probably go to the hand_manager
var _mouse_hovering: bool = false

func _ready() -> void:
	if card_resource:
		initialize_card()

func initialize_card():
	card_title.text = card_resource.title
	card_description.text = card_resource.description
	stamina_cost_label.text = "Stamina: " + str(card_resource.stamina_cost)
	card_category_dictionary = CardCategoryDictionary.new()
	if card_resource.card_categories:
		card_category_dictionary.populate_dictionary(card_resource.card_categories)
	
# TODO: this should probably go to the hand_manager
func _input(event: InputEvent) -> void:
	if _mouse_hovering and event.is_action_pressed("left_click"):
		_play_card()

func _play_card():
	var card_controller_instance: CardController = card_resource.card_ability_controller_scene.instantiate()
	card_controller_instance.card_finished_playing.connect(_on_card_finished_playing)
	card_controller_instance.play_card_action(
		card_resource, 
		card_category_dictionary
	)

func _on_card_finished_playing():
	_discard_card()

func _discard_card():
	BattlemapSignals.card_discarded_from_hand.emit(self.get_index())
	self.queue_free()

func _on_mouse_entered() -> void:
	_mouse_hovering = true


func _on_mouse_exited() -> void:
	_mouse_hovering = false
	

func _on_discard_button_pressed() -> void:
	_discard_card()
