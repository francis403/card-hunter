extends Resource
class_name ValidationResult

## Whether the validation passed
@export var is_valid: bool = true

## Human-readable error messages
@export var errors: Array[String] = []

## Modules that failed validation
@export var invalid_modules: Array[CardModule] = []

func _init():
	is_valid = true
	errors = []
	invalid_modules = []

func add_error(error_message: String, module: CardModule = null):
	is_valid = false
	errors.append(error_message)
	if module and module not in invalid_modules:
		invalid_modules.append(module)

func clear():
	is_valid = true
	errors.clear()
	invalid_modules.clear()

func has_errors() -> bool:
	return not is_valid or errors.size() > 0
