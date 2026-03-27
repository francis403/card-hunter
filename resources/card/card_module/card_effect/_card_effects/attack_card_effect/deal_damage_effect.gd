extends CardEffect

## Just like a normal attack_card_effect but it gets the input from the previous module
class_name DealDamageEffect

@export var damage: int = 10

var damage_dealt: int = 0
var body_part_hit: BodyPart.BodyPartType
var piece_attacked: Piece 

func play_card_effect() -> CardEffectResponse:
	var _response: CardEffectResponse = CardEffectResponse.new()
	_response.set_failure()
	if not _previous_card_module_resp:
		push_error("Previous card_module response necessary but not provided.")
		return _response
	if not _previous_card_module_resp.tile_selected:
		push_error("Previous card_module response has no selected tile")
		return _response
	var _selected_tile: Tile = _previous_card_module_resp.tile_selected
	if not _selected_tile.piece_in_tile:
		push_warning("Previous card_module response tile has no piece in it!")
		return _response
	var _attacking_piece: Piece = BattleController.get_player()
	var _piece: Piece = _selected_tile.piece_in_tile
	var _actual_damage: int = damage * _attacking_piece._strength
	_subscribe_if_monster(_piece)
	_piece.apply_damage(
		_actual_damage,
		_attacking_piece._tile
	)
	damage_dealt = _actual_damage
	_response.set_ok()
	return _response


func _subscribe_if_monster(piece: Piece):
	if piece is GenericMonster:
		piece_attacked = piece
		if not piece.is_connected("body_part_hit", _on_monster_body_part_hit):
			piece.body_part_hit.connect(_on_monster_body_part_hit)

## TODO: not sure if this is smart, what if we get it afterwards?
func _on_monster_body_part_hit(body_part: BodyPart):
	self.body_part_hit = body_part.body_part_type
