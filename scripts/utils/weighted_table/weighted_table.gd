class_name WeightedTable

var items: Array[Dictionary] = []
var weight_sum = 0

func add_item(item, weight: int):
	items.append({"item": item, "weight": weight, "index": items.size()})
	weight_sum += weight

func remove_item(item_to_remove):
	items = items.filter(func (item): return item["item"] != item_to_remove)
	weight_sum = 0
	for item in items:
		weight_sum += item["weight"]

func remove_item_by_index(index: int):
	var _temp_item_weight: int = items[index]["weight"]
	items.remove_at(index)
	weight_sum -= _temp_item_weight
	var _new_index: int = 0
	for item in items:
		item["index"] = _new_index
		_new_index += 1

func is_empty() -> bool:
	return items.is_empty()

func pick_item(exclude: Array = []):
	return self.pick_dictionary(exclude)["item"]

func pick_dictionary(exclude: Array = []):
	var adjusted_items: Array[Dictionary] = items
	var adjusted_weight_sum = weight_sum
	if exclude.size() > 0:
		adjusted_items = []
		adjusted_weight_sum = 0
		for item in items:
			if item in items:
				if item["item"] in exclude:
					continue
				adjusted_items.append(item)
				adjusted_weight_sum += item["weight"]
	
	var chosen_weight = randi_range(1, adjusted_weight_sum)
	var iteration_sum = 0
	
	for item in adjusted_items:
		iteration_sum += item["weight"]
		if chosen_weight <= iteration_sum:
			return item
	return null
