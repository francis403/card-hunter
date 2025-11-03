extends CardEffectWithUserInput

## Select 1 enemy and deal damage to it
class_name AttackCardEffect

@export var damage: int = 10

var damage_dealt: int = 0
var body_part_hit: BodyPart.BodyPartType

var piece_attacked: Piece 

func card_effect():
	if not target_tile:
		return
	var player: PlayerPiece = BattleController.get_player()
	if not player:
		return
	if target_tile.piece_in_tile:
		_subscribe_if_monster(target_tile.piece_in_tile)
		target_tile.piece_in_tile.apply_damage(
			damage * player._strength,
			player._tile
		)
		damage_dealt = damage * player._strength
	elif target_tile.has_effect():
		target_tile.remove_tile_effects()

func _subscribe_if_monster(piece: Piece):
	if piece is GenericMonster:
		piece_attacked = piece
		if not piece.is_connected("body_part_hit", _on_monster_body_part_hit):
			piece.body_part_hit.connect(_on_monster_body_part_hit)

## TODO: not sure if this is smart, what if we get it afterwards?
func _on_monster_body_part_hit(body_part: BodyPart):
	self.body_part_hit = body_part.body_part_type

func update_data_after_card_is_played():
	print(update_data_after_card_is_played)
	super.update_data_after_card_is_played()
	self.card_effect_data.monster_effect_data.damage_dealt_to_monster_last_effect = damage_dealt
	self.card_effect_data.monster_effect_data.monster_targetted_last_effect = damage_dealt > 0
	print("current_body_part_hit: ", body_part_hit)
	self.card_effect_data.monster_effect_data.monster_body_part_last_hit = body_part_hit

func clean_card_effect() -> void:
	super.clean_card_effect()
	if piece_attacked and piece_attacked.is_connected("body_part_hit", _on_monster_body_part_hit):
		piece_attacked.disconnect("body_part_hit", _on_monster_body_part_hit)

func revert_card_effect() -> bool:
	piece_attacked.apply_damage(damage_dealt * -1, null, false)
	return true
