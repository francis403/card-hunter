extends MarginContainer
class_name PlayerMenu

func _setup_monster_battle_scenes(
	_sub_menu_item: MenuItemWithSubMenu
):
	var _monster_list: Array[GenericMonster] =\
		MonsterResourcesController._generic_monsters_list
	var _boss_monster_list: Array[GenericMonster] =\
		MonsterResourcesController._boss_monsters_list
	var _all_monsters_list: Array[GenericMonster] = []
	_all_monsters_list.append_array(_monster_list)
	_all_monsters_list.append_array(_boss_monster_list)
	#var _hunt_scenes: Array[PackedScene] = []
	## Name - PackedScene
	var _hunt_scenes: Array[Dictionary] = []
	for _monster: GenericMonster in _all_monsters_list:
		var _hunt_scene: BattleGenericScene = GameController.generate_battle_scene(
			_monster
		)
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


func _on_trigger_world_node_menu_item_ready(
	_menu_item: MenuItem
) -> void:
	_setup_world_node_trigger_items(_menu_item)


func _setup_world_node_trigger_items(
	_sub_menu_item: MenuItemWithSubMenu
) -> void:
	var _node_types: Array[Dictionary] = [
		{"display_name": "Treasure Node", "class": TreasureWorldNode},
		{"display_name": "Deforge Card Node", "class": DeforgeCardWorldNode},
	]
	
	var _menu_item_scene: PackedScene = preload(
			"res://ui/screen_components/_general_componets/menu/menu_item/_generic_menu_item/menu_item.tscn"
		)
	for _node_type_info: Dictionary in _node_types:
		var _menu_item: MenuItem = _menu_item_scene.instantiate()
		_menu_item._display_name = _node_type_info["display_name"]
		_menu_item.menu_item_clicked.connect(
			_on_world_node_type_selected.bind(_node_type_info["class"])
		)
		_sub_menu_item.add_child(_menu_item)


func _on_world_node_type_selected(_node_class: Variant) -> void:
	var _world_node: GenericWorldNode = load(_node_class.new().my_node_scene_path).instantiate()
	_world_node.world_node_complete.connect(_on_world_node_complete)
	self.add_child(_world_node)
	if _world_node:
		_world_node.on_node_click_event()
	else:
		push_warning("No node of type found: ", _node_class)


func _on_world_node_complete(_node: GenericWorldNode):
	if _node:
		_node.queue_free()
