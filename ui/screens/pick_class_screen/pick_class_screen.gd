extends Control
class_name PickClassScreen

@onready var weapons_container: HBoxContainer = %WeaponsContainer
@onready var weapon_description_subscreen: ClassDescriptionSubscreen = %WeaponDescriptionSubscreen

@export var class_choices: Array[PlayerClass] = []

func _ready() -> void:
	_hide_preview_content()
	_populate_actual_content()
	_populate_weapon_description_subscreen()


func _hide_preview_content():
	for item in weapons_container.get_children():
		item.queue_free()

func _populate_actual_content():
	for player_class in class_choices:
		var class_pick_instance: ClassPickerComponent =\
			Refs.weapon_picker_component_scene.instantiate()
		class_pick_instance.title = player_class.player_class_name
		class_pick_instance.player_class = player_class
		class_pick_instance.is_locked = not LockedContentController.is_unlocked(player_class.player_class_name)
		if class_pick_instance.is_locked:
			class_pick_instance.card_back_texture = Refs.locked_card_back_texture
			class_pick_instance._enable_click = false
			class_pick_instance.title = "???????"
		else:
			class_pick_instance.card_back_texture = player_class.player_class_icon
		class_pick_instance.class_picker_clicked.connect(_on_class_pick_instance_clicked)
		weapons_container.add_child(class_pick_instance)

func _populate_weapon_description_subscreen():
	if not class_choices.is_empty():
		weapon_description_subscreen.player_class = class_choices[0]
		weapon_description_subscreen.reload_ui()
		PlayerController.replace_deck(class_choices[0].default_class_deck)
	weapon_description_subscreen.on_container_button_clicked.connect(_on_container_button_clicked)
	weapon_description_subscreen.on_cards_preview_button_clicked.connect(_on_card_preview_button_clicked)

func _on_class_pick_instance_clicked(
	_instance: ClassPickerComponent
):
	weapon_description_subscreen.player_class = _instance.player_class
	weapon_description_subscreen.reload_ui()
	
func _on_container_button_clicked():
	get_tree().change_scene_to_packed(Constants.main_world_scroll_scene)
	
func _on_card_preview_button_clicked():
	ScreenUtils.show_deck_visualizer_screen(
		weapon_description_subscreen.player_class.default_class_deck
	)
