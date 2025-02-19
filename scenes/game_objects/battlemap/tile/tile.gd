extends ReferenceRect
class_name Tile

var _x_size: int = 40
var _y_size: int = 40

@export var show_status: bool = false

@onready var status_label: Label = $StatusLabel

func _ready() -> void:
	status_label.visible = show_status


func initialize_tile(
	border_color: Color,
	x: int, 
	y: int, 
	x_size: int, 
	y_size: int,
	editor_only: bool = true
):
	_x_size = x_size
	_y_size = y_size
	self.border_color = border_color
	status_label.text = "(" + str(x) + ", " + str(y) + ")" 
	self.position.x = x * x_size
	self.position.y = y * y_size
	self.editor_only = editor_only
	self.custom_minimum_size.x = x_size
	self.custom_minimum_size.y = y_size
