# Forged Cards — Known Bugs

## Bug 1 — ForgeCardScreen never saves to disk (Critical)
**File:** `ui/screens/forge_card_screen/forge_card_screen.gd:47`

`_on_forge_button_pressed` adds the card to the deck, consumes modules, then calls `_on_back_button_pressed`. There is no `File.change_progress()` call anywhere in this path.

If the player forges a card and quits before the next world-node transition (which triggers the autosave via `_on_player_world_state_updated_signal`), both the forged card and the consumed modules are lost.

**Fix:** Call `File.change_progress()` at the end of `_on_forge_button_pressed`, before `_on_back_button_pressed()`. Mirrors what `card_inspector_screen.gd:167` already does for upgrades.

---

## Bug 2 — `quantity` is always reset to 1 on load (Moderate)
**File:** `singletons/game_settings/file/progress/progress.gd:80`

```gdscript
card_resource.from_dictionary(_dict[key])  # 'quantity' ignored
PlayerController.add_forged_card(card_resource)  # always writes quantity = 1
```

`CardResourceV2.from_dictionary` does not read the `quantity` field, and `add_forged_card` always initialises a new entry with `quantity = 1`. Any card saved with `quantity > 1` will reload as 1.

**Fix:** Read the `quantity` value from `_dict[key]` before calling `add_forged_card` and restore it directly into `PlayerController._forged_cards[id]["quantity"]` after the call.

---

## Bug 3 — Dead duplicate load functions in `file.gd` (Moderate)
**File:** `singletons/game_settings/file/file.gd:128-157`

`file.gd` contains `_load_world_state`, `_load_player_info`, `_load_player_card_modules`, and `_load_player_forged_cards` — none of which are called by `load_save_file()`. The actual load path delegates entirely to `progress.gd`, which has its own identical implementations.

Any fix applied to one copy will silently not affect the other.

**Fix:** Remove the dead functions from `file.gd`.

---

## Bug 4 — Card ID collision when forging (Moderate)
**File:** `ui/screens/forge_card_screen/forge_card_screen.gd:52`

```gdscript
new_card_resource.id = card_title_input.text.replace(" ", "")
```

Two cards forged with the same title (or titles differing only in spaces) produce the same ID. `PlayerController.add_forged_card` then increments the quantity of the first card instead of registering a new one. After reload, both deck slots reconstruct the same card.

The upgrade path avoids this correctly with `randi()`.

**Fix:** Append a random suffix the same way the upgrade does:
```gdscript
new_card_resource.id = "%s_%d" % [card_title_input.text.replace(" ", ""), randi()]
```

---

## Bug 5 — `ResourceLoader.load("")` crash risk on base CardModule (Minor)
**File:** `singletons/game_settings/file/progress/progress.gd:75`

`CardModule.to_dictionary()` always writes `"scene_path": _get_my_node_scene_path()`. The base `CardModule` returns `""` for that method. The load guard checks `has("scene_path")`, which always passes, so if any base `CardModule` ends up in the inventory `ResourceLoader.load("")` is called and `.new()` is invoked on `null`, causing a crash.

**Fix:** Add an empty-string guard before loading:
```gdscript
var scene_path: String = _player_card_modules_dict[key].get("scene_path", "")
if not scene_path.is_empty():
    card_module = ResourceLoader.load(scene_path).new()
```
