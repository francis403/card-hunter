extends Node

## Reference to the current battlemap
var battlemap: Battlemap

## Reference to the player
var player: PlayerPiece
var player_hand: Hand

var turn_counter: int = 0

var player_turn_stats: PlayerTurnStats = PlayerTurnStats.new()

## TODO: probably here is not the ideal place
var _current_card_being_played: Card = null

var awaiting_player_input: bool = false

func _ready() -> void:
	BattleSignals.battle_scene_finished_loading.connect(_on_battle_scene_finished_loading_signal)
	BattlemapSignals.battlemap_generated.connect(_on_battlemap_generated_signal)
	BattlemapSignals.card_discarded_from_hand.connect(_on_card_discarded_from_hand)
	BattlemapSignals.monster_turn_started.connect(_on_player_turn_ended)
	BattlemapSignals.card_has_been_played.connect(_on_card_played)
	BattlemapSignals.awaiting_player_input.connect(_on_awaiting_player_input_signal)
	BattlemapSignals.player_input_received.connect(_on_player_input_received)
	BattlemapSignals.canceled_player_input.connect(_on_player_input_received)
	
func _on_battle_scene_finished_loading_signal(battle_scene: BattleGenericScene):
	self.player_hand = battle_scene.hand
	if not self.player_hand:
		push_error(_on_battle_scene_finished_loading_signal, " ERROR: player_hand not initiated in battle")
	
func _on_battlemap_generated_signal(map: Battlemap):
	print(_on_battlemap_generated_signal)
	self.battlemap = map
	if battlemap:
		self.player = battlemap.player

func _on_awaiting_player_input_signal():
	awaiting_player_input = true
	
func _on_player_input_received():
	awaiting_player_input = false

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
	
func get_monster() -> MonsterPiece:
	if not battlemap or not battlemap.monsters or battlemap.monsters.is_empty():
		return null
	return battlemap.monsters[0]

func get_tile(x: int, y: int) -> Tile:
	return battlemap.get_tile(x, y)

func get_random_tile(_center_tile: Tile, _config: TileHighlightConfig) -> Tile:
	return null
	
func discard_card_from_player(_card: Card) -> void:
	if not player:
		return
	player.discard_card_from_hand(_card)
	player_hand.discard_card(_card)

# SIGNALS

func _on_player_turn_ended():
	player_turn_stats = PlayerTurnStats.new()

func _on_card_discarded_from_hand(_index: int):
	player_turn_stats.total_number_of_cards_discarded += 1

func _on_card_played(_card_resource: CardResourceV2):
	player_turn_stats.total_number_of_cards_played += 1
