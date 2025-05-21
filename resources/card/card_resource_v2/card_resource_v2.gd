extends Resource
class_name CardResourceV2

signal card_finished_playing

@export_group("Basic Card info")
@export var id: String
@export var title: String
@export_multiline var description: String
@export var stamina_cost: int = 0
@export var tag_array: Array[String] = []

@export_group("Card Effects")
@export var play_conditions: Array[Condition]
@export var play_actions: Array[CardEffect]
@export var special_effects: Array[SpecialCardEffect]

@export_group("Card Audio & animation")
@export var audio_stream: AudioStream

func play_card() -> bool:
	if not _is_card_playable():
		return false
	for condition in play_conditions:
		if not condition.is_condition_meet():
			return false
	for action in play_actions:
		action.play_card_effect()
	self._after_card_is_played()
	return true
	
	
func _is_card_playable() -> bool:
	if not _is_player_stamina_enough():
		return false
	for condition in play_conditions:
		if not condition.is_condition_meet():
			return false
	return true

func _is_player_stamina_enough() -> bool:
	var player: PlayerCharacter = BattleController.get_player()
	if not player:
		return false
	return player._stamina >= self.stamina_cost

func _after_card_is_played():
	if self.audio_stream:
		BattlemapSignals.play_card_stream.emit(self.audio_stream)
	_apply_stamina_cost(self.stamina_cost)
	card_finished_playing.emit()
	BattlemapSignals.card_has_been_played.emit(self)

func _apply_stamina_cost(stamina_cost: int):
	var player: PlayerPiece = BattleController.get_player()
	if not player:
		return
	player._stamina -= stamina_cost
	BattlemapSignals.player_stamina_changed.emit(player._stamina)
