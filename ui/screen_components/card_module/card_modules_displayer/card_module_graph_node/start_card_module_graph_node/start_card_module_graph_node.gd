extends BaseCardModuleGraphNode
class_name StartCardModuleGraphNode

var card_module: CardModule

func _ready() -> void:
	# Start node: output only (no input port)
	# Golden color matching original StartCardModule
	set_slot(0, false, 0, Color.WHITE, true, 0, Color(0.83, 0.78, 0.42))


func set_card_module(_module: CardModule) -> void:
	card_module = _module
