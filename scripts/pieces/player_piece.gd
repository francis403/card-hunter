extends Piece
class_name PlayerPiece

@export var _deck: Array[CardResource] = []
@export var hand_size: int = 4

var current_card_in_hand_size: int = 0

var draw_pile: Array[CardResource] = []
var discard_pile: Array[CardResource] = []
var cards_in_hand: Array[CardResource] = []

func _ready() -> void:
	_prepare_deck()
	BattlemapSignals.card_discarded_from_hand.connect(_on_card_discared_from_hand_signal)
	
func _prepare_deck():
	draw_pile = _deck.duplicate()
	discard_pile = []
	shuffle_deck(draw_pile)
	
# We might have some special deck abilities
func shuffle_deck(deck: Array[CardResource]):
	deck.shuffle()
	
func draw_til_hand_size():
	var new_cards_added: Array[CardResource] = []
	print(draw_til_hand_size)
	var start_size: int = cards_in_hand.size()
	for n in range(start_size, hand_size):
		var drawn_card = draw_card()
		cards_in_hand.append(drawn_card)
		current_card_in_hand_size += 1
		new_cards_added.append(drawn_card)
	return new_cards_added
		
func draw_card() -> CardResource:
	print(draw_card)
	if draw_pile.size() <= 0:
		# put all the cards in the discard pile in the draw pile
		draw_pile = discard_pile.duplicate()
		discard_pile = []
		shuffle_deck(draw_pile)
	var card_resource: CardResource = draw_pile.pop_front()
	return card_resource

func recover_stamina(stamina = _stamina_recover):
	self._stamina = min(self._stamina + stamina, _max_stamina)
	
func _on_card_discared_from_hand_signal(index: int):
	var card: CardResource = cards_in_hand.pop_at(index)
	current_card_in_hand_size -= 1
	discard_pile.append(card)
