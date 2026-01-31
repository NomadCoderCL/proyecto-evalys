extends Control

@onready var start_button: Button = %StartButton
@onready var continue_button: Button = %ContinueButton
@onready var exit_button: Button = %ExitButton

func _ready() -> void:
	# Connect signals
	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	# Check if we can continue
	if not GameManager.has_save():
		continue_button.disabled = true

func _on_start_pressed() -> void:
	GameManager.start_new_game()

func _on_continue_pressed() -> void:
	GameManager.continue_game()

func _on_exit_pressed() -> void:
	GameManager.exit_game()
