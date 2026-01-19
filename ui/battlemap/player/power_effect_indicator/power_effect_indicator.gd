extends MarginContainer
class_name PowerEffectIndicator

@onready var tooltip: Tooltip = %Tooltip

@export var power_effect: PowerEffect


func _ready() -> void:
	if power_effect and tooltip:
		var _tooltip_text = "[b]%s[/b]\n%s" % [power_effect.title, power_effect.description]
		tooltip.set_display_text(_tooltip_text)
		_setup_compact_tooltip_style()


func _setup_compact_tooltip_style() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.78)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.12, 0.12, 0.12, 1)
	style.border_blend = true
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.content_margin_left = 6.0
	style.content_margin_top = 4.0
	style.content_margin_right = 6.0
	style.content_margin_bottom = 4.0
	tooltip.add_theme_stylebox_override("panel", style)
	tooltip.content_rich_text_label.add_theme_font_size_override("normal_font_size", 12)
	tooltip.content_rich_text_label.add_theme_font_size_override("bold_font_size", 12)
