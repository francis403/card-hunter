extends GenericWorldNode
class_name MonsterHuntWorldNode

const REVEALED_NODE_SPRITE = preload("res://assets/images/nodes/revealed_node.png")
const UNKOWN_NODE_SPRITE = preload("res://assets/images/nodes/question_mark_node-transparent.png")
const BATTLE_GENERIC_SCENE = preload("res://scenes/battle_scenes/battle_generic_scene/battle_generic_scene.tscn")

const MONSTERS_DICTIONARY_FIELD: String = "monsters"

@export_category("Monsters in node")
@export var monsters_in_node: Array[GenericMonster] = []

## -------- OVERRIDE IMNPORTANT FUNCTIONS --------
func set_world_scene():
	my_node_scene_path = "res://scenes/game_objects/world/world_node/monster_hunt_world_node/monster_hunt_world_node.tscn"

func reveal_node_effect():
	show_monster()
	world_node_sprite.texture = REVEALED_NODE_SPRITE

func _is_click_event_processable() -> bool:
	return monsters_in_node.size() > 0

func on_node_click_event():
	if not _is_click_event_processable():
		return
	if !GameController.is_showing_battle_scene:
		var battle_scene: BattleGenericScene = generate_battle_scene()
		self._is_already_clicked = true
		get_tree().root.add_child(battle_scene)
	else:
		push_error(on_node_click_event, ": Error node clicked while hunt is started!")

func after_node_is_ready():
	if self.is_revealed:
		world_node_sprite.texture = REVEALED_NODE_SPRITE
	else:
		world_node_sprite.texture = UNKOWN_NODE_SPRITE
		
func after_world_node_completed_successfully():
	super.after_world_node_completed_successfully()
	clear_monsters()
	
## -------- FINISH OVERRIDING IMNPORTANT FUNCTIONS --------
	
func clear_monsters():
	self.monster_texture_rect.visible = false
	self.monsters_in_node.clear()

func generate_battle_scene(
	_is_boss_battle: bool = false
) -> BattleGenericScene:
	var battle_scene: BattleGenericScene = null
	if on_click_scene:
		battle_scene = on_click_scene.instantiate()
	else:
		battle_scene = BATTLE_GENERIC_SCENE.instantiate()
	battle_scene.is_boss_battle = _is_boss_battle
	battle_scene.monsters.clear()
	battle_scene.set_world_node(self)
	for monster in monsters_in_node:
		battle_scene.monsters.append(monster.duplicate())
	return battle_scene

func show_monster():
	if monsters_in_node.size() > 0:
		monster_texture_rect.texture = monsters_in_node[0].get_texture()
		monster_texture_rect.visible = true

func convert_node_to_dictionary() -> Dictionary:
	var result: Dictionary = super.convert_node_to_dictionary()
	result[MONSTERS_DICTIONARY_FIELD] = {}
	var i: int = 0
	for child_monster in self.monsters_in_node:
		if not child_monster:
			continue
		result[MONSTERS_DICTIONARY_FIELD][i] = child_monster.monster_id
		i += 1
	return result
	
func load_node_from_dictionary(node_state: Dictionary):
	super.load_node_from_dictionary(node_state)
	self.monsters_in_node = []
	for monster_id in node_state[MONSTERS_DICTIONARY_FIELD].keys():
		var actual_monster_id: String = node_state[MONSTERS_DICTIONARY_FIELD][monster_id]
		var monster: GenericMonster = MonsterResourcesController.get_specific_monster(actual_monster_id)
		if monster == null:
			push_error(load_node_from_dictionary, ": ERROR while loading monster ", monster_id)
			continue
		var monster_scene: PackedScene = load(monster.scene_file_path)
		self.monsters_in_node.append(
			monster_scene.instantiate().duplicate()
		)

func copy_properties_into_node(node: GenericWorldNode):
	super.copy_properties_into_node(node)
	for child_monster in self.monsters_in_node:
		node.monsters_in_node.append(child_monster)
