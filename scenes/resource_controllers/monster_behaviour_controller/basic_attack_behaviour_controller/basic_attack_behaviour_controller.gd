extends MonsterBehaviourController
class_name  BasicAttackBehaviourController


func play_monster_behaviour(
	behaviour_resource: MonsterBehaviourResource,
	behaviour_info_array: EventCategoryDictionary = null
):
	super.play_monster_behaviour(
		behaviour_resource,
		behaviour_info_array
	)
	
	var monster: MonsterPiece = BattleController.get_monster()
	
	var source_tile: Tile = monster.next_move
	if not source_tile:
		source_tile = monster._tile
	
	BattlemapSignals.deal_damage_to_attacked_squares.emit(
		monster._strength
	)
	
	# clean old attacked tiles
	BattlemapSignals.clear_attack_highlight_tiles.emit()
	
	BattlemapSignals.highlight_attack_tiles.emit(
		source_tile,
		1,
		Constants.AreaType.RADIUS
	)
	
	super.after_behaviour_is_played(
		behaviour_resource,
		behaviour_info_array
	)
