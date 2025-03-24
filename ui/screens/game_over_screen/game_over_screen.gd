extends Control
class_name GameOverScreen


@export var title_text: String = "You Win"

@onready var title_label: Label = %TitleLabel


func _ready() -> void:
	title_label.text = title_text

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_continue_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(Constants.pick_class_screen_scene)
