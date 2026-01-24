extends MarginContainer
class_name TutorialBanner

@onready var title_label: RichTextLabel = %TitleLabel
@onready var content_label: RichTextLabel = %ContentLabel

@export var title_text: String:
	set(value):
		title_text = value
		if title_label:
			title_label.text = title_text

@export var content_text: String:
	set(value):
		content_text = value
		if content_label:
			content_label.text = content_text

func _ready() -> void:
	title_label.text = title_text
	content_label.text = content_text
