extends MarginContainer
class_name PlayerBattleMenu

@export var _hide_nodes: Array[CanvasItem]
@export var _hand: Hand

var _deck_visualizer_instance: DeckVisualizer

func _on_win_battle_pressed_and_sound_played() -> void:
	BattlemapSignals.monster_died.emit()


## TODO: maybe on this one we just open the page and let the user pick, and not use the all menu
func _on_add_card_pressed_and_sound_played() -> void:
	pass # Replace with function body.


func _on_toggle_immortality_pressed_and_sound_played() -> void:
	SpecialSignals.immortallity_toggled_player.emit()


func _on_toggle_tile_status_pressed_and_sound_played() -> void:
	SpecialSignals.tile_map_status_label_toggled_signal.emit()


func _on_highlight_occupied_tiles_pressed_and_sound_played() -> void:
	SpecialSignals.highlight_occupied_tiles.emit()


func _on_add_card_via_screen_menu_item_clicked() -> void:
	if _deck_visualizer_instance:
		_deck_visualizer_instance.queue_free()
	_deck_visualizer_instance = Refs.deck_visualizer_scene.instantiate()
	_deck_visualizer_instance.deck = CardResourcesController.get_cards()
	_deck_visualizer_instance.on_card_clicked.connect(_on_card_clicked)
	_deck_visualizer_instance.on_back_button_clicked.connect(_on_back_button_clicked)
	_deck_visualizer_instance.listen_for_card_clicks = true
	_hide_elems()
	get_tree().root.add_child(_deck_visualizer_instance)
	
func _hide_elems():
	for _elem: CanvasItem in _hide_nodes:
		if _elem:
			_elem.visible = false
		
func _show_elems():
	for _elem: CanvasItem in _hide_nodes:
		if _elem:
			_elem.visible = true
	
func _on_card_clicked(_card: Card):
	#print("Card clicked: ", _card.card_resource.title)
	_hand.populate_hand([_card.card_resource])
	var _player: PlayerPiece = BattleController.get_player()
	if _player:
		_player.current_card_in_hand_size += 1
	_deck_visualizer_instance._on_back_button_pressed()
	
	
func _on_back_button_clicked():
	_show_elems()
	
