extends Piece
class_name PlayerPiece

@export var _deck: Array[CardResource] = []
@export var hand_size: int = 4

var draw_pile: Array[CardResource] = []
var discard_pile: Array[CardResource] = []
var cards_in_hand: Array[CardResource] = []

func _ready() -> void:
	_prepare_deck()
	
func _prepare_deck():
	draw_pile = _deck.duplicate()
	discard_pile = []
	shuffle_deck(draw_pile)
	
# We might have some special deck abilities
func shuffle_deck(deck: Array[CardResource]):
	deck.shuffle()
	
func draw_til_hand_size():
	var start_size: int = cards_in_hand.size()
	for n in range(start_size, hand_size):
		draw_card()
		
func draw_card() -> void:
	print(draw_card)
	if draw_pile.size() <= 0:
		# put all the cards in the discard pile in the draw pile
		draw_pile = discard_pile.duplicate()
		discard_pile = []
		shuffle_deck(draw_pile)
	var card_resource: CardResource = draw_pile.pop_front()
	cards_in_hand.append(card_resource)

func recover_stamina(stamina = _stamina_recover):
	self._stamina = min(self._stamina + stamina, _max_stamina)
