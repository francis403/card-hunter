extends Node
class_name CardController

var battlemap: Battlemap

func _ready() -> void:
	BattlemapSignals.battlemap_generated.connect(_on_battlemap_generated_signal)
	battlemap = BattleController.battlemap
#Question, do we need this to be extending node? 
#	Maybe a script would be enough, we don't need an entire packed scene

func _on_battlemap_generated_signal(map: Battlemap):
	print(_on_battlemap_generated_signal)
	self.battlemap = map

func play_card_action(card_resource: CardResource):
	pass
