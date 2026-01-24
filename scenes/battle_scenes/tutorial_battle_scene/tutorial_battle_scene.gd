extends BattleGenericScene
class_name TutorialBattleScene

@onready var tutorial_banner: TutorialBanner = $TutorialBannerLayer/TutorialBanner

## UI to disable
@onready var end_turn_button: SoundButton = %EndTurnButton

func _ready() -> void:
	super._ready()
	_setup_dynamic_tooltips()
	tutorial_banner.tutorial_completed.connect(_on_tutorial_completed)
	tutorial_banner.start_tutorial()
	_stop_player_ui_input()

func _setup_dynamic_tooltips():
	if not monsters.is_empty():
		var monster_tooltip: Tooltip = _create_monster_tooltip(monsters[0])
		# Insert monster tooltip at index 4 (after discard pile, before player)
		tutorial_banner.insert_tooltip_at(4, monster_tooltip)

func _create_monster_tooltip(_monster: GenericMonster) -> Tooltip:
	var tooltip: Tooltip = Refs.tooltip_component_scene.instantiate()
	var tooltip_title: String = "The Monster wants to eat you\n (and your pets)"
	var tooltip_description: String = "During a hunt,\n your goal is to kill the monster."
	tooltip.display_text = "[b]%s[/b]\n%s" % [tooltip_title, tooltip_description]
	_monster.add_child(tooltip)
	return tooltip

func _on_tutorial_completed() -> void:
	GameController.days_till_attack += 1
	TutorialController.mark_tutorial_completed()
	EventController.show_event(EventController.EventID.BATTLE_TUTORIAL_COMPLETE, self)

func _stop_player_ui_input():
	end_turn_button.disabled = true
	for _card: Card in hand.get_cards():
		_card.card_can_hover = false
		_card.card_can_be_played = false
		_card.card_can_be_discarded = false
