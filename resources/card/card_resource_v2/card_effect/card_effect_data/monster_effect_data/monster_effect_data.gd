extends Resource

## Stores the previous interation with the monster
class_name MonsterEffectData

var monster_targetted_last_effect: bool = false
var damage_dealt_to_monster_total: int = 0
var damage_dealt_to_monster_last_effect: int = 0
var monster_body_part_last_hit: BodyPart.BodyPartType
