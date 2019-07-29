extends Node

const _SAVE_COMPRESSION_MODE = File.COMPRESSION_DEFLATE  
const PREFERENCES_FILE_NAME = "user://EmanQuestPreferences.dat"

static func save_preferences(data):
	var serialized_data = to_json(data)
	var save_game = File.new()
	save_game.open_compressed(PREFERENCES_FILE_NAME, File.WRITE, _SAVE_COMPRESSION_MODE)	
	save_game.store_line(serialized_data)
	save_game.close()

static func load_preferences():
	var save_game = File.new()
	
	if not save_game.file_exists(PREFERENCES_FILE_NAME):
		return # First run - preferences don't exist yet
	
	save_game.open_compressed(PREFERENCES_FILE_NAME, File.READ, _SAVE_COMPRESSION_MODE)
	
	var data = parse_json(save_game.get_line())
	save_game.close()
	return data