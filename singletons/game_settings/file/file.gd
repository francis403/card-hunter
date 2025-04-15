extends Node

const SAVE_FILE_PATH = "user://card_hunter.save"
var save_data: Dictionary = {
	"settings": {},
	"progress": {}
}

var settings: Settings
var progress: Progress

func _ready() -> void:
	BattlemapSignals.player_world_state_updated.connect(_on_player_world_state_updated_signal)
	settings = Settings.new()
	progress = Progress.new()

func delete_save():
	DirAccess.remove_absolute(SAVE_FILE_PATH)

func save():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(save_data)
	
func load_save_file():
	if !FileAccess.file_exists(SAVE_FILE_PATH):
		return
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	save_data = file.get_var()
	load_settings()
	load_progress()
	

func change_settings():
	save_data["settings"]["volume"] = settings.volume
	save()

func change_progress():
	save_data["progress"]["player_world_node_id"] = progress.current_world_node_id
	save_data["progress"]["world_state"] = progress.world_state.to_dictionary()
	save_data["progress"]["player"] = PlayerController.get_deck().save()
	save_data["progress"]["player"]["hp"] = PlayerController.current_player_health
	save()

func load_settings():
	if save_data["settings"].has("volume"):
		self.settings.volume = save_data["settings"]["volume"]
		
func load_progress():
	if save_data["progress"].has("player_world_node_id"):
		self.progress.current_world_node_id = save_data["progress"]["player_world_node_id"]
	if save_data["progress"].has("world_state"):
		_load_world_state()
	if save_data["progress"].has("player"):
		_load_player_info()
	
func _load_world_state():
	self.progress.world_state._world_state = save_data["progress"]["world_state"]
	self.progress.village_node = self.progress.world_state.convert_world_state_to_node()

## TODO: this can probably be done a lot better
func _load_player_info():
	var player_deck_info: Dictionary = save_data["progress"]["player"]
	progress.current_player_deck._load(player_deck_info)
	#progress.current_health = save_data["progress"]["player"]["hp"]
	progress.current_health = save_data["progress"]["player"]["hp"]
	PlayerController.current_player_health = progress.current_health
	#PlayerController._deck = save_data["progress"]["player"]["deck"]

## SIGNALS
## TODO: do we want to save as soon as the player clicks there? 
func _on_player_world_state_updated_signal(world_node: WorldNode):
	progress.world_state.convert_node_to_world_state(progress.village_node)
	change_progress()
