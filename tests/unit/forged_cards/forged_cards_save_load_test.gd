extends Node

## Tests for forged card save/load behaviour.
##
## Bug 1 (forge_card_screen.gd): File.change_progress() was not called after
##   forging, so the card and consumed modules were lost on crash/quit.
##   Tests verify that after the forge operation the in-memory state is correct
##   and that PlayerController._forged_cards holds the data that
##   File.change_progress() will flush to disk.
##
## Bug 2 (progress.gd): _load_player_forged_cards always reset quantity to 1,
##   ignoring the value stored in the save dict.
##   Tests verify that the saved quantity is preserved after a load round-trip.


func _ready() -> void:
	# --- Bug 2: quantity preserved on load ---
	_run_test(true, _test_load_preserves_quantity_greater_than_one(),  "load_preserves_quantity_greater_than_one")
	_run_test(true, _test_load_quantity_one_stays_one(),               "load_quantity_one_stays_one")
	_run_test(true, _test_load_missing_quantity_key_defaults_to_one(), "load_missing_quantity_key_defaults_to_one")

	# --- Bug 1: in-memory state after forge ---
	_run_test(true, _test_forge_registers_card_in_forged_dict(),       "forge_registers_card_in_forged_dict")
	_run_test(true, _test_forge_card_title_survives_serialization(),   "forge_card_title_survives_serialization")
	_run_test(true, _test_forge_consumed_module_is_removed(),          "forge_consumed_module_is_removed")

	# --- Module round-trip ---
	_run_test(true, _test_load_preserves_play_action_modules_and_order(), "load_preserves_play_action_modules_and_order")

	# --- scene_path correctness for CardEffect subclasses ---
	_run_test(true, _test_target_input_scene_path_is_own_class(),           "target_input_scene_path_is_own_class")
	_run_test(true, _test_target_input_reloads_as_correct_class(),          "target_input_reloads_as_correct_class")
	_run_test(true, _test_target_input_area_input_type_preserved_on_load(), "target_input_area_input_type_preserved_on_load")
	_run_test(true, _test_status_change_effect_scene_path_is_own_class(),   "status_change_effect_scene_path_is_own_class")
	_run_test(true, _test_move_other_effect_scene_path_is_own_class(),      "move_other_effect_scene_path_is_own_class")
	_run_test(true, _test_status_change_reloads_as_correct_class(),         "status_change_reloads_as_correct_class")

	# --- tile_highlight_config round-trip ---
	_run_test(true, _test_target_input_tile_highlight_config_preserved_on_load(), "target_input_tile_highlight_config_preserved_on_load")
	_run_test(true, _test_target_input_null_config_survives_round_trip(),         "target_input_null_config_survives_round_trip")
	_run_test(true, _test_move_card_effect_tile_highlight_config_preserved(),     "move_card_effect_tile_highlight_config_preserved")
	_run_test(true, _test_card_effect_with_user_input_config_preserved(),         "card_effect_with_user_input_config_preserved")
	_run_test(true, _test_move_other_highlight_config_preserved(),                "move_other_highlight_config_preserved")

	get_tree().quit()


func _run_test(expected: bool, actual: bool, test_name: String) -> void:
	if expected != actual:
		push_error("FAIL: " + test_name)
	else:
		print("PASS: " + test_name)


# Returns a valid dict that CardResourceV2.from_dictionary() can consume,
# with an explicit quantity field.
func _make_card_dict(id: String, quantity: int) -> Dictionary:
	var card := CardResourceV2.new()
	card.id = id
	card.title = "Test Card " + id
	var dict := card.to_dictionary()
	dict["quantity"] = quantity
	return dict


# ─────────────────────────────────────────────────────────────────────────────
# Bug 2 tests
# ─────────────────────────────────────────────────────────────────────────────

## A card saved with quantity=3 should load back with quantity=3.
func _test_load_preserves_quantity_greater_than_one() -> bool:
	var snapshot := PlayerController._forged_cards.duplicate(true)

	var dict := {"test_qty_3": _make_card_dict("test_qty_3", 3)}
	File.progress._load_player_forged_cards(dict)
	var actual: int = PlayerController._forged_cards.get("test_qty_3", {}).get("quantity", -1)

	PlayerController._forged_cards = snapshot
	return actual == 3


## A card saved with quantity=1 should load back with quantity=1.
func _test_load_quantity_one_stays_one() -> bool:
	var snapshot := PlayerController._forged_cards.duplicate(true)

	var dict := {"test_qty_1": _make_card_dict("test_qty_1", 1)}
	File.progress._load_player_forged_cards(dict)
	var actual: int = PlayerController._forged_cards.get("test_qty_1", {}).get("quantity", -1)

	PlayerController._forged_cards = snapshot
	return actual == 1


## An older save dict that has no quantity key should default to 1 on load.
func _test_load_missing_quantity_key_defaults_to_one() -> bool:
	var snapshot := PlayerController._forged_cards.duplicate(true)

	var card_dict := _make_card_dict("test_qty_missing", 1)
	card_dict.erase("quantity")
	var dict := {"test_qty_missing": card_dict}
	File.progress._load_player_forged_cards(dict)
	var actual: int = PlayerController._forged_cards.get("test_qty_missing", {}).get("quantity", -1)

	PlayerController._forged_cards = snapshot
	return actual == 1


# ─────────────────────────────────────────────────────────────────────────────
# Bug 1 tests
# ─────────────────────────────────────────────────────────────────────────────

## After calling add_forged_card the card id must be present in _forged_cards.
## This is the data that File.change_progress() reads and writes to disk.
func _test_forge_registers_card_in_forged_dict() -> bool:
	var snapshot := PlayerController._forged_cards.duplicate(true)

	var card := CardResourceV2.new()
	card.id = "test_forge_register_001"
	card.title = "Forge Register Test"
	card.is_forged = true
	PlayerController.add_forged_card(card)

	var found: bool = PlayerController._forged_cards.has("test_forge_register_001")

	PlayerController.remove_forged_card("test_forge_register_001")
	PlayerController._forged_cards = snapshot
	return found


## The title stored in _forged_cards must match the card that was forged,
## ensuring the serialised data that reaches the save file is correct.
func _test_forge_card_title_survives_serialization() -> bool:
	var snapshot := PlayerController._forged_cards.duplicate(true)

	var card := CardResourceV2.new()
	card.id = "test_forge_title_001"
	card.title = "My Custom Blade"
	card.is_forged = true
	PlayerController.add_forged_card(card)

	var stored_title: String = PlayerController._forged_cards.get("test_forge_title_001", {}).get("title", "")

	PlayerController.remove_forged_card("test_forge_title_001")
	PlayerController._forged_cards = snapshot
	return stored_title == "My Custom Blade"



## After a full save/load round-trip (add_forged_card → from_dictionary),
## play_actions must contain the same modules in the same order.
## This covers the serialisation path through to_dictionary/_card_modules_to_dictionary
## and the deserialisation path through _read_card_modules_from_dictionary.
func _test_load_preserves_play_action_modules_and_order() -> bool:
	var snapshot := PlayerController._forged_cards.duplicate(true)

	# Build a card with 3 ordered play_action modules.
	# Each needs a unique connection_id so the dict keys don't collide.
	var card := CardResourceV2.new()
	card.id = "test_module_order_001"
	card.title = "Module Order Test"
	card.is_forged = true

	var module_ids := ["mod_alpha", "mod_beta", "mod_gamma"]
	for mid in module_ids:
		var effect := CardEffect.new()
		effect.id = mid
		effect.title = "Module " + mid
		effect.connection_id = "conn_" + mid
		card.play_actions.append(effect)
	card._generate_card_modules_tree()

	# Serialize into _forged_cards (same path as PlayerController.add_forged_card).
	PlayerController.add_forged_card(card)

	# Deserialize from the stored dict (same path as PlayerDeck._load).
	var loaded := CardResourceV2.new()
	loaded.from_dictionary(PlayerController._forged_cards["test_module_order_001"])

	# Verify count.
	var count_ok := loaded.play_actions.size() == module_ids.size()

	# Verify order: each position must match the original id.
	var order_ok := true
	if count_ok:
		for i in module_ids.size():
			if loaded.play_actions[i].id != module_ids[i]:
				order_ok = false
				break

	PlayerController.remove_forged_card("test_module_order_001")
	PlayerController._forged_cards = snapshot
	return count_ok and order_ok


# ─────────────────────────────────────────────────────────────────────────────
# TargetInputCardEffect scene_path tests
#
# Root cause: TargetInputCardEffect did not override _get_my_node_scene_path(),
# so it inherited CardEffect's version which returns the base-class .gd path.
# _load_player_card_modules uses scene_path directly (no controller id-lookup),
# so after a save/load the inventory module became a plain CardEffect, losing
# area_input_type and the tile-selection behaviour.
# ─────────────────────────────────────────────────────────────────────────────

## _get_my_node_scene_path() must return the TargetInputCardEffect path, not the
## base CardEffect path. This is what gets written into save data as "scene_path".
func _test_target_input_scene_path_is_own_class() -> bool:
	var effect := TargetInputCardEffect.new()
	var path: String = effect._get_my_node_scene_path()
	return path.ends_with("target_input_card_effect.gd")


## Simulates _load_player_card_modules: deserialise a TargetInputCardEffect from
## its saved dict using the scene_path key (the exact path used in progress.gd).
## The loaded instance must be a TargetInputCardEffect, not a plain CardEffect.
func _test_target_input_reloads_as_correct_class() -> bool:
	var original := TargetInputCardEffect.new()
	original.id = "target_input_other_1"
	original.title = "Target Other"
	original.area_input_type = "OTHER"
	var dict: Dictionary = original.to_dictionary()

	# Mirror of _load_player_card_modules logic in progress.gd
	var loaded: CardModule = CardEffect.new()
	if dict.has("scene_path"):
		var res = ResourceLoader.load(dict["scene_path"])
		if res:
			loaded = res.new()
	loaded.from_dictionary(dict)

	return loaded is TargetInputCardEffect


## After the round-trip through scene_path, area_input_type must still be "OTHER".
func _test_target_input_area_input_type_preserved_on_load() -> bool:
	var original := TargetInputCardEffect.new()
	original.id = "target_input_other_1"
	original.area_input_type = "OTHER"
	var dict: Dictionary = original.to_dictionary()

	var res = ResourceLoader.load(dict.get("scene_path", ""))
	if not res:
		return false
	var loaded: CardModule = res.new()
	loaded.from_dictionary(dict)

	if not loaded is TargetInputCardEffect:
		return false
	return (loaded as TargetInputCardEffect).area_input_type == "OTHER"


## StatusChangeCardEffectV2 must report its own script path, not the base CardEffect path.
func _test_status_change_effect_scene_path_is_own_class() -> bool:
	var effect := StatusChangeCardEffectV2.new()
	var path: String = effect._get_my_node_scene_path()
	return path.ends_with("status_change_card_effect_v2.gd")


## MoveOtherCardEffect must report its own script path.
func _test_move_other_effect_scene_path_is_own_class() -> bool:
	var effect := MoveOtherCardEffect.new()
	var path: String = effect._get_my_node_scene_path()
	return path.ends_with("move_other_card_effect.gd")


## Simulates loading a StatusChangeCardEffectV2 from a save dict via scene_path
## (the path taken in _load_player_card_modules for non-controller modules).
## The loaded instance must be a StatusChangeCardEffectV2, not a plain CardEffect.
func _test_status_change_reloads_as_correct_class() -> bool:
	var original := StatusChangeCardEffectV2.new()
	original.id = "status_heal_50"
	var dict: Dictionary = original.to_dictionary()

	var loaded: CardModule = CardEffect.new()
	var scene_path: String = dict.get("scene_path", "")
	if not scene_path.is_empty() and ResourceLoader.exists(scene_path):
		loaded = ResourceLoader.load(scene_path).new()
	loaded.from_dictionary(dict)

	return loaded is StatusChangeCardEffectV2


## A TargetInputCardEffect with a TileHighlightConfig must preserve its config
## fields (_range, area_type, ignore_corners) after a full to/from_dictionary round-trip.
func _test_target_input_tile_highlight_config_preserved_on_load() -> bool:
	var original := TargetInputCardEffect.new()
	original.id = "target_input_arrow_test"
	original.area_input_type = "OTHER"
	original.tile_highlight_config = TileHighlightConfig.new()
	original.tile_highlight_config._range = 3
	original.tile_highlight_config.area_type = 4
	original.tile_highlight_config.ignore_corners = true
	var dict: Dictionary = original.to_dictionary()

	var res = ResourceLoader.load(dict.get("scene_path", ""))
	if not res:
		return false
	var loaded: TargetInputCardEffect = res.new() as TargetInputCardEffect
	loaded.from_dictionary(dict)

	if not loaded.tile_highlight_config:
		return false
	return (
		loaded.tile_highlight_config._range == 3
		and loaded.tile_highlight_config.area_type == 4
		and loaded.tile_highlight_config.ignore_corners == true
	)


## A TargetInputCardEffect with no TileHighlightConfig (null) must not crash
## during serialization and must still have null after from_dictionary.
func _test_target_input_null_config_survives_round_trip() -> bool:
	var original := TargetInputCardEffect.new()
	original.id = "target_input_no_config"
	original.area_input_type = "SELF"
	# tile_highlight_config intentionally left null
	var dict: Dictionary = original.to_dictionary()

	var res = ResourceLoader.load(dict.get("scene_path", ""))
	if not res:
		return false
	var loaded: TargetInputCardEffect = res.new() as TargetInputCardEffect
	loaded.from_dictionary(dict)

	return loaded.tile_highlight_config == null


## MoveCardEffect.tile_highlight_config must survive a to/from_dictionary round-trip.
func _test_move_card_effect_tile_highlight_config_preserved() -> bool:
	var original := MoveCardEffect.new()
	original.id = "move_card_test"
	original.tile_highlight_config = TileHighlightConfig.new()
	original.tile_highlight_config._range = 2
	original.tile_highlight_config.ignore_corners = true
	var dict: Dictionary = original.to_dictionary()

	var res = ResourceLoader.load(dict.get("scene_path", ""))
	if not res:
		return false
	var loaded: MoveCardEffect = res.new() as MoveCardEffect
	loaded.from_dictionary(dict)

	if not loaded.tile_highlight_config:
		return false
	return loaded.tile_highlight_config._range == 2 and loaded.tile_highlight_config.ignore_corners == true


## CardEffectWithUserInput.tile_highlight_config and center_piece must survive round-trip.
func _test_card_effect_with_user_input_config_preserved() -> bool:
	var original := MoveSelfCardEffect.new()
	original.id = "move_self_test"
	original.tile_highlight_config = TileHighlightConfig.new()
	original.tile_highlight_config._range = 4
	original.center_piece = Constants.TargetType.MONSTER
	var dict: Dictionary = original.to_dictionary()

	var res = ResourceLoader.load(dict.get("scene_path", ""))
	if not res:
		return false
	var loaded: MoveSelfCardEffect = res.new() as MoveSelfCardEffect
	loaded.from_dictionary(dict)

	if not loaded.tile_highlight_config:
		return false
	return loaded.tile_highlight_config._range == 4 and loaded.center_piece == Constants.TargetType.MONSTER


## MoveOtherCardEffect.move_other_highlight_config must survive round-trip.
func _test_move_other_highlight_config_preserved() -> bool:
	var original := MoveOtherCardEffect.new()
	original.id = "move_other_test"
	original.move_other_highlight_config = TileHighlightConfig.new()
	original.move_other_highlight_config._range = 3
	original.move_other_highlight_config.ignore_occupied_tiles = true
	var dict: Dictionary = original.to_dictionary()

	var res = ResourceLoader.load(dict.get("scene_path", ""))
	if not res:
		return false
	var loaded: MoveOtherCardEffect = res.new() as MoveOtherCardEffect
	loaded.from_dictionary(dict)

	if not loaded.move_other_highlight_config:
		return false
	return loaded.move_other_highlight_config._range == 3 and loaded.move_other_highlight_config.ignore_occupied_tiles == true


## When a module is consumed during forge it must be removed from
## PlayerController's available modules inventory.
func _test_forge_consumed_module_is_removed() -> bool:
	var module := CardModule.new()
	module.id = "test_module_consumed_001"
	module.title = "Test Module"
	PlayerController.add_card_module(module)

	var size_before: int = PlayerController.get_card_modules().size()
	PlayerController.remove_card_module(module)
	var size_after: int = PlayerController.get_card_modules().size()

	return size_after == size_before - 1
