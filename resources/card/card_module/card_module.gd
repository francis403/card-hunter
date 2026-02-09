extends Resource

## Represents some modular component 
## that can be added or removed from a card
class_name CardModule

@export var id: String
@export var title: String = ""
@export var stamina_cost: int = 5
@export var types: Array[String] = []

@export_group("Card Module Color Configuration")
@export var default_top_section_background_color: Color = Color(0.124, 0.15, 0.153)
@export var default_bottom_section_background_color: Color = Color(0.384, 0.384, 0.384)

@export_group("Validation Rules")
## Position constraint for this module
@export var placement_rule: Constants.ModulePlacementRule = Constants.ModulePlacementRule.NONE
## Maximum number of this module type allowed per card
@export var max_instances_per_card: int = -1

@export_group("Connection Configuration Between card modules")
## Define how many inputs this card can have, what types, and to where
@export var output_links: Array[CardModuleOutputLink]
## Unique identifier to be used in the connection between card_modulesss
@export var connection_id: String
@export_enum(
	"START",
	"INPUT",
	"EFFECT", 
	"DECISION"
) var module_type: String = "EFFECT"

## Built from the output_links
var next_modules: Array[CardModule]

func get_top_section_color() -> Color:
	if "top_section_background_color" in self:
		return self.top_section_background_color
	return default_top_section_background_color

func get_bottom_section_color() -> Color:
	if "bottom_section_background_color" in self:
		return self.bottom_section_background_color
	return default_bottom_section_background_color	

## Override this function
func _get_my_node_scene_path() -> String:
	return ""

func to_dictionary() -> Dictionary:
	var result: Dictionary = {
		"id": self.id,
		"title": self.title,
		"stamina_cost": self.stamina_cost,
		"placement_rule": self.placement_rule,
		"types": self.types,
		"scene_path": _get_my_node_scene_path()
	}
	return result

func from_dictionary(dictionary: Dictionary):
	self.id = dictionary["id"]
	self.title = dictionary["title"]
	self.stamina_cost = dictionary["stamina_cost"]
	self.types = dictionary["types"]
	self.placement_rule = dictionary["placement_rule"]

func equals(other: CardModule) -> bool:
	return self.id == other.id and self.title == other.title\
		and self.stamina_cost == other.stamina_cost
