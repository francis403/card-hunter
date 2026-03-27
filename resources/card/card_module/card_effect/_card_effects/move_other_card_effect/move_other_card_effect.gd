extends CardEffectWithUserInput
class_name MoveOtherCardEffect

@export var move_other_highlight_config: TileHighlightConfig

func to_dictionary() -> Dictionary:
	var result: Dictionary = super.to_dictionary()
	if move_other_highlight_config:
		result["move_other_highlight_config"] = move_other_highlight_config.to_dictionary()
	return result


func from_dictionary(dictionary: Dictionary) -> void:
	super.from_dictionary(dictionary)
	if dictionary.has("move_other_highlight_config"):
		move_other_highlight_config = TileHighlightConfig.new()
		move_other_highlight_config.from_dictionary(dictionary["move_other_highlight_config"])


func card_effect():
	if target_tile == null:
		return
	var piece_to_move: Piece = target_tile.piece_in_tile
	if not piece_to_move:
		return
	var player: Piece = BattleController.get_player()
	if not player: 
		return
	
	move_other_highlight_config.origin_tile = player._tile
	move_other_highlight_config.target_tile = piece_to_move._tile
	var move_tile: Tile = null
	move_tile = await self._get_user_input(move_other_highlight_config, piece_to_move)
	
	if not target_tile:
		return
	
	var battlemap: Battlemap = BattleController.battlemap
	battlemap.place_piece_in_tile(piece_to_move, target_tile)
	after_effect_is_played()
	if piece_to_move is MonsterPiece:
		piece_to_move.on_monster_moved_by_player(move_tile)

func after_effect_is_played():
	pass
