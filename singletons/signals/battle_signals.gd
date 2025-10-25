extends Node

signal battle_scene_finished_loading(
	battle_scene: BattleGenericScene
)
signal battle_start
signal battle_lost
signal battle_won

## Sent right before the battle is freed
signal battle_complete
signal boss_battle_complete
signal game_complete
