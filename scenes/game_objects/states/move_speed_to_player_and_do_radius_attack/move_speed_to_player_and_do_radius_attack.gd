extends State
class_name MoveSpeedToPlayerAndDoRadiusAttack

# TODO: I have to make this state scenes more module
#	They should be able to take an array of the following:
#	- condition to trigger to next state
#	- next state

var target: PlayerPiece
var monster: MonsterPiece
var monster_sprite: Sprite2D

@export var range: int = 1

func enter_state():
	target = BattleController.get_player()
	monster = get_parent().get_parent()
	
func exit_state():
	pass
	
func do_state_action():
		
	self.do_movement()
	
	var distance_to_player = BattleController.distance_between_tiles(
		monster.next_move if monster.next_move else monster._tile,
		target._tile
	)
	
	# only show when able to attack player
	if distance_to_player > 1:
		BattlemapSignals.clear_attack_highlight_tiles.emit()
		return
	
	self.do_attack()
	
	var half_hp_monster: float = float (monster._max_hp) / 2
	if half_hp_monster > monster._health:
		self.changed_state.emit(self, "StayAwayAndAttackFromRange")

func do_preview_action():
	self.preview_monster_attack_behaviour()

func do_movement():
	if not monster:
		monster = BattleController.get_monster()
	var next_turn_move_tile: Tile = monster.next_move
	
	if next_turn_move_tile:
		BattleController.battlemap.place_piece_in_tile(monster, next_turn_move_tile)
	if monster_sprite:
		monster_sprite.queue_free()
	monster_sprite = monster.get_sprite().duplicate()
	next_turn_move_tile = MovementUtils.get_movement_tile(
		monster._tile,
		target._tile,
		monster._speed
	)
	BattlemapSignals.monster_prepared_move.emit(
		monster_sprite,
		next_turn_move_tile
	)
	
func do_attack():
	BattlemapSignals.deal_damage_to_attacked_squares.emit(
		monster._strength
	)
	preview_monster_attack_behaviour()

func preview_monster_attack_behaviour() -> void:
	var monster: MonsterPiece = BattleController.get_monster()
	var source_tile: Tile = monster.next_move
	if not source_tile:
		source_tile = monster._tile
	highlight_attack_tiles(source_tile)

func highlight_attack_tiles(source_tile: Tile):
	# clean old attacked tiles
	BattlemapSignals.clear_attack_highlight_tiles.emit()
	BattlemapSignals.highlight_attack_tiles.emit(
		source_tile,
		1,
		Constants.AreaType.RADIUS
	)
