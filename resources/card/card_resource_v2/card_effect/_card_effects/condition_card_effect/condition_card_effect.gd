extends CardEffect
class_name ConditionCardEffect

enum ConditionEnum {
	MONSTER_HIT_BY_PLAYER,
	MONSTER_BODY_PART_HIT_BY_PLAYER,
	PLAYER_HIT_BY_MONSTER,
	PLAYER_MOVED_BY_MONSTER,
	MONSTER_MOVED_BY_PLAYER
}

@export var condition: ConditionEnum
@export var specific_monster_body_part: BodyPart.BodyPartType


func play_card_effect() -> CardEffectResponse:
	var response: CardEffectResponse = CardEffectResponse.new()
	if not condition_matched(self.card_effect_data):
		response.set_failure(false)
		return response
	## Do effect or just return true?
	response.set_ok()
	return response

## TODO
func condition_matched(card_effect_data: CardEffectData) -> bool:
	match condition:
		ConditionEnum.MONSTER_HIT_BY_PLAYER:
			return _was_monster_hit()
		ConditionEnum.MONSTER_BODY_PART_HIT_BY_PLAYER:
			if not _was_monster_hit():
				return false
			var hit_body_part = card_effect_data.monster_effect_data.monster_body_part_last_hit
			return specific_monster_body_part == hit_body_part
	return false

func _was_monster_hit() -> bool:
	if not card_effect_data || not card_effect_data.monster_effect_data:
		return false
	return card_effect_data.monster_effect_data.monster_targetted_last_effect
	
	
