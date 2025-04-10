extends StateWithMovement

## If outside of attack range create some spiderwebs
class_name CreateSpiderWebsIfOutsideOfRange

@export var create_webs_range: int = 2
@export var maximum_distance_to_player: int = 2

func do_state_action():
	super.do_state_action()

	var distance_to_player = MovementUtils.distance_between_tiles(
		monster.next_move if monster.next_move else monster._tile,
		target._tile
	)

	# if we are in range do something else
	if distance_to_player < self.maximum_distance_to_player:
		BattlemapSignals.clear_attack_highlight_tiles.emit()
		## TODO: change to a different behaviour
		return

	## TODO: get random at range tile that doesn't have a spider web
	#BattleController.get_random_tile
