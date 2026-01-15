extends MarginContainer
class_name ClassDebugMenu


func _ready() -> void:
	GameController.debug_mode_toggled.connect(_on_debug_mode_toggled)
	
func _on_debug_mode_toggled(_toggled: bool):
	self.visible = _toggled

func _unlock_all_classes():
	var _unlockable_content: Dictionary = LockedContentController.unlockable_content
	for key in _unlockable_content.keys():
		if not LockedContentController.is_unlocked(key):
			LockedContentController.unlock_content(key)
	self.get_parent()._ready()
