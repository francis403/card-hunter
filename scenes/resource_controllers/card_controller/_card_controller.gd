extends ResourceController
class_name CardController

signal card_finished_playing

func _ready() -> void:
	BattlemapSignals.battlemap_generated.connect(_on_battlemap_generated_signal)
	battlemap = BattleController.battlemap

func _on_battlemap_generated_signal(map: Battlemap):
	print(_on_battlemap_generated_signal)
	self.battlemap = map


func play_card_action(
	card_resource: CardResource,
	card_categories: EventCategoryDictionary = null
):
	
	if not card_can_be_played(card_resource, card_categories):
		return
	
	if not battlemap:
		battlemap = BattleController.battlemap
	
	var stamina_cost = card_resource.stamina_cost
	var player: PlayerPiece = BattleController.get_player()

	if player._stamina < stamina_cost:
		# cancel player card
		BattlemapSignals.canceled_player_input.emit()
	
func after_card_is_played(
	card_resource: CardResource,
	card_categories: EventCategoryDictionary = null
):
	_apply_stamina_cost(card_resource.stamina_cost)
	card_finished_playing.emit()

func _apply_stamina_cost(stamina_cost: int):
	var player: PlayerPiece = BattleController.get_player()
	player._stamina -= stamina_cost
	BattlemapSignals.player_stamina_changed.emit(player._stamina)

func _discard_card():
	pass

func card_can_be_played(
	card_resource: CardResource,
	card_categories: EventCategoryDictionary = null
):
	var stamina_cost = card_resource.stamina_cost
	var player: PlayerPiece = BattleController.get_player()

	return player._stamina >= stamina_cost
