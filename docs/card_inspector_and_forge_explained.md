# Card Inspector Screen & Forged Cards — How It Works

## CardInspectorScreen (`card_inspector_screen.gd`)

The screen has two tabs: **Inspect** (view/upgrade an existing deck card) and **Forge** (create a brand-new card).

### Inspect tab — viewing a card
- On `_ready`, the screen loads all player card modules into `CardModulesContainerComponent` (the palette on the side) via `PlayerController.get_card_modules()`.
- The card currently being inspected is shown in the `Card` node and its module graph in `CardModuleDisplayer`.
- **Change Card** opens a `DeckVisualizer` overlay. Clicking a card in there calls `_on_deck_card_selected`, which repopulates the displayer for the newly selected card.

### Inspect tab — upgrading a card ("Upgrade Card" / "Save")
Pressing **Upgrade Card** toggles `_is_upgrade_open`:
- Module palette becomes visible; the displayer enables deletion and connection of nodes.
- The player drags modules from the palette into the graph. Each click calls `_on_card_module_pressed`, which removes the module from the palette, adds it to the graph displayer, and appends it to `_upgrade_modules`.
- An **undo stack** (`_undo_stack: Array[Dictionary]`) tracks every add/remove action so the player can step back. Each undo mirrors both the graph state and the palette.

Pressing **Save** calls `_save_card_upgrade()`:
1. Validates the graph via `card_modules_displayer.is_display_module_valid()`.
2. Creates a **new** `CardResourceV2` resource (never mutates the original).
   - ID is `"<old_id>_<random_int>"`, title gains a `+` suffix.
   - `play_actions` are collected from the displayer's `_node_module_map` (only nodes that are `CardEffect`).
   - `_generate_card_modules_tree()` rebuilds the linked tree from those actions.
   - `special_effects` are copied from the displayer's `_special_card_effects` list.
   - `stamina_cost` = old cost + sum of all added module costs.
3. The old card is removed from the deck and from `_forged_cards`; the new one is added.
4. Consumed modules are removed from the player inventory via `PlayerController.remove_card_module`.
5. **`File.change_progress()`** is called to flush everything to disk (see below).

### Forge tab (`forge_card_screen.gd`)
- Opened lazily when the user switches to tab index 1; the `ForgeCardScreen` scene is instantiated and its back/title buttons are hidden since it's embedded.
- The player picks modules from the palette. Each click validates the combination with `CardModuleValidator` before accepting it.
- Pressing **Forge** calls `_on_forge_button_pressed()` which:
  1. Validates title length (1–30 chars) and module count (1–4).
  2. Builds a `CardResourceV2` via `_build_card_resource_from_displayer()` (same pattern as upgrade: collect `CardEffect` nodes, call `_generate_card_modules_tree()`).
  3. Sets `is_forged = true`, adds the card to the deck, registers it in `PlayerController.add_forged_card`, and consumes the modules.

---

## How Forged Cards Are Saved

### In memory — `PlayerController`
`_forged_cards: Dictionary` maps `card_id → Dictionary` (the card's serialised form + a `quantity` counter).
- `add_forged_card(resource)` serialises via `resource.to_dictionary()` and inserts/increments.
- `remove_forged_card(id)` decrements; erases when quantity reaches 0.

### Serialisation — `CardResourceV2.to_dictionary()` / `from_dictionary()`
`to_dictionary()` stores:
```
{ id, title, rarity, description, stamina_cost,
  play_actions:   { connection_id → module.to_dictionary() },
  special_effects: { … },
  play_conditions: { … } }
```
Each module dict also carries `output_link_ids` (the `connection_id`s of the next nodes), which is enough to reconstruct the execution tree.

`from_dictionary()` reverses this:
1. `_read_card_modules_from_dictionary()` loads each module: looks it up in `CardModuleController` (canonical resource) or falls back to `scene_path`, duplicates it, then appends to the correct array (`play_actions` / `special_effects` / `play_conditions`).
2. `_rebuild_output_links_from_dictionary()` wires `output_links` on every loaded module using the saved `output_link_ids`.
3. `_generate_card_modules_tree()` builds the in-memory tree (`start_card_module`, `modules_dictionary`, `next_modules` references).

### Writing to disk — `File.change_progress()`
```
save_data["progress"]["player"]["forged_cards"] = PlayerController._forged_cards
```
The whole progress blob is then written with `FileAccess` to `user://card_hunter.save`.

### Loading from disk
`File._load_player_forged_cards(dict)`:
1. Clears `PlayerController._forged_cards`.
2. For each entry, creates a blank `CardResourceV2`, calls `from_dictionary()`, then re-registers it via `PlayerController.add_forged_card()`.
   - This also re-adds the card to the player deck (the deck load happens separately in `progress.current_player_deck._load()`).

---

## Data Flow Summary

```
Player upgrades/forges card
        │
        ▼
CardInspectorScreen / ForgeCardScreen
  ├─ creates new CardResourceV2 (play_actions + tree)
  ├─ PlayerController.add_card_to_deck()
  ├─ PlayerController.add_forged_card()   ← serialises to dict
  └─ File.change_progress()
          │
          ▼
    save_data["progress"]["player"]["forged_cards"]
          │
          ▼
    FileAccess.store_var()  →  user://card_hunter.save

On next load:
    File._load_player_forged_cards()
      └─ CardResourceV2.from_dictionary()  →  _generate_card_modules_tree()
```
