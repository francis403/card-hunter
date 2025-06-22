extends CardEffectWithUserInput

## Select 1 enemy and deal damage to it
class_name AttackCardEffect

@export var damage: int = 10

var damage_dealt: int = 0
var body_part_hit: BodyPart.BodyPartType

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
		if piece.body_part_hit.get_connections().size() == 0:
			piece.body_part_hit.connect(_on_monster_body_part_hit)

## TODO: not sure if this is smart, what if we get it afterwards?
func _on_monster_body_part_hit(body_part: BodyPart):
	self.body_part_hit = body_part.body_part_type

func update_data_after_card_is_played():
	print(update_data_after_card_is_played)
	super.update_data_after_card_is_played()
	self.card_effect_data.monster_effect_data.damage_dealt_to_monster_last_effect = damage_dealt
	self.card_effect_data.monster_effect_data.monster_targetted_last_effect = damage_dealt > 0
	self.card_effect_data.monster_effect_data.monster_body_part_last_hit = body_part_hit
