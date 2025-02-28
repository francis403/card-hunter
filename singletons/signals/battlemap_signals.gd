extends Node

signal battlemap_generated(battlemap_grid: Battlemap)

signal clear_highlighted_tiles
signal canceled_player_input
signal tile_picked_in_battlemap(tile: Tile)

signal lock_player_input
signal unlock_player_input
signal awaiting_player_input
signal player_input_received

# Card signals
signal card_discarded_from_hand(index: int)

# Player signals
signal player_turn_started
signal player_stamina_changed(current_stamina: int)

# Monster signals
signal monster_turn_started
signal monster_prepared_move(monster_sprite: Sprite2D, tile: Tile)
signal monster_prepared_attack(attacked_tiles: Array[Tile])
