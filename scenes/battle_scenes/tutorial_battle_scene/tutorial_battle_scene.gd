extends BattleGenericScene
class_name TutorialBattleScene

@onready var hand_tooltip: Tooltip = $Hand/HandTooltip
@onready var draw_pile_tooltip: Tooltip = $UINodes/DrawPile/Tooltip
@onready var discard_pile_tooltip: Tooltip = $UINodes/BottomRightContainer/DiscardPile/Tooltip
@onready var end_turn_tooltip: Tooltip = $UINodes/BottomRightContainer/EndTurnButton/Tooltip
@onready var player_stats_tooltip: Tooltip = $UINodes/PlayerStatsUI/Tooltip
@onready var tutorial_banner: TutorialBanner = $TutorialBannerLayer/TutorialBanner
@onready var player_tool_tip: Tooltip = $Player/PlayerToolTip

## UI to disable
@onready var end_turn_button: SoundButton = %EndTurnButton


var _monster_tooltip: Tooltip
var _player_tooltip: Tooltip

var _tutorial_tooltips: Array[Tooltip] = []
var _current_tooltip_index: int = -1

# Banner text for each tutorial step (index corresponds to tooltip being shown)
var _banner_texts: Dictionary = {
	-1: "In this tutorial you will know everything you need to know about the battle system.\nRight-click to continue.",
	0: "This are your stats.\nRight-click to continue.",
	1: "This is your [b]Hand[/b]. Right-click to continue.",
	2: "This is your [b]Draw Pile[/b]. Right-click to continue.",
	3: "This is your [b]Discard Pile[/b]. Right-click to continue.",
	4: "This is the [b]Monster[/b] you need to defeat. Right-click to continue.",
	5: "This is [b]You[/b] don't get too close to the monster!. Right-click to continue.",
	6: "Click [b]End Turn[/b] when you're done playing cards. Right-click to finish.",
}
var _default_banner_text: String = "Right-click to continue."

func _ready() -> void:
	super._ready()
	tutorial_banner.title_text = "[b]Tutorial[/b]"
	_setup_dynamic_tooltips()
	_tutorial_tooltips = [
		player_stats_tooltip, hand_tooltip, draw_pile_tooltip,
		discard_pile_tooltip, _monster_tooltip, player_tool_tip,
		end_turn_tooltip
	]
	_display_screen_description_main_banner()
	_stop_player_ui_input()

func _setup_dynamic_tooltips():
	if not monsters.is_empty():
		_monster_tooltip = _setup_monster_tooltip(monsters[0])
		
func _setup_monster_tooltip(
	_monster: GenericMonster
) -> Tooltip:
	var _tooltip: Tooltip = Refs.tooltip_component_scene.instantiate()
	var _tooltip_title: String = "The Monster wants to eat you\n (and your pets)"
	var _tooltip_description: String = "During a hunt,\n your goal is to kill the monster."
	var _tooltip_text: String = "[b]%s[/b]\n%s" % [_tooltip_title, _tooltip_description]
	_tooltip.display_on_hover = false
	_tooltip.follow_mouse = false
	_tooltip.display_on_mouse_position = false
	_tooltip.display_text = _tooltip_text
	_monster.add_child(_tooltip)
	return _tooltip


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton\
		and event.button_index == MOUSE_BUTTON_RIGHT\
		and event.pressed:
		_show_next_tutorial_tooltip()

func _display_screen_description_main_banner():
	_update_banner_text(_banner_texts, _current_tooltip_index)

func _show_next_tutorial_tooltip() -> void:
	# Hide current tooltip if one is showing
	if _current_tooltip_index >= 0 and _current_tooltip_index < _tutorial_tooltips.size():
		if _tutorial_tooltips[_current_tooltip_index]:
			_tutorial_tooltips[_current_tooltip_index].toggle_off()
	_current_tooltip_index += 1
	_update_banner_text(_banner_texts, _current_tooltip_index)
	# Show next tooltip if within bounds
	if _current_tooltip_index < _tutorial_tooltips.size():
		var _current_tooltip: Tooltip = _tutorial_tooltips[_current_tooltip_index]
		if _current_tooltip:
			_tutorial_tooltips[_current_tooltip_index].toggle_on()
	else:
		_finish_tutorial()

func _update_banner_text(
	_banner_content: Dictionary,
	_index: int
) -> void:
	if _banner_content.has(_index):
		tutorial_banner.content_text = "[center]%s[/center]" % _banner_content[_index]
	else:
		tutorial_banner.content_text = "[center]%s[/center]" % _default_banner_text

func _finish_tutorial():
	_hide_banner()
	GameController.days_till_attack += 1
	TutorialController.mark_tutorial_completed()
	EventController.show_event(EventController.EventID.BATTLE_TUTORIAL_COMPLETE, self)
	#self.queue_free()

func _hide_banner() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(tutorial_banner, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): tutorial_banner.visible = false)

func _stop_player_ui_input():
	end_turn_button.disabled = true
	for _card: Card in hand.get_cards():
		_card.card_can_hover = false
		_card.card_can_be_played = false
		_card.card_can_be_discarded = false
