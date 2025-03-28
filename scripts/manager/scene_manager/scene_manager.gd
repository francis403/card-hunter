extends Node
class_name SceneManager

@export var _background_music: AudioStream
#@export var _fade: ColorRect
#@export var _settings_menu: Menu

func _ready() -> void:
	if _background_music:
		Music.play_track(_background_music)
	#_fade.to_clear()


func change_scene(scene: PackedScene):
	Music.fade_out()
	#await _fade.to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(scene)
