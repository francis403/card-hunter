extends Node
## Tracks tutorial completion state and manages tutorial-specific behaviors

const TUTORIAL_MONSTER_ID: String = "crab_monster_small"

var should_show_tutorial: bool = false
var is_in_tutorial_battle: bool = false

func is_tutorial_completed() -> bool:
	return File.meta_progress.unlocked_content.has("tutorial_completed")

func mark_tutorial_completed() -> void:
	self.should_show_tutorial = false
	File.meta_progress.add_unlocked_content("tutorial_completed")
	File.change_meta_progress()

func generate_tutorial_battle():
	var monster: GenericMonster = MonsterResourcesController.get_monster(TUTORIAL_MONSTER_ID)
	if not monster:
		push_warning("Tutorial monster not found: %s" % TUTORIAL_MONSTER_ID)
		return 
	self.is_in_tutorial_battle = true
	var _hunt_scene: BattleGenericScene = GameController.generate_battle_scene(
		monster,
		false,
		null,
		true
	)
	get_tree().root.add_child(_hunt_scene)
	
