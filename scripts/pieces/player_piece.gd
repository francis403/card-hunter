extends Piece
class_name PlayerPiece

@export var _deck: Array[CardResource] = []
@export var hand_size: int = 4

var current_card_in_hand_size: int = 0

var draw_pile: Array[CardResource] = []
var discard_pile: Array[CardResource] = []
var cards_in_hand: Array[CardResource] = []

func _ready() -> void:
	BattleSignals.battle_start.connect(_on_battle_start_signal)
	BattlemapSignals.card_discarded_from_hand.connect(_on_card_discared_from_hand_signal)
	BattlemapSignals.card_removed_from_deck.connect(on_card_removed_from_deck)
	BattlemapSignals.deal_damage_to_attacked_squares.connect(_on_squares_attacked_signal)
	_prepare_deck()
	
func _prepare_deck():
	draw_pile = _deck.duplicate()
	discard_pile = []
	shuffle_deck(draw_pile)
	
# We might have some special deck abilities
func shuffle_deck(deck: Array[CardResource]):
	deck.shuffle()
	
func draw_til_hand_size() -> Array[CardResource]:
	var new_cards_added: Array[CardResource] = []
	var start_size: int = cards_in_hand.size()
	for n in range(start_size, hand_size):
		var drawn_card = draw_card()
		cards_in_hand.append(drawn_card)
		current_card_in_hand_size += 1
		new_cards_added.append(drawn_card)
	return new_cards_added
		
func draw_card() -> CardResource:
	if draw_pile.size() <= 0:
		# put all the cards in the discard pile in the draw pile
		draw_pile = discard_pile.duplicate()
		discard_pile = []
		BattlemapSignals.discard_pile_updated.emit(discard_pile)
		shuffle_deck(draw_pile)
	var card_resource: CardResource = draw_pile.pop_front()
	return card_resource

func recover_stamina(stamina = _stamina_recover):
	self._stamina = min(self._stamina + stamina, _max_stamina)
	BattlemapSignals.player_stamina_changed.emit(self._stamina)
	
func _on_battle_start_signal():
	pass

func _on_card_discared_from_hand_signal(index: int):
	var card: CardResource = cards_in_hand.pop_at(index)
	current_card_in_hand_size -= 1
	discard_pile.append(card)
	BattlemapSignals.discard_pile_updated.emit(discard_pile)

func on_card_removed_from_deck(index: int):
	var card: CardResource = cards_in_hand.pop_at(index)
	current_card_in_hand_size -= 1

func _on_squares_attacked_signal(damage: int):
	#print(_on_squares_attacked_signal)
	if self._tile.is_tile_attacked:
		self.apply_damage(damage)
		
		
func _die():
	BattleSignals.battle_lost.emit()
	self.queue_free()
