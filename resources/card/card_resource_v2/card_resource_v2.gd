extends Resource
class_name CardResourceV2

const BASIC_CARD_BACKGROUND_IMAGE: Texture2D = preload("res://assets/images/card/card_main_image/exclamation_mark.png")

signal card_finished_playing

enum CardRaririty {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY,
	UNIQUE
}

@export_group("Basic Card info")
@export var id: String
@export var title: String
@export var rarity: CardRaririty
@export_multiline var description: String
@export var stamina_cost: int = 0
@export var tag_array: Array[String] = []

@export_group("Card Effects")
@export var play_conditions: Array[Condition]
## Contains all the play_actions to be played. We might not need anything else
@export var play_actions: Array[CardEffect]
@export var special_effects: Array[SpecialCardEffectResource]

@export_group("Card Audio & animation")
@export var _on_click_sound: AudioStream = load("res://assets/sound/sound_effects/button_clicks/click3.ogg")
@export var audio_stream: AudioStream

@export_group("Card Visuals")
@export var card_image: Texture2D = BASIC_CARD_BACKGROUND_IMAGE

## Used for the Tree connections
## Head of the tree
var start_card_module: CardModule
## All the nodes in the tree
var modules_dictionary: Dictionary = {
	## module_id : Reference
}
var module_has_module_connected_to_it_dict: Dictionary = {
	## module_id: the module id has something connected to it
}

var _revertable_play_actions: Array[CardEffect] = []

## Was this card_resource_forged by the user
var is_forged: bool = false

func _init() -> void:
	start_card_module = CardModule.new()
	start_card_module.id = "start_module"
	start_card_module.title = "Start Module"
	start_card_module.module_type = "START"
	start_card_module.output_links = []
	start_card_module.next_modules = []

## Modules might have the same id, but never the same connection_id.
## Example: Target Self -> Move -> Target Self -> Heal has two "Target Self" modules
## with the same id but distinct connection_ids, so we must track visits by connection_id.
func rebuild_play_actions_from_tree(head: CardModule) -> void:
	play_actions.clear()
	start_card_module = head
	if head.connection_id.is_empty():
		head.connection_id = "%s_%d" % [head.id, head.get_instance_id()]
	var visited: Dictionary = {}
	visited[head.connection_id] = true
	var queue: Array[CardModule] = head.next_modules.duplicate()
	while not queue.is_empty():
		var module: CardModule = queue.pop_front()
		if module.connection_id.is_empty():
			module.connection_id = "%s_%d" % [module.id, module.get_instance_id()]
		if visited.has(module.connection_id):
			continue
		visited[module.connection_id] = true
		if module is CardEffect:
			play_actions.append(module)
			module.output_links.clear()
			for next_mod: CardModule in module.next_modules:
				if next_mod.connection_id.is_empty():
					next_mod.connection_id = "%s_%d" % [next_mod.id, next_mod.get_instance_id()]
				var link: CardModuleOutputLink = CardModuleOutputLink.new()
				link.connection_id = next_mod.connection_id
				module.output_links.append(link)
		for next_module: CardModule in module.next_modules:
			if not visited.has(next_module.connection_id):
				queue.append(next_module)

func _generate_card_modules_tree():
	# Clear instance state for idempotent rebuild (safe to call on duplicated resources)
	modules_dictionary.clear()
	module_has_module_connected_to_it_dict.clear()
	start_card_module.next_modules.clear()

	## Generate HashMap with card module connection_id's
	for card_module in play_actions:
		modules_dictionary[card_module.connection_id] = card_module
	## Generate connections between tree
	for card_module: CardEffect in play_actions:
		if not card_module.output_links:
			continue
		# Only populate if not already built (shared refs from original are still valid)
		if card_module.next_modules.is_empty():
			for output_link: CardModuleOutputLink in card_module.output_links:
				if not modules_dictionary.has(output_link.connection_id):
					push_warning(
						"_generate_card_modules_tree: unknown connection_id '%s' on module '%s' — skipping link"
						% [output_link.connection_id, card_module.id]
					)
					continue
				card_module.next_modules.append(
					modules_dictionary[output_link.connection_id]
				)
		for output_link: CardModuleOutputLink in card_module.output_links:
			module_has_module_connected_to_it_dict[output_link.connection_id] = true
	## Connect to the start node any module that has nothing connected to it
	for card_module: CardEffect in play_actions:
		if not module_has_module_connected_to_it_dict.has(card_module.connection_id):
			start_card_module.next_modules.append(card_module)
	

func play_card() -> bool:
	if not _is_card_playable():
		return false
	GeneralUtils.debug_log(
		"Starting to play card %s" % [self.id],
		GameController.debug_mode_enabled
	)
	for condition in play_conditions:
		if not condition.is_condition_meet():
			GeneralUtils.debug_log(
				"Card %s not playable due to condition" % [self.id],
				GameController.debug_mode_enabled
			)
			return false
	var response: CardEffectResponse = await _depth_first_effect_player()
	
	if not response.should_rollback():
		self._after_card_is_played()
		_revertable_play_actions.clear()
	GeneralUtils.debug_log(
		"Finished playing card %s." % [self.id],
		GameController.debug_mode_enabled
	)
	return true
	
## Traverses the card module tree starting from start_card_module in depth-first order,
## processing each CardEffect and passing response data between modules via _previous_card_module_resp.
func _depth_first_effect_player() -> CardEffectResponse:
	var response: CardEffectResponse = CardEffectResponse.new()
	response.set_ok()

	# Start from the start_card_module's children
	if not start_card_module or start_card_module.next_modules.is_empty():
		self._generate_card_modules_tree()
	if not start_card_module or start_card_module.next_modules.is_empty():
		push_warning("Graph has not been built!")
		return response

	# Process each root-level module
	for module in start_card_module.next_modules:
		if module is CardEffect:
			response = await _process_module_recursive(module, null, null)
			if response.should_rollback():
				return response

	return response


func _process_module_recursive(
	module: CardEffect,
	previous_response: CardEffectResponse,
	previous_data: CardEffectData
) -> CardEffectResponse:
	# Set up module with data from previous module
	module._previous_card_module_resp = previous_response
	module.card_effect_data = previous_data

	GeneralUtils.debug_log(
		"- Processing module %s (depth-first)" % [module.id],
		GameController.debug_mode_enabled
	)

	# Process this effect
	var response: CardEffectResponse = await module.process_card_effect()

	GeneralUtils.debug_log(
		"- Module %s got response %s with tile %s" % [module.id, response.response, response.tile_selected],
		GameController.debug_mode_enabled
	)


	if not response.is_ok():
		return response

	# Track for potential rollback
	_revertable_play_actions.append(module)

	# Prepare data for children
	var next_data: CardEffectData = module.card_effect_data if module.update_next_card_effect_data else previous_data

	# Recursively process children
	for child_module in module.next_modules:
		if child_module is CardEffect:
			response = await _process_module_recursive(child_module, response, next_data)
			if response.should_rollback():
				return response

	return response

## When the card is canceled midway through, 
## we need to revert all the effects that have been played
## TO_THINK: this seems to be called for every card on the deck on init. 
func revert_all_played_card_effects() -> bool:
	while not _revertable_play_actions.is_empty():
		var action: CardEffect = _revertable_play_actions.pop_front()
		action.revert_card_effect()
	return true
	
func _is_card_playable() -> bool:
	if not _is_player_stamina_enough():
		return false
	for condition in play_conditions:
		if not condition.is_condition_meet():
			return false
	return true

func _is_player_stamina_enough() -> bool:
	var player: PlayerCharacter = BattleController.get_player()
	if not player:
		return false
	return player._stamina >= self.stamina_cost

func _after_card_is_played():
	if self.audio_stream:
		BattlemapSignals.play_card_stream.emit(self.audio_stream)
	_apply_stamina_cost(self.stamina_cost)
	card_finished_playing.emit()
	BattlemapSignals.card_has_been_played.emit(self)

func _apply_stamina_cost(_stamina_cost: int):
	var player: PlayerPiece = BattleController.get_player()
	if not player:
		return
	player._stamina -= _stamina_cost
	BattlemapSignals.player_stamina_changed.emit(player._stamina)

func subscribe_to_special_effects(
	card: Card,
	container_node: Node
):
	if special_effects.is_empty():
		return
	for special_effect in special_effects:
		var controller_instance: BaseSpecialEffect = special_effect.controller.instantiate()
		controller_instance._init_special_effect(
			card,
			special_effect
		)
		controller_instance.card = card
		container_node.add_child(controller_instance)

func add_card_module(_card_module: CardModule) -> void:
	if not _card_module:
		push_error(add_card_module, ": Error: _card_module is null")
		return
	_append_card_module(_card_module)
	
func remove_card_module(_card_module: CardModule):
	if not _card_module:
		return
	if _card_module is CardEffect:
		remove_module_from_array(_card_module, play_actions)
	elif _card_module is SpecialCardEffectResource:
		remove_module_from_array(_card_module, special_effects)
	elif _card_module is SpecialCardEffectResource:
		remove_module_from_array(_card_module, play_conditions)

func remove_play_card_effect(card_effect: CardEffect):
	var index: int = -1
	var i: int = 0
	for play_action in play_actions:
		if play_action.equals(card_effect):
			index = i
			break
		i += 1
	if index < 0:
		return
	play_actions.remove_at(index)

func remove_module_from_array(
	_card_module: CardModule,
	_array: Array
):
	var index: int = -1
	var i: int = 0
	for module in _array:
		if _card_module.equals(module):
			index = i
			break
		i += 1
	if index < 0:
		return
	_array.remove_at(index)

func get_card_modules() -> Array[CardModule]:
	var result: Array[CardModule] = []
	for play_action in self.play_actions:
		result.append(play_action)
	for special_card_effect in self.special_effects:
		result.append(special_card_effect)
	for condition in self.play_conditions:
		result.append(condition)
	return result

func from_dictionary(dict: Dictionary):
	self.id = dict["id"]
	self.title = dict["title"]
	self.rarity = dict["rarity"]
	self.description = dict["description"]
	self.stamina_cost = dict["stamina_cost"]
	_read_card_modules_from_dictionary(dict["play_actions"])
	_read_card_modules_from_dictionary(dict["special_effects"])
	_read_card_modules_from_dictionary(dict["play_conditions"])
	# Restore output_links now that all modules have their connection_ids set,
	# then rebuild the execution tree.
	_rebuild_output_links_from_dictionary(dict["play_actions"])
	_generate_card_modules_tree()

## Rebuilds output_links on each loaded play_action module using the
## connection_id strings that were saved alongside each module.
## Must run after all modules are appended so the connection_id map is complete.
func _rebuild_output_links_from_dictionary(modules_dict: Dictionary) -> void:
	if modules_dict.is_empty():
		return
	# Old save files don't have output_link_ids — fall back to flat connection.
	if not modules_dict.values()[0].has("output_link_ids"):
		return
	var conn_id_map: Dictionary = {}
	for module in play_actions:
		if not module.connection_id.is_empty():
			conn_id_map[module.connection_id] = module
	for module_data: Dictionary in modules_dict.values():
		var conn_id: String = module_data.get("connection_id", "")
		if conn_id.is_empty() or not conn_id_map.has(conn_id):
			continue
		var module: CardModule = conn_id_map[conn_id]
		for link_conn_id: String in module_data.get("output_link_ids", []):
			var link := CardModuleOutputLink.new()
			link.connection_id = link_conn_id
			module.output_links.append(link)

func _read_card_modules_from_dictionary(dict: Dictionary):
	for key in dict.keys():
		var module_data: Dictionary = dict[key]
		# New saves key by connection_id; the actual module id is in the value.
		# Old saves key by id directly, so fall back to the key when id is absent.
		var module_id: String = module_data.get("id", key)
		var _card_module: CardModule = CardModuleController.get_card_module(module_id)
		if _card_module:
			# Duplicate so we don't mutate the shared canonical resource stored
			# in CardModuleController — each forged card needs its own copy with
			# its own connection_id and output_links.
			_card_module = _card_module.duplicate() as CardModule
		else:
			# Not a standard module — instantiate the correct subclass via scene_path
			# so the result passes `is CardEffect` / `is SpecialCardEffectResource` checks.
			var scene_path: String = module_data.get("scene_path", "")
			if not scene_path.is_empty() and ResourceLoader.exists(scene_path):
				_card_module = load(scene_path).new()
			else:
				_card_module = CardModule.new()
		# Apply all saved properties (id, title, stamina_cost, connection_id, …).
		_card_module.from_dictionary(module_data)
		# output_links are rebuilt by _rebuild_output_links_from_dictionary once all
		# modules are loaded; clear stale links from the duplicated canonical resource.
		_card_module.output_links.clear()
		_card_module.next_modules.clear()
		_append_card_module(_card_module)
		
func _append_card_module(_card_module: CardModule) -> void:
	if not _card_module:
		return
	if _card_module is CardEffect:
		self.play_actions.append(_card_module)
	elif _card_module is SpecialCardEffectResource:
		self.special_effects.append(_card_module)
	elif _card_module is Condition:
		self.play_conditions.append(_card_module)

func to_dictionary() -> Dictionary:
	var result: Dictionary = {}
	result["id"] = self.id
	result["title"] = self.title
	result["rarity"] = self.rarity
	result["description"] = self.description
	result["stamina_cost"] = self.stamina_cost
	result["play_actions"] = _card_modules_to_dictionary(play_actions)
	result["special_effects"] = _card_modules_to_dictionary(special_effects)
	result["play_conditions"] = _card_modules_to_dictionary(play_conditions)
	return result

func _card_modules_to_dictionary(
	card_module_array: Array
) -> Dictionary:
	var result: Dictionary = {}
	for card_module: CardModule in card_module_array:
		# Key by connection_id when available so that two modules sharing the same
		# id (e.g. two "Target Self" nodes in one chain) are stored separately.
		# Fall back to id for modules that have no connection_id (e.g. inventory items).
		var key: String = card_module.connection_id \
			if not card_module.connection_id.is_empty() \
			else card_module.id
		result[key] = card_module.to_dictionary()
	return result
	
## Returns a duplicate copy of this CardResourceV2
func dup() -> CardResourceV2:
	var result: CardResourceV2 = self.duplicate()

	# Deep copy arrays to avoid shared references
	result.tag_array = self.tag_array.duplicate()
	result.play_conditions = self.play_conditions.duplicate()
	result.play_actions = self.play_actions.duplicate()
	result.special_effects = self.special_effects.duplicate()

	# Copy non-exported variables (not handled by duplicate())
	result.is_forged = self.is_forged

	# Rebuild the module tree from play_actions (start_card_module, modules_dictionary,
	# and module_has_module_connected_to_it_dict are non-exported and lost by duplicate())
	result._generate_card_modules_tree()

	return result
	
