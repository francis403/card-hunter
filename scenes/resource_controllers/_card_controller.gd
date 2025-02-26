extends Node
class_name CardController

signal card_finished_playing

var battlemap: Battlemap

#TODO: this is getting a bit too big. Might think about dividing

func _ready() -> void:
	BattlemapSignals.battlemap_generated.connect(_on_battlemap_generated_signal)
	battlemap = BattleController.battlemap

func _on_battlemap_generated_signal(map: Battlemap):
	print(_on_battlemap_generated_signal)
	self.battlemap = map


func get_piece(
	card_resource: CardResource,
	card_category: CardCategory
):
	if card_category.target == Constants.TargetType.INHERIT:
		return _get_piece(card_resource.default_target)
	return _get_piece(card_category.target)

func _get_piece(
	target_type: Constants.TargetType
):
	if target_type == Constants.TargetType.SELF || target_type == Constants.TargetType.INHERIT:
		return battlemap.player
	return battlemap.monster


func get_area_type(
	card_resource: CardResource,
	card_category: CardCategory
) -> Constants.AreaType:
	if card_category.area_type == Constants.AreaType.INHERIT:
		return card_resource.default_area_type
	return card_category.area_type


func play_card_action(
	card_resource: CardResource,
	card_categories: CardCategoryDictionary = null
):
	print(play_card_action)
	
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
	card_categories: CardCategoryDictionary = null
):
	_apply_stamina_cost(card_resource.stamina_cost)
	card_finished_playing.emit()

func _apply_stamina_cost(stamina_cost: int):
	var player: PlayerPiece = BattleController.get_player()
	player._stamina -= stamina_cost
	BattlemapSignals.player_stamina_changed.emit(player._stamina)

func _discard_card():
	pass

func highlight_tiles(
	piece: Piece,
	area_type: Constants.AreaType,
	range: int
):
	if area_type == Constants.AreaType.RADIUS:
		battlemap.highligh_tiles_radius(
			piece,
			range
		)
	elif area_type == Constants.AreaType.CROSS:
		battlemap.highligh_tiles_cross(
			piece,
			range
		)
	elif area_type == Constants.AreaType.SPECIFIC:
		print("TODO: specific movement")
	elif area_type == Constants.AreaType.SHOTGUN:
		print("TODO: shotgun movement")
		
		
	
func card_can_be_played(
	card_resource: CardResource,
	card_categories: CardCategoryDictionary = null
):
	var stamina_cost = card_resource.stamina_cost
	var player: PlayerPiece = BattleController.get_player()

	return player._stamina >= stamina_cost
