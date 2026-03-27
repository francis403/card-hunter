extends CardModule

## Represents one possible effect a card can have
class_name CardEffect

@export_group("Card Effect Data config")
## This data will configure the effect of all CardEffects in the CardEffect chain.
## It will be commiunicated between all card effects.
## For example, we can check how much data has been done to the monster, 
## or the target of a previous attack and use it instead of asking oto highlight again
var card_effect_data: CardEffectData
## Update the next card effect with the data gathered from the last
@export var update_next_card_effect_data: bool = true

@export_group("Card Module Color Configuration")
@export var top_section_background_color: Color = Color(0.124, 0.15, 0.153)
@export var bottom_section_background_color: Color = Color(0.384, 0.384, 0.384)

var _previous_card_module_resp: CardEffectResponse

func process_card_effect() -> CardEffectResponse:
	var response = await play_card_effect()
	if not response.should_rollback():
		clean_card_effect()
	return response

## Says if the card effect has been played successfully
## Only continues to next effect if so
func play_card_effect() -> CardEffectResponse:
	push_error("Using Default Card Effect!")
	GeneralUtils.debug_log(
		"-- Using Default Card Effect!",
		GameController.debug_mode_enabled
	)
	return CardEffectResponse.new()

## What happens when we cancel the card effect after it has already been played. 
## This is more to do with if you have multiple effects and you cancel it in the middle
## For example, let's say you have a discard effect followed by a move effect
## This revert_card_effect should add the card again
func revert_card_effect() -> bool:
	return false

func update_data_after_card_is_played():
	if not self.card_effect_data:
		self.card_effect_data = CardEffectData.new()
	if not self.card_effect_data.monster_effect_data:
		self.card_effect_data.monster_effect_data = MonsterEffectData.new()

func clean_card_effect() -> void:
	pass

func _get_my_node_scene_path() -> String:
	var s: Script = get_script() as Script
	if s:
		return s.resource_path
	return "res://resources/card/card_module/card_effect/card_effect.gd"
