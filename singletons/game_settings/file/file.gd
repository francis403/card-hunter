extends Node

var settings: Settings
var progress: Progress

func _ready() -> void:
	settings = Settings.new()
	progress = Progress.new()
