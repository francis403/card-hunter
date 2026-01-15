extends Resource

## Holds info between games.
## Should only update on game comleted, no matter if defeat or victory
class_name MetaProgress

const SAVE_FILE_ID: String = "meta_progress"

var number_of_games_completed_successfully: int = 0
var number_of_games_completed_unsuccessfully: int = 0
var number_of_bosses_defeated: int = 0
var number_of_cards_forged: int = 0
var unlocked_content: Dictionary = {}

func update_games_completed(_successfully: bool):
	if _successfully:
		number_of_games_completed_successfully += 1
	else:
		number_of_games_completed_unsuccessfully += 1

func update_bosses_defeated():
	number_of_bosses_defeated += 1
	File.change_meta_progress()

func get_meta_progress() -> Dictionary:
	var _result: Dictionary = {
		"nr_victorious_games": number_of_games_completed_successfully,
		"nr_lost_games": number_of_games_completed_successfully,
		"nr_bosses_defeated": number_of_bosses_defeated,
		"nr_cards_forged": number_of_cards_forged,
		"unlocked_content": unlocked_content
	}
	return _result

func load_meta_progress(
	_save_file: Dictionary
):
	if _save_file.has("nr_victorious_games"):
		self.number_of_games_completed_successfully = _save_file["nr_victorious_games"]
	if _save_file.has("nr_lost_games"):
		self.number_of_games_completed_successfully = _save_file["nr_lost_games"]
	if _save_file.has("nr_bosses_defeated"):
		self.number_of_bosses_defeated = _save_file["nr_bosses_defeated"]
	if _save_file.has("nr_cards_forged"):
		self.number_of_cards_forged = _save_file["nr_cards_forged"]
	if _save_file.has("unlocked_content"):
		_load_unlocked_content(_save_file["unlocked_content"])

func add_unlocked_content(content_id: String):
	unlocked_content[content_id] = true
	
## TODO: on game load we need to get the LockedContentController populated
func _load_unlocked_content(_dict: Dictionary):
	for key in _dict.keys():
		LockedContentController.unlockable_content[key] = true
	## after loading the game we update it again. This can't be smart right?
	LockedContentController.check_weapons_availability()
	
