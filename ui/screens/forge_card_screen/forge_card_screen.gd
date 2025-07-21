extends Control
## 1. Show a list of available card modules
## 2. Player picks a module, it gets added to the card
## 3. Go back to step 2 until done
## 4. Player clicks forge and the card is done
## Show success message
class_name ForgeCardScreen

@onready var card_modules_container_component: CardModulesContainerComponent = %CardModulesContainerComponent

func _ready() -> void:
	card_modules_container_component.set_grid_elems(
		PlayerController.get_card_modules()
	)
	for child: CardModuleComponent in card_modules_container_component.get_children_nodes():
		child._is_clickable = true
		child.clicked.connect(_on_card_module_clicked_signal)
		

func _on_card_module_clicked_signal(
	_card_module_component: CardModuleComponent
):
	print(_on_card_module_clicked_signal, ": ", _card_module_component.card_module_title)

func _on_back_button_pressed() -> void:
	self.queue_free()
