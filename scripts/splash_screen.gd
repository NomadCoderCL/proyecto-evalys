extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Start the intro animation automatically
	animation_player.play("intro")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "intro":
		GameManager.change_scene("res://scenes/MainMenu.tscn")
