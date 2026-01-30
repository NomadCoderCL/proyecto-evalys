extends Node2D

func _ready() -> void:
	# Try to load game logic
	if GameManager:
		GameManager.load_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if GameManager:
			GameManager.save_game()
