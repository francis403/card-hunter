extends Node

## battlemap signals
signal battlemap_generated(battlemap_grid: Battlemap)
signal highlight_tiles(source_tile: Tile, config: TileHighlightConfig)
signal highlight_attack_tiles(source_tile: Tile, config: TileHighlightConfig)
signal highlight_move_tiles(source_tile: Tile, config: TileHighlightConfig)
signal clear_attack_highlight_tiles
signal clear_highlighted_tiles
signal tile_picked_in_battlemap(tile: Tile)
signal button_pressed_to_toggle_view_monster_parts

# TODO: signals should be a response to something, not to tell the game to do something
signal get_monster_range_tiles(source_tile: Tile, config: TileHighlightConfig)
signal monster_range_tiles_generated(monster_range_tiles: Array[Tile])
# Select/Discard Card UI
signal awaiting_for_card_selection(_ignore_card_list: Array[Card])
signal input_received_for_card_selected(card: Card)
signal card_selected_confirmed(card: Card)
signal card_discarded_by_other_card(discarded_card: Card)

## deck signals
signal draw_pile_updated(draw_pile_cards: Array[CardResourceV2])
signal discard_pile_updated(discard_pile_cards: Array[CardResourceV2])
signal full_deck_updated(discard_pile_cards: Array[CardResourceV2])
signal show_full_deck
signal show_draw_pile_deck
signal show_discard_pile_deck
signal draw_pile_draw_cards_requested(number_of_cards_to_draw: int)

## Card signals
signal card_has_been_played(card_resource: CardResourceV2)
signal player_initiated_card_discard(card: Card)
signal discard_card_animation_finished(is_success: bool)
signal card_discarded_from_hand(index: int)
signal card_discarded_from_hand_reverted(card_resource: CardResourceV2)
signal card_removed_from_deck()

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
signal deal_damage_to_attacked_squares(origin_tile: Tile, damage: int)
signal monster_hp_changed(new_hp: int, max_hp: int)
signal monster_prepared_move(tile: Tile)
signal monster_prepared_attack(attacked_tiles: Array[Tile])
signal monster_died
signal monster_moved_by_player(new_tile: Tile)
signal monster_body_part_attacked(monster: MonsterPiece, bodyPart: BodyPart)


## WorldMap Signals
signal player_world_state_updated(world_node: GenericWorldNode)
signal reveal_connected_nodes(world_node: GenericWorldNode)
signal node_finished_revealing(world_node_id: String)
signal node_completed(world_node_id: String)
signal node_completed_and_freed(world_node_id: String)
signal world_updated
signal world_node_screen_completed(_advance_day: bool)
signal generate_new_world
