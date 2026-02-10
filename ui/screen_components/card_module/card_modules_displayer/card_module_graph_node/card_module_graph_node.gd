extends GraphNode
class_name CardModuleGraphNode

var card_module: CardModule

@onready var title_label: Label = %TitleLabel
@onready var stamina_label: Label = %StaminaLabel

func _ready() -> void:
	# Default slot configuration (input and output)
	set_slot(0, true, 0, Color.WHITE, true, 0, Color.WHITE)
	_update_display()


func set_card_module(_module: CardModule) -> void:
	card_module = _module
	if is_inside_tree():
		_update_display()


func _update_display() -> void:
	if not card_module:
		return

	if title_label:
		title_label.text = tr(card_module.title) if card_module.title else "Module"
	if stamina_label:
		stamina_label.text = str(card_module.stamina_cost)


func configure_as_start() -> void:
	# Start node: output only (no input port)
	set_slot(0, false, 0, Color.WHITE, true, 0, Color(0.83, 0.78, 0.42))


func configure_as_effect() -> void:
	# Effect node: both input and output
	set_slot(0, true, 0, Color(0.58, 0.45, 0.07), true, 0, Color(0.58, 0.45, 0.07))


func configure_as_decision() -> void:
	# Decision node: both input and output (yellow)
	set_slot(0, true, 0, Color(0.85, 0.75, 0.2), true, 0, Color(0.85, 0.75, 0.2))


func configure_as_end() -> void:
	# End node: input only (no output port)
	set_slot(0, true, 0, Color(0.21, 0.15, 0.4), false, 0, Color.WHITE)
