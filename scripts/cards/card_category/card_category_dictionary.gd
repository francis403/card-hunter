extends Node
class_name CardCategoryDictionary

var _card_category_dictionary = {} 

func populate_dictionary(category_array: Array[CardCategory]):
	for cat in category_array:
		add_category(cat)
	
func add_category(category: CardCategory):
	var id = category.category_id
	if not has_category(id):
		_card_category_dictionary[category.category_id] = category
	
func has_category(category_id: String) -> bool:
	return _card_category_dictionary.has(category_id)
	
func get_category(category_id: String) -> CardCategory:
	return _card_category_dictionary.get(category_id)
