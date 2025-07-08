extends Node

var battlemap: Battlemap

var turn_counter: int = 0

var player_turn_stats: PlayerTurnStats = PlayerTurnStats.new()

## TODO: probably here is not the ideal place
var _current_card_being_played: Card = null

func _ready() -> void:
	BattlemapSignals.battlemap_generated.connect(_on_battlemap_generated_signal)
	BattlemapSignals.card_discarded_from_hand.connect(_on_card_discarded_from_hand)
	BattlemapSignals.monster_turn_started.connect(_on_player_turn_ended)
	BattlemapSignals.card_has_been_played.connect(_on_card_played)
	
func _on_battlemap_generated_signal(map: Battlemap):
	print(_on_battlemap_generated_signal)
	self.battlemap = map

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		BattlemapSignals.canceled_player_input.emit()
		_handle_current_card_being_played_canceled()
	elif event.is_action_pressed("v_pressed"):
		BattlemapSignals.button_pressed_to_toggle_view_monster_parts.emit()

func _handle_current_card_being_played_canceled():
	if not _current_card_being_played:
		return
	_current_card_being_played.revert_all_played_card_effects()

func get_player() -> PlayerPiece:
	if not battlemap:
		return null
	return battlemap.player
	
func get_player_hand() -> Hand:
	if not battlemap:
		return null
	return battlemap.get_ha
	
func get_monster() -> MonsterPiece:
	if not battlemap or not battlemap.monsters or battlemap.monsters.is_empty():
		return null
	return battlemap.monsters[0]

func get_tile(x: int, y: int) -> Tile:
	return battlemap.get_tile(x, y)

## TODO: how can we do this knowing what we already know
func get_random_tile(center_tile: Tile, config: TileHighlightConfig) -> Tile:
	return null
	
# SIGNALS

func _on_player_turn_ended():
	player_turn_stats = PlayerTurnStats.new()

func _on_card_discarded_from_hand(index: int):
	player_turn_stats.total_number_of_cards_discarded += 1

func _on_card_played(card_resource: CardResourceV2):
	player_turn_stats.total_number_of_cards_played += 1
