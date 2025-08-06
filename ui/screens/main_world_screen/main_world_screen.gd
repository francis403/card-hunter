extends Control
class_name MainWorldScreen

@onready var world_nodes: MarginContainer = $WorldNodes
@onready var boss_timer_label: Label = %BossTimerLabel
@onready var deck_ui: DeckUI = $DeckUI


func _ready() -> void:
	BattleSignals.battle_start.connect(_on_battle_start_signal)
	BattleSignals.battle_complete.connect(_on_battle_won_signal)
	BattlemapSignals.node_completed_and_freed.connect(_on_node_completed_signal)
	GameController.days_till_attack_modified.connect(_on_days_till_attack_modified_signal)
	_clean_preview()
	boss_timer_label.text = "Days till next attack: " + str(GameController.days_till_attack)

func _clean_preview():
	for child in world_nodes.get_children():
		child.queue_free()

func _update_days_till_attack(_days: int):
	boss_timer_label.text = "Days till next attack: " + str(_days)
	deck_ui._update_deck_label()

func _on_battle_start_signal():
	world_nodes.process_mode = Node.PROCESS_MODE_DISABLED

func _on_node_complete_signal():
	pass

func _on_days_till_attack_modified_signal(days: int):
	_update_days_till_attack(days)

func _on_battle_won_signal():
	world_nodes.process_mode = Node.PROCESS_MODE_ALWAYS
	GameController.decrease_days_till_next_attack()

func _on_node_completed_signal(id: String):
	deck_ui._update_deck_label()
