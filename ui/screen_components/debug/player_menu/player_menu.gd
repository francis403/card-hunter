extends MarginContainer
class_name PlayerMenu

func _setup_monster_battle_scenes(
	_sub_menu_item: MenuItemWithSubMenu
):
	var _generic_monster_list: Array[GenericMonster] =\
		MonsterResourcesController._generic_monsters_list
	#var _hunt_scenes: Array[PackedScene] = []
	## Name - PackedScene
	var _hunt_scenes: Array[Dictionary] = []
	for _monster: GenericMonster in _generic_monster_list:
		var _hunt_scene: BattleGenericScene =\
			load(BattleGenericScene.my_node_scene_path).instantiate()
		_hunt_scene.add_child(_monster)
		_monster.owner = _hunt_scene
		_hunt_scene.monsters.append(_monster)
		var _packed_scene: PackedScene = PackedScene.new()
		_packed_scene.pack(_hunt_scene)
		_hunt_scenes.append(
			{
				"scene": _packed_scene,
			 	"display_name": _monster.monster_id
			}
		)
		#_hunt_scenes.append(_packed_scene)
	_sub_menu_item.add_extra_menu_items_scenes(_hunt_scenes)

func _on_generate_battle_button_pressed() -> void:
	## TODO: show sub menu that has all monsters
	pass # Replace with function body.

func _on_deforge_card_button_pressed() -> void:
	if !get_parent() is DeforgeCardScreen:
		var scene: DeforgeCardScreen = Constants.deforge_card_screen_scene.instantiate()
		#get_tree().change_scene_to_packed(Constants.deforge_card_screen_scene)
		get_tree().root.add_child(scene)


func _on_forge_card_button_pressed() -> void:
	if !get_parent() is ForgeCardScreen:
		var scene: ForgeCardScreen = Constants.forge_card_screen_scene.instantiate()
		get_tree().root.add_child(scene)


func _on_expand_world_pressed() -> void:
	BattleSignals.boss_battle_complete.emit()


func _on_game_complete_pressed() -> void:
	BattleSignals.game_complete.emit()


func _on_boss_encounter_pressed() -> void:
	GameController.world_boss_monster_encountered.emit()


func _on_generate_new_world_pressed() -> void:
	BattleSignals.world_generation_triggered.emit()


func _on_generate_monster_hunt_ready() -> void:
	pass # Replace with function body.


func _on_generate_monster_hunt_menu_item_ready(
	_menu_item: MenuItem
) -> void:
	_setup_monster_battle_scenes(_menu_item)
