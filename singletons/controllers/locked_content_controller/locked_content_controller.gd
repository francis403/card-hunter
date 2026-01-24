extends Node
## Might be better as a manager
## LockedContentController comes up, mark everything that is locked
## File comes up, load from metadata that is unlocked.
## ClassPicker page is open, If class is still locked hide it

@export_dir var weapons_path: String

var unlockable_content: Dictionary = {
	## ID -> bool
}

var _weapons_references: Array[PlayerClass] = []

func _ready() -> void:
	_load_weapons_availability()
		

## Do i really need to go through all the weapons every time?
func check_weapons_availability(_should_save: bool = false):
	for weapon in _weapons_references:
		var _weapon_id: String = weapon.player_class_name
		if is_unlocked(_weapon_id):
			continue
		if weapon.is_unlock_condition_encountered():
			self.unlock_content(weapon.player_class_name, _should_save)

func _load_weapons_availability():
	var weapons_resources_paths: Array[String] = get_all_file_paths(weapons_path)
	for weapon_path in weapons_resources_paths:
		var weapon: PlayerClass = load(weapon_path)
		_weapons_references.append(weapon)
		unlockable_content[weapon.player_class_name] = not weapon.start_locked

func is_unlocked(unlock_id: String) -> bool:
	return unlockable_content.get(unlock_id, true)

func unlock_content(
	unlock_id: String,
	_should_save: bool = true
):
	unlockable_content[unlock_id] = true
	File.meta_progress.add_unlocked_content(unlock_id)
	if _should_save:
		File.change_meta_progress()  # Save immediately

func get_all_file_paths(path: String) -> Array[String]:
	var file_paths: Array[String] = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = path + "/" + file_name
		if dir.current_is_dir():
			file_paths += get_all_file_paths(file_path)
		else:
			# In exported builds, .tres files become .tres.remap
			# Strip .remap suffix so load() can find the actual resource
			if file_path.ends_with(".remap"):
				file_path = file_path.substr(0, file_path.length() - 6)
			file_paths.append(file_path)
		file_name = dir.get_next()
	return file_paths
