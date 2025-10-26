extends MarginContainer
class_name PlayerBattleMenu


func _on_win_battle_pressed_and_sound_played() -> void:
	BattlemapSignals.monster_died.emit()


func _on_add_card_pressed_and_sound_played() -> void:
	pass # Replace with function body.


func _on_toggle_immortality_pressed_and_sound_played() -> void:
	SpecialSignals.immortallity_toggled_player.emit()
