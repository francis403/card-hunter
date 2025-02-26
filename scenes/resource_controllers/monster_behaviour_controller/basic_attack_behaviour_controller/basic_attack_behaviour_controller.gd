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
	
	print("TODO: do specific monster behaviour")
	
	super.after_behaviour_is_played(
		behaviour_resource,
		behaviour_info_array
	)
