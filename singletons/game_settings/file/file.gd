extends Node

const SAVE_FILE_PATH = "user://card_hunter.save"
var save_data: Dictionary = {
	"settings": {},
	"progress": {}
}

var settings: Settings
var progress: Progress

func _ready() -> void:
	BattlemapSignals.update_player_node.connect(_on_update_player_node_signal)
	settings = Settings.new()
	progress = Progress.new()

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
	save()

func load_settings():
	if save_data["settings"].has("volume"):
		self.settings.volume = save_data["settings"]["volume"]
		
func load_progress():
	if save_data["progress"].has("player_world_node_id"):
		self.progress.current_world_node_id = save_data["progress"]["player_world_node_id"]
		
## SIGNALS
## TODO: do we want to save as soon as the player clicks there? 
func _on_update_player_node_signal(node_id: String):
	progress.current_world_node_id = node_id
	change_progress()
