extends Node

signal battlemap_generated(battlemap_grid: Battlemap)

signal awaiting_player_input
signal clear_highlighted_tiles
signal player_input_received
signal canceled_player_input
signal tile_picked_in_battlemap(tile: Tile)
