extends Node
class_name EventCategoryDictionary

var _event_category_dictionary = {} 

func populate_dictionary(category_array: Array[EventCategory]):
	for cat in category_array:
		add_category(cat)
	
func add_category(category: EventCategory):
	var id = category.category_id
	if not has_category(id):
		_event_category_dictionary[category.category_id] = category
	
func has_category(category_id: String) -> bool:
	return _event_category_dictionary.has(category_id)
	
func get_category(category_id: String) -> EventCategory:
	return _event_category_dictionary.get(category_id)
