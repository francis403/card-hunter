extends Node

## TODO: need to convert this to Game_Controller 
##	and make a battle_manager in the generic battle_scene instead
var battlemap: Battlemap

func _ready() -> void:
	BattlemapSignals.battlemap_generated.connect(_on_battlemap_generated_signal)
	File.load_save_file()

func _on_battlemap_generated_signal(map: Battlemap):
	print(_on_battlemap_generated_signal)
	self.battlemap = map

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape_button_pressed"):
		_process_settings_screen()

func _process_settings_screen():
	ScreenUtils.open_settings_screen(get_parent())
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func get_player() -> PlayerPiece:
	return battlemap.player
	
func get_monster() -> MonsterPiece:
	return battlemap.monsters[0]

func get_tile(x: int, y: int) -> Tile:
	return battlemap.get_tile(x, y)

func distance_between_tiles(tile1: Tile, tile2: Tile) -> int:
	var x1 = tile1._x_position
	var x2 = tile2._x_position
	var y1 = tile1._y_position
	var y2 = tile2._y_position
	return round(
		pow(
			pow((x2 - x1), 2) + pow((y2 - y1), 2),
			0.5
		)
	)
