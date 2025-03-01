extends ResourceController
class_name MonsterBehaviourController

signal monster_behaviour_finished

func _ready() -> void:
	BattlemapSignals.battlemap_generated.connect(_on_battlemap_generated_signal)
	battlemap = BattleController.battlemap

func _on_battlemap_generated_signal(map: Battlemap):
	print(_on_battlemap_generated_signal)
	self.battlemap = map

func preview_monster_behaviour() -> void:
	pass


func play_monster_behaviour(
	behaviour_resource: MonsterBehaviourResource,
	card_categories: EventCategoryDictionary = null
):
	pass

func after_behaviour_is_played(
	behaviour_resource: MonsterBehaviourResource,
	card_categories: EventCategoryDictionary = null
):
	monster_behaviour_finished.emit()
		
