extends GenericWorldNode
class_name MonsterHuntWorldNode

const REVEALED_NODE_SPRITE = preload("res://assets/images/nodes/revealed_node.png")
const UNKOWN_NODE_SPRITE = preload("res://assets/images/nodes/question_mark_node-transparent.png")
# Boss nodes reuse the event icon to distinguish them visually on the map
const BOSS_NODE_SPRITE = preload("res://assets/images/nodes/event_node_icon.png")
const BATTLE_GENERIC_SCENE = preload("res://scenes/battle_scenes/battle_generic_scene/battle_generic_scene.tscn")

const MONSTERS_DICTIONARY_FIELD: String = "monsters"

@export_category("Monsters in node")
@export var monsters_in_node: Array[GenericMonster] = []

## -------- OVERRIDE IMPORTANT FUNCTIONS --------
func set_world_scene():
	my_node_scene_path = "res://scenes/game_objects/world/world_node/monster_hunt_world_node/monster_hunt_world_node.tscn"

func reveal_node_effect():
	if _is_boss_node:
		# Use a distinct sprite so the final boss node is easy to spot
		world_node_sprite.texture = BOSS_NODE_SPRITE
	else:
		show_monster()
		world_node_sprite.texture = REVEALED_NODE_SPRITE

func _is_click_event_processable() -> bool:
	# Boss node is always clickable once (no monster data required)
	if _is_boss_node:
		return not _is_already_clicked
	return monsters_in_node.size() > 0

func on_node_click_event():
	if not _is_click_event_processable():
		return

	# ── Boss node: delegate entirely to the existing boss-event pipeline ──
	if _is_boss_node:
		self._is_already_clicked = true
		# Emit the same signal the day-counter used to emit when it hit 0,
		# so MainWorldScreen._ on_world_boss_monster_encountered_signal fires.
		GameController.world_boss_monster_encountered.emit()
		return

	# ── Regular monster node ──
	if !GameController.is_showing_battle_scene:
		var battle_scene: BattleGenericScene = GameController.generate_battle_scene(
			monsters_in_node[0].duplicate(),
			false,
			self
		)
		self._is_already_clicked = true
		get_tree().root.add_child(battle_scene)
	else:
		push_error(on_node_click_event, ": Error node clicked while hunt is started!")

func after_node_is_ready():
	if _is_boss_node:
		# Boss sprite is only shown once revealed
		world_node_sprite.texture = UNKOWN_NODE_SPRITE if not is_revealed else BOSS_NODE_SPRITE
	elif self.is_revealed:
		world_node_sprite.texture = REVEALED_NODE_SPRITE
	else:
		world_node_sprite.texture = UNKOWN_NODE_SPRITE
		
func after_world_node_completed_successfully():
	super.after_world_node_completed_successfully()
	if not _is_boss_node:
		clear_monsters()
		
## -------- FINISH OVERRIDING IMPORTANT FUNCTIONS --------
	
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