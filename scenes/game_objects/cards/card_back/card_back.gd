extends MarginContainer
class_name CardBack

const SHIELD_ICON = preload("res://assets/game_objects/card_parts/card_icons/shield.tres")
const BOW_ICON = preload("res://assets/game_objects/card_parts/card_icons/bow.tres")
const SWORD_ICON = preload("res://assets/game_objects/card_parts/card_icons/sword.tres")

enum CardBackStyle {
	SHIELD,
	SWORD,
	BOW
}

@export var _card_back_style: CardBackStyle = CardBackStyle.SHIELD
@onready var card_back_texture_rect: TextureRect = $CardBackTextureRect

func _ready() -> void:
	if _card_back_style == CardBackStyle.SHIELD:
		update_card_back_image(SHIELD_ICON)
	elif  _card_back_style == CardBackStyle.SWORD:
		update_card_back_image(SWORD_ICON)
	elif _card_back_style == CardBackStyle.BOW:
		update_card_back_image(BOW_ICON)

func update_card_back_image(card_back_texture: AtlasTexture) -> void:
	card_back_texture_rect.texture = card_back_texture
