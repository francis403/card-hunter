extends MarginContainer
class_name PlayerBattleMenu


func _on_win_battle_pressed_and_sound_played() -> void:
	BattlemapSignals.monster_died.emit()


func _on_add_card_pressed_and_sound_played() -> void:
	pass # Replace with function body.


func _on_toggle_immortality_pressed_and_sound_played() -> void:
	SpecialSignals.immortallity_toggled_player.emit()


func _on_toggle_tile_status_pressed_and_sound_played() -> void:
	SpecialSignals.tile_map_status_label_toggled_signal.emit()


func _on_highlight_occupied_tiles_pressed_and_sound_played() -> void:
	SpecialSignals.highlight_occupied_tiles.emit()
