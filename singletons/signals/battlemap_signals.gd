extends Node

## battlemap signals
signal battlemap_generated(battlemap_grid: Battlemap)
signal highlight_tiles(source_tile: Tile, range: int, area_type: Constants.AreaType)
signal highlight_attack_tiles(source_tile: Tile, range: int, area_type: Constants.AreaType)
signal highlight_move_tiles(source_tile: Tile, range: int, area_type: Constants.AreaType)
signal clear_player_highlighted_tiles
signal clear_attack_highlight_tiles
signal clear_highlighted_tiles
signal tile_picked_in_battlemap(tile: Tile)

## deck signals
signal draw_pile_updated(draw_pile_cards: Array[CardResource])
signal discard_pile_updated(discard_pile_cards: Array[CardResource])
signal show_draw_pile_deck
signal show_discard_pile_deck

## Card signals
signal card_discarded_from_hand(index: int)
signal card_removed_from_deck(index: int)

## Player signals
signal player_turn_started
signal player_stamina_changed(current_stamina: int)
signal player_health_changed(current_hp: int)
signal lock_player_input
signal unlock_player_input
signal awaiting_player_input
signal player_input_received
signal canceled_player_input
signal player_died
signal play_card_stream(audio_stream: AudioStream)

## Monster signals
signal monster_turn_started
signal deal_damage_to_attacked_squares(damage: int)
signal monster_hp_changed(new_hp: int, max_hp: int)
signal monster_prepared_move(monster_sprite: Sprite2D, tile: Tile)
signal monster_prepared_attack(attacked_tiles: Array[Tile])
signal monster_died
signal monster_moved_by_player(new_tile: Tile)
