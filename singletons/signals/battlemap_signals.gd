extends Node

## battlemap signals
signal battlemap_generated(battlemap_grid: Battlemap)
signal highlight_tiles(source_tile: Tile, config: TileHighlightConfig)
signal highlight_attack_tiles(source_tile: Tile, config: TileHighlightConfig)
signal highlight_move_tiles(source_tile: Tile, config: TileHighlightConfig)
signal clear_player_highlighted_tiles
signal clear_attack_highlight_tiles
signal clear_highlighted_tiles
signal tile_picked_in_battlemap(tile: Tile)
signal add_effect_to_tile(tile_effect: TileEffect, tile: Tile)
signal add_effect_type_to_tile(tile_effect: Constants.TileEffectTypes, tile: Tile)
signal get_monster_range_tiles(source_tile: Tile, config: TileHighlightConfig)
signal monster_range_tiles_generated(monster_range_tiles: Array[Tile])

## deck signals
signal draw_pile_updated(draw_pile_cards: Array[CardResource])
signal discard_pile_updated(discard_pile_cards: Array[CardResource])
signal full_deck_updated(discard_pile_cards: Array[CardResource])
signal show_full_deck
signal show_draw_pile_deck
signal show_discard_pile_deck

## Card signals
signal card_discarded_from_hand(index: int)
signal card_removed_from_deck(index: int)

## Player signals
signal player_turn_started
signal player_turn_ended
signal player_stamina_changed(current_stamina: int)
signal player_health_changed(current_hp: int)
signal lock_player_input
signal unlock_player_input
signal awaiting_player_input
signal player_input_received
signal canceled_player_input
signal player_died
signal play_card_stream(audio_stream: AudioStream)

# status can subscripte to a specific signal and apply whatever they need
signal determined_if_player_can_move(can_move: bool)
signal before_player_movement
signal after_player_movement

## Monster signals
signal monster_turn_started
signal deal_damage_to_attacked_squares(damage: int)
signal monster_hp_changed(new_hp: int, max_hp: int)
signal monster_prepared_move(tile: Tile)
signal monster_prepared_attack(attacked_tiles: Array[Tile])
signal monster_died
signal monster_moved_by_player(new_tile: Tile)

## WorldMap Signals
signal player_world_state_updated(world_node: WorldNode)
signal hide_player_in_other_node(world_node_id: String)
signal reveal_connected_nodes(world_node: WorldNode)
signal reveal_node(world_node_id: String)
signal node_finished_revealing(world_node_id: String)
signal node_completed(world_node_id: String)
signal world_updated
# TODO: if we want some sort of fog of war
signal generate_world_node_children(world_node: WorldNode)
