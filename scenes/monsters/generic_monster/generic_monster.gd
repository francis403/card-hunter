extends MonsterPiece
class_name GenericMonster

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var state_machine: StateMachine = $StateMachine

@onready var status_effect_container: StatusEffectContainer = $StatusEffectContainer
@onready var status_effects_ui: StatusEffectUI = $StatusEffectsUI

@onready var move_intent_container: MarginContainer = $StatusControl/MoveIntentContainer
@onready var reward_manager: RewardManager = $RewardManager

@export var monster_id: String
@export var monster_texture: Texture2D
@export var monster_config: MonsterConfig

func _ready() -> void:
	super._ready()
	if monster_texture and not sprite_2d.texture:
		sprite_2d.texture = monster_texture

func play_monster_turn():
	super.play_monster_turn()
	state_machine.do_state_action()
	self.end_monster_turn()
	
func on_monster_moved_by_player(new_tile: Tile) -> void:
	self._tile = new_tile
	state_machine.do_preview_action(true)

func _on_monster_prepared_move_signal(tile: Tile):
	super._on_monster_prepared_move_signal(tile)
	if self.next_move:
		move_intent_container.visible = true
		move_intent_container.rotation = (_tile.position.angle_to_point(self.next_move.position)) 
	else:
		move_intent_container.visible = false

func on_battle_start_signal():
	state_machine.do_state_action()
	
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

func add_status(status: StatusEffect):
	## TODO: improve
	## Check to see if the monster is immune to the specific status
	if _is_monster_immune_to_status(monster_config, status.id):
		return
	status_effect_container.add_status(status, self)

## TODO: improve this
func remove_status(status_id: String):
	for child in status_effects_ui.get_status_indicator_children():
		if child.status_effect.id == status_id:
			child.queue_free()
			return

func _is_monster_immune_to_status(
	monster_config: MonsterConfig,
	status_id: String
) -> bool:
	if not monster_config:
		return false
	if not monster_config.monster_immunity_config:
		return false
	return monster_config.monster_immunity_config.immune_list.has(status_id)

func has_any_status() -> bool:
	return status_effect_container.has_any_status()

func has_status(status_id: String) -> bool:
	return status_effect_container.has_status(status_id)

func get_card_rewards() -> Array[CardResource]:
	return reward_manager.get_random_cards(2)
