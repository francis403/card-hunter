extends Node

const SAVE_FILE_PATH = "user://card_hunter.save"
var save_data: Dictionary = {
	"settings": {},
	"progress": {}
}

var settings: Settings
var progress: Progress

func _ready() -> void:
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

func change_settings():
	save_data["settings"]["volume"] = settings.volume
	save()
	
func load_settings():
	if save_data["settings"].has("volume"):
		self.settings.volume = save_data["settings"]["volume"]
