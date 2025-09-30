extends RefCounted
class_name CardModuleValidator

## Validates a complete set of card modules
static func validate_card_modules(modules: Array[CardModule]) -> ValidationResult:
	var result = ValidationResult.new()
	
	if modules.is_empty():
		result.add_error("Card must have at least one module")
		return result
	
	# Validate each module's placement rules
	for i in range(modules.size()):
		var module = modules[i]
		if not validate_module_placement(module, i, modules):
			var placement_errors = get_placement_errors(module, i, modules)
			for error in placement_errors:
				result.add_error(error, module)
	
	# Validate module instance limits
	validate_instance_limits(modules, result)
	
	return result

## Validates if a module can be placed at a specific position
static func validate_module_placement(module: CardModule, position: int, all_modules: Array[CardModule]) -> bool:
	if not module:
		return false
	
	var module_count = all_modules.size()
	var is_first = position == 0
	var is_last = position == module_count - 1
	
	match module.placement_rule:
		Constants.ModulePlacementRule.CANNOT_BE_FIRST:
			return not is_first
		Constants.ModulePlacementRule.CANNOT_BE_LAST:
			return not is_last
		Constants.ModulePlacementRule.MUST_BE_FIRST:
			return is_first
		Constants.ModulePlacementRule.MUST_BE_LAST:
			return is_last
		Constants.ModulePlacementRule.NEEDS_ATTACK_AFTER:
			return not is_last and _has_attack_module_after(position, all_modules)
		Constants.ModulePlacementRule.NEEDS_ATTACK_BEFORE:
			return not is_first and _has_attack_module_before(position, all_modules)
		Constants.ModulePlacementRule.CANNOT_FOLLOW_SAME_TYPE:
			return not _has_same_type_before(module, position, all_modules)
	return true

## Gets detailed error messages for placement violations
static func get_placement_errors(module: CardModule, position: int, all_modules: Array[CardModule]) -> Array[String]:
	var errors: Array[String] = []
	var module_count = all_modules.size()
	var is_first = position == 0
	var is_last = position == module_count - 1
	
	match module.placement_rule:
		Constants.ModulePlacementRule.CANNOT_BE_FIRST:
			if is_first:
				errors.append("'%s' cannot be the first module" % module.title)
		Constants.ModulePlacementRule.CANNOT_BE_LAST:
			if is_last:
				errors.append("'%s' cannot be the last module" % module.title)
		Constants.ModulePlacementRule.MUST_BE_FIRST:
			if not is_first:
				errors.append("'%s' must be the first module" % module.title)
		Constants.ModulePlacementRule.MUST_BE_LAST:
			if not is_last:
				errors.append("'%s' must be the last module" % module.title)
		Constants.ModulePlacementRule.NEEDS_ATTACK_AFTER:
			if is_last or not _has_attack_module_after(position, all_modules):
				errors.append("'%s' requires an attack module after it" % module.title)
		Constants.ModulePlacementRule.NEEDS_ATTACK_BEFORE:
			if is_first or not _has_attack_module_before(position, all_modules):
				errors.append("'%s' requires an attack module before it" % module.title)
		Constants.ModulePlacementRule.CANNOT_FOLLOW_SAME_TYPE:
			if _has_same_type_before(module, position, all_modules):
				errors.append("'%s' cannot follow another module of the same type" % module.title)
	
	return errors

## Validates instance limits per card
static func validate_instance_limits(modules: Array[CardModule], result: ValidationResult):
	var type_counts: Dictionary = {}
	
	for module in modules:
		# Count instances by each type the module declares
		for module_type in module.types:
			if not type_counts.has(module_type):
				type_counts[module_type] = 0
			type_counts[module_type] += 1
			
			if module.max_instances_per_card > 0 and type_counts[module_type] > module.max_instances_per_card:
				result.add_error("Too many '%s' modules (max: %d)" % [module.title, module.max_instances_per_card], module)
				break  # Only report once per module

## Helper: Check if there's an attack module after the given position
static func _has_attack_module_after(position: int, modules: Array[CardModule]) -> bool:
	for i in range(position + 1, modules.size()):
		if _is_attack_module(modules[i]):
			return true
	return false

## Helper: Check if there's an attack module before the given position
static func _has_attack_module_before(position: int, modules: Array[CardModule]) -> bool:
	for i in range(position):
		if _is_attack_module(modules[i]):
			return true
	return false

## Helper: Check if there's the same module type before the given position
static func _has_same_type_before(module: CardModule, position: int, modules: Array[CardModule]) -> bool:
	for i in range(position):
		var previous_module = modules[i]
		# Check if any types overlap between the modules
		for module_type in module.types:
			if module_type in previous_module.types:
				return true
	return false

## Helper: Check if there's a specific module type before the given position
static func _has_type_before(type_name: String, position: int, modules: Array[CardModule]) -> bool:
	for i in range(position):
		if type_name in modules[i].types:
			return true
	return false

## Helper: Check if there's a specific module type after the given position
static func _has_type_after(type_name: String, position: int, modules: Array[CardModule]) -> bool:
	for i in range(position + 1, modules.size()):
		if type_name in modules[i].types:
			return true
	return false

## Helper: Check if a module is an attack module
static func _is_attack_module(module: CardModule) -> bool:
	# Check if module has "attack" type
	return module and "attack" in module.types

## Helper: Check if a module matches a specific type
static func _is_module_type(module: CardModule, type_name: String) -> bool:
	# Check if the type is in the module's types array
	return type_name in module.types
	
