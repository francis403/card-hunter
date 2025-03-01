extends Node

## battlemap signals
signal battlemap_generated(battlemap_grid: Battlemap)
signal highlight_tiles(source_tile: Tile, range: int, area_type: Constants.AreaType)
signal highlight_attack_tiles(source_tile: Tile, range: int, area_type: Constants.AreaType)
signal clear_player_highlighted_tiles
signal clear_attack_highlight_tiles
signal clear_highlighted_tiles
signal tile_picked_in_battlemap(tile: Tile)

## Card signals
signal card_discarded_from_hand(index: int)

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

## Monster signals
signal monster_turn_started
signal deal_damage_to_attacked_squares(damage: int)
signal monster_prepared_move(monster_sprite: Sprite2D, tile: Tile)
signal monster_prepared_attack(attacked_tiles: Array[Tile])
signal monster_died
signal monster_moved_by_player(new_tile: Tile)
