extends StateWithMovement
class_name PounceState

func do_action():
	if not attack_tiles_highlight or not monster._tile:
		return
	attack_tiles_highlight.origin_tile = monster._tile
	attack_tiles_highlight.target_tile = target._tile
	BattleController.battlemap.clear_highlighted_tiles()
	BattleController.battlemap.highlight_attack_tiles(
		attack_tiles_highlight.origin_tile,
		attack_tiles_highlight
	)
