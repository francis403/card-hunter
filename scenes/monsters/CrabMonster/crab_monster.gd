extends MonsterPiece
class_name CrabMonster

#TODO: will need to create a basic enemy scene

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var state_machine: StateMachine = $StateMachine

## TODO: when the monster moves we need to update this
@onready var move_intent_container: MarginContainer = $StatusControl/MoveIntentContainer

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
	
func get_sprite() -> Sprite2D:
	return sprite_2d

func highlight_attack_action() -> void:
	state_machine.current_state.highlight_attack_action()
