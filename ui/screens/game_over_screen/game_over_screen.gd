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
	self.get_parent().queue_free()
