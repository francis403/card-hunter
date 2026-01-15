extends Node
## Might be better as a manager
## LockedContentController comes up, mark everything that is locked
## File comes up, load from metadata that is unlocked.
## ClassPicker page is open, If class is still locked hide it

@export_dir var weapons_path: String

var unlockable_content: Dictionary = {
	## ID -> bool
}

func _ready() -> void:
	_load_weapons_availability()
		

func _load_weapons_availability():
	var weapons_resources_paths: Array[String] = get_all_file_paths(weapons_path)
	for weapon_path in weapons_resources_paths:
		var weapon: PlayerClass = load(weapon_path)
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
			file_paths.append(file_path)  
		file_name = dir.get_next()  
	return file_paths
