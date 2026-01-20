extends EventButtonAction
class_name OpenBattleEventButton

@export var _monster_id: String
@export var _is_boss_battle: bool = false

func execute(
	_event_sub_screen: EventSubScreen
) -> bool:
	var _monster: GenericMonster = MonsterResourcesController.get_monster(_monster_id)
	if not _monster:
		push_warning("No monster with %s found!" % _monster_id)
		return true
	var _hunt_scene = GameController.generate_battle_scene(
		_monster,
		_is_boss_battle
	)
	_event_sub_screen.get_tree().root.add_child(_hunt_scene)
	return true
