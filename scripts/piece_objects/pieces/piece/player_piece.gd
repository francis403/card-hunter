extends Piece
class_name PlayerPiece

signal player_hit

@export var is_player_damageable: bool = true
@export var hand_size: int = 4
@export var max_hand_size: int = 10

## Used when we want to replace the deck of the player
@export var replace_deck: PlayerDeck = null

var current_card_in_hand_size: int = 0

## TODO: Need to convert all of this into PlayerDeck
var draw_pile: Array[CardResourceV2] = []
var discard_pile: Array[CardResourceV2] = []
var _deck: Array[CardResourceV2] = []

func _ready() -> void:
	BattleSignals.battle_start.connect(_on_battle_start_signal)
	BattlemapSignals.card_removed_from_deck.connect(on_card_removed_from_deck)
	BattlemapSignals.deal_damage_to_attacked_squares.connect(_on_squares_attacked_signal)
	#BattlemapSignals.before_player_movement.connect(_before_player_movement_signal)
	BattlemapSignals.card_discarded_from_hand_reverted.connect(_on_card_discarded_from_hand_reverted_signal)
	_prepare_deck()
	
func _prepare_deck():
	if replace_deck:
		_deck = replace_deck._deck
	else:
		_deck = PlayerController.get_deck()._deck
	draw_pile = _deck.duplicate()
	discard_pile = []
	shuffle_deck(draw_pile)
	
func set_deck(player_deck: PlayerDeck ):
	_deck = player_deck._deck
	
# We might have some special deck abilities
func shuffle_deck(deck: Array[CardResourceV2]):
	deck.shuffle()
	
func draw_til_hand_size() -> Array[CardResourceV2]:
	var new_cards_added: Array[CardResourceV2] = []
	var start_size: int = current_card_in_hand_size
	for n in range(start_size, hand_size):
		var drawn_card = draw_card()
		new_cards_added.append(drawn_card)
	return new_cards_added
		
func draw_card() -> CardResourceV2:
	if draw_pile.size() <= 0:
		# put all the cards in the discard pile in the draw pile
		draw_pile = discard_pile.duplicate()
		discard_pile = []
		BattlemapSignals.discard_pile_updated.emit(discard_pile)
		shuffle_deck(draw_pile)
	var card_resource: CardResourceV2 = draw_pile.pop_front()
	current_card_in_hand_size += 1
	return card_resource

func recover_stamina(stamina = _stamina_recover):
	self._stamina = min(self._stamina + stamina, _max_stamina)
	BattlemapSignals.player_stamina_changed.emit(self._stamina)
	
func discard_card_from_hand(_card: Card):
	current_card_in_hand_size -= 1
	discard_pile.append(_card.card_resource.duplicate())
	BattlemapSignals.discard_pile_updated.emit(discard_pile)
	
func _on_battle_start_signal():
	BattlemapSignals.player_turn_started.emit()

func _on_card_discarded_from_hand_reverted_signal(card_resource: CardResourceV2):
	print(_on_card_discarded_from_hand_reverted_signal)
	## I should probably make sure we manage to revert first
	current_card_in_hand_size += 1
	var index_of_discarded_card: int = _find_index_of_discarded_card(card_resource.id)
	if index_of_discarded_card >= 0:
		discard_pile.remove_at(index_of_discarded_card)
		BattlemapSignals.discard_pile_updated.emit(discard_pile)

func _find_index_of_discarded_card(card_id: String) -> int:
	for i in range(discard_pile.size() - 1, -1, -1):
		print(_find_index_of_discarded_card, ": ", i)
		if discard_pile[i].id == card_id:
			return i
	return -1


func hit_player(
	origin_tile: Tile,
	damage: int
):
	self.apply_damage(damage, origin_tile)
	self.player_hit.emit()
	
func on_card_removed_from_deck():
	current_card_in_hand_size -= 1

func _on_squares_attacked_signal(
	origin_tile: Tile,
	damage: int
):
	if self._tile.is_tile_attacked:
		hit_player(origin_tile, damage)


## TODO: this is not smart, need to improve this
func _before_player_movement_signal():
	pass
		
func _die():
	BattlemapSignals.player_died.emit()
	BattleSignals.battle_lost.emit()
	self.queue_free()
