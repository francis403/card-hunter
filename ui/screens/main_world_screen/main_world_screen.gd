extends Control
class_name MainWorldScreen

@onready var world_nodes: MarginContainer = $WorldNodes
@onready var boss_timer_label: Label = %BossTimerLabel

## TODO: I probably don't want this here
var days_till_attack: int = 5

func _ready() -> void:
	BattleSignals.battle_won.connect(_on_battle_won_signal)
	_clean_preview()
	boss_timer_label.text = "Days till next attack: " + str(days_till_attack)

func _clean_preview():
	for child in world_nodes.get_children():
		child.queue_free()
		
func _on_battle_won_signal():
	days_till_attack -= 1
	boss_timer_label.text = "Days till next attack: " + str(days_till_attack)
