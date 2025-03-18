extends VBoxContainer
class_name ClassPickerComponent

@onready var card_back: CardBack = $CardBack
@onready var title_label: Label = %Title

@export var card_back_texture: AtlasTexture
@export var title: String
@export var player_class: PlayerClass

func _ready() -> void:
	card_back.update_card_back_image(card_back_texture)
	title_label.text = title


func _on_card_back_gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		#PlayerController.replace_deck()
		if player_class:
			PlayerController.replace_deck(player_class.default_class_deck)
		get_tree().change_scene_to_packed(Constants.quest_picker_screen_scroll_scene)
