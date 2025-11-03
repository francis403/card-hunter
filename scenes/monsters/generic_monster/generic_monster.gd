extends MonsterPiece
class_name GenericMonster

signal monster_hit
signal body_part_hit(body_part: BodyPart)

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var state_machine: StateMachine = $StateMachine
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var monster_body_part_container: MonsterBodyPartContainer = $MonsterBodyPartContainer

@onready var power_effect_container: PowerEffectContainer = $PowerEffectContainer
@onready var power_effect_ui: PowerEffectUI = $PowerEffectUI

@onready var move_intent_container: MarginContainer = $StatusControl/MoveIntentContainer
@onready var reward_manager: RewardManager = $RewardManager

## Indicator of what the monster is going to do
@onready var move_intent_image: TextureRect = $StatusControl/MoveIntentContainer/MoveIntentImage

@onready var monster_stats_ui: Control = $MonsterStatsUI
@onready var monster_health_bar: ProgressBar = $MonsterStatsUI/MonsterHealthBar

@export var monster_id: String
@export var monster_texture: Texture2D
@export var monster_config: MonsterConfig
@export var debug_mode: bool = false

func _ready() -> void:
	super._ready()
	if monster_texture and not sprite_2d.texture:
		sprite_2d.texture = monster_texture
	self.set_state_icon()
	self.set_debug_mode()
	self.subscribe_to_events()
	monster_health_bar.max_value = self._max_hp if _max_hp >= _health else _health
	monster_health_bar.value = self._health

## Play the monster turn
func play_monster_turn():
	super.play_monster_turn()
	state_machine.do_state_action()
	self.end_monster_turn()
	
func on_monster_moved_by_player(new_tile: Tile) -> void:
	self._tile = new_tile
	state_machine.do_preview_action(true)

## TODO: improve the function
## We shouldn;t be using sprite_2d.flip_h.
## Maybe we can calculate using
func _on_monster_prepared_move_signal(tile: Tile):
	super._on_monster_prepared_move_signal(tile)
	if self.next_move:
		if move_intent_container:
			move_intent_container.visible = true
		var angle: float = (_tile.position.angle_to_point(self.next_move.position))
		move_intent_container.rotation = angle
		var initial_rotation: float = sprite_2d.rotation
		var _initial_flip: bool = sprite_2d.flip_h
		var _new_rotation: float = _calculate_monster_orientation(self.next_move)
		if _new_rotation != initial_rotation:
			sprite_2d.rotation = _new_rotation
			monster_body_part_container._rotate_body_parts(
				self._tile,
				initial_rotation,
				_new_rotation
			)
		if _initial_flip != sprite_2d.flip_h:
			monster_body_part_container._rotate_body_parts(
				self._tile,
				initial_rotation,
				deg_to_rad(rad_to_deg(initial_rotation) + 180)
			)
	else:
		move_intent_container.visible = false

func _calculate_monster_orientation(move_tile: Tile) -> float:
	## An angle of 0 is looking to the left
	var monster_rotation_angle: float = 1.5
	monster_rotation_angle = move_tile.position.angle_to_point(self._tile.position) 
	if (absf(monster_rotation_angle - PI) <= 0.1):
		monster_rotation_angle = 0
		sprite_2d.flip_h = not sprite_2d.flip_h
	## if it's negative
	if monster_rotation_angle < 0:
		monster_rotation_angle += PI
	if monster_rotation_angle > 1.6:
		monster_rotation_angle -= PI
	return monster_rotation_angle
	

func set_state_icon(icon: Texture2D = null):
	if not state_machine or not move_intent_image:
		return
	if icon:
		move_intent_image.texture = icon
		return
	var current_state_icon: Texture2D = state_machine.get_state_icon()
	if current_state_icon:
		move_intent_image.texture = current_state_icon
	
func set_debug_mode():
	if not debug_mode:
		return
	monster_body_part_container.debug_mode = self.debug_mode
	
func subscribe_to_events():
	monster_body_part_container.monster_body_part_hit.connect(_on_monster_body_part_hit)
	
func _on_monster_body_part_hit(body_part: BodyPart):
	if debug_mode:
		print(_on_monster_body_part_hit, ": ", body_part.part_name)
	#BattlemapSignals.monster_body_part_attacked.emit(self, body_part)
	self.body_part_hit.emit(body_part)
	
## TODO: I don't think I need this function
func get_sprite() -> Sprite2D:
	return sprite_2d

func get_texture() -> Texture2D:
	if monster_texture:
		return monster_texture
	if sprite_2d:
		return sprite_2d.texture
	return null

func highlight_attack_action() -> void:
	state_machine.current_state.highlight_attack_action()
	
func add_power_effect(power_effect: BasePowerNodeController):
	if _is_monster_immune_to_status(power_effect.power_effect_resource.id):
		return
	power_effect_container.add_power_effect(power_effect, self)

## TODO: improve this
func remove_power_effect(status_id: String):
	for child in power_effect_ui.get_power_effect_indicator_children():
		if child.power_effect.id == status_id:
			child.queue_free()
			return

func _is_monster_immune_to_status(
	status_id: String
) -> bool:
	if not monster_config:
		return false
	if not monster_config.monster_immunity_config:
		return false
	return monster_config.monster_immunity_config.immune_list.has(status_id)

func has_any_power_effect() -> bool:
	return power_effect_container.has_any_power_effect()

func has_power_effect(status_id: String) -> bool:
	return power_effect_container.has_power_effect(status_id)

func get_card_rewards() -> Array[CardResourceV2]:
	return reward_manager.get_random_cards(2)

func apply_damage(
	damage: int,
	_origin_tile: Tile,
	_show_text: bool = true
):
	if _origin_tile:
		var angle: float = rad_to_deg(
			_tile.get_center().angle_to_point(
				_origin_tile.get_center()
			)
		)
		
		monster_body_part_container.get_and_hit_body_parts(
			fmod(angle + 360, 360), 
			damage
		)
	if _show_text:
		hurtbox_component.trigger(str(damage))
	super.apply_damage(damage, _origin_tile, _show_text)
	monster_health_bar.value = self._health

func on_mouse_hover_enter():
	self.monster_stats_ui.visible = not BattleController.awaiting_player_input

func on_mouse_hover_exit():
	self.monster_stats_ui.visible = false
