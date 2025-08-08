extends Resource

## Represents some modular component 
## that can be added or removed from a card
class_name CardModule

@export var id: String
@export var title: String = ""
@export var stamina_cost: int = 5

func to_dictionary() -> Dictionary:
	var result: Dictionary = {
		"id": self.id,
		"title": self.title,
		"stamina_cost": self.stamina_cost
	}
	return result

func from_dictionary(dictionary: Dictionary):
	self.id = dictionary["id"]
	self.title = dictionary["title"]
	self.stamina_cost = dictionary["stamina_cost"]

func equals(other: CardModule) -> bool:
	return self.id == other.id and self.title == other.title\
		and self.stamina_cost == other.stamina_cost
