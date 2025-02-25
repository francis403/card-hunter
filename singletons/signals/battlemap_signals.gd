extends Node

signal battlemap_generated(battlemap_grid: Battlemap)

signal awaiting_player_input
signal clear_highlighted_tiles
signal player_input_received
signal canceled_player_input
signal tile_picked_in_battlemap(tile: Tile)

signal player_stamina_changed(current_stamina: int)

signal lock_player_input
signal unlock_player_input

signal monster_turn_started
signal player_turn_started
