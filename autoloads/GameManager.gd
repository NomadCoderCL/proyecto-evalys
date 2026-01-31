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

func change_scene(path: String) -> void:
	# Small delay or transition logic could go here
	get_tree().change_scene_to_file(path)

func start_new_game() -> void:
	# Here we could reset global variables if we had any identifying the current run
	# For now, just deleting the save file if we wanted a "fresh" start might be too aggressive,
	# so we will just load the main scene. The player variables reset on _ready.
	change_scene("res://scenes/Main.tscn")

func continue_game() -> void:
	if has_save():
		change_scene("res://scenes/Main.tscn")
		# We need to defer the load until the scene is ready
		# A simple way is to wait a frame or use a signal, but for simplicity:
		await get_tree().process_frame
		await get_tree().process_frame
		load_game()
	else:
		notify_ui("No saved game found")

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func exit_game() -> void:
	get_tree().quit()
