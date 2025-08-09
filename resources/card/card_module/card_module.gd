extends Resource

## Represents some modular component 
## that can be added or removed from a card
class_name CardModule

@export var id: String
@export var title: String = ""
@export var stamina_cost: int = 5

@export_group("Card Module Color Configuration")
@export var default_top_section_background_color: Color = Color(0.124, 0.15, 0.153)
@export var default_bottom_section_background_color: Color = Color(0.384, 0.384, 0.384)

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
		"scene_path": _get_my_node_scene_path()
	}
	return result

func from_dictionary(dictionary: Dictionary):
	self.id = dictionary["id"]
	self.title = dictionary["title"]
	self.stamina_cost = dictionary["stamina_cost"]

func equals(other: CardModule) -> bool:
	return self.id == other.id and self.title == other.title\
		and self.stamina_cost == other.stamina_cost
