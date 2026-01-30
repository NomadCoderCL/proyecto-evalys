extends Node

signal notify(message: String)

const SAVE_PATH = "user://savegame.json"

func _ready() -> void:
	if Config and Config.has_method("ensure_actions"):
		Config.ensure_actions()

func notify_ui(message: String) -> void:
	notify.emit(message)

func save_game() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
		
	var data = player.get_data()
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		print("Game Saved")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_text)
		if error == OK:
			var data = json.get_data()
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.set_data(data)
				print("Game Loaded")
