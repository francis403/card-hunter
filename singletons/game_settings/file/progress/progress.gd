extends Resource
class_name Progress

var current_health: int
var current_world_node_id: String:
	set(value):
		if current_world_node_id and current_world_node_id != value:
			var _old_node: GenericWorldNode = world_state.get_world_node(current_world_node_id)
			if _old_node:
				_old_node.hide_player()
		current_world_node_id = value
		GameController.current_player_node_id = current_world_node_id

## Already loaded world
var village_node: VillageWorldNode

## Dictionary representation of the world
var world_state: WorldState

## Representation of the deck the player currently has equiped
var current_player_deck: PlayerDeck


## Default values
func _init() -> void:
	current_health = -1
	current_world_node_id = Constants.VILLAGE_NODE_ID
	current_player_deck = PlayerDeck.new()
	world_state = WorldState.new()

func load_world(_dict: Dictionary):
	world_state.load_world_state(_dict)
	var _loaded_village_node: GenericWorldNode = world_state.load_node_from_memory(Constants.VILLAGE_NODE_ID)
	self.village_node = _loaded_village_node

func update_player_position(current_world_node: GenericWorldNode):
	if not PlayerController.current_world_node:
		PlayerController.current_world_node = current_world_node
	PlayerController.current_world_node.hide_player()
	File.progress.current_world_node_id = current_world_node.world_node_id
	PlayerController.current_world_node = current_world_node
	PlayerController.current_world_node.show_player()
