extends Node

var REQUIRED_ACTIONS := {
	"ui_up": [
		{"type": InputEventKey, "keycode": KEY_W},
		{"type": InputEventKey, "keycode": KEY_UP}
	],
	"ui_down": [
		{"type": InputEventKey, "keycode": KEY_S},
		{"type": InputEventKey, "keycode": KEY_DOWN}
	],
	"ui_left": [
		{"type": InputEventKey, "keycode": KEY_A},
		{"type": InputEventKey, "keycode": KEY_LEFT}
	],
	"ui_right": [
		{"type": InputEventKey, "keycode": KEY_D},
		{"type": InputEventKey, "keycode": KEY_RIGHT}
	],
	"interact": [
		{"type": InputEventKey, "keycode": KEY_E}
	],
	"build": [
		{"type": InputEventKey, "keycode": KEY_B}
	],
	"toggle_inventory": [
		{"type": InputEventKey, "keycode": KEY_I},
		{"type": InputEventKey, "keycode": KEY_TAB}
	]
}

func _ready() -> void:
	ensure_actions()

func ensure_actions() -> void:
	for action_name in REQUIRED_ACTIONS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		_ensure_events(action_name, REQUIRED_ACTIONS[action_name])

func _ensure_events(action_name: String, events: Array) -> void:
	for ev_data in events:
		if not _event_exists(action_name, ev_data):
			var event := _create_event(ev_data)
			if event:
				InputMap.action_add_event(action_name, event)

func _event_exists(action_name: String, ev_data: Dictionary) -> bool:
	for existing in InputMap.action_get_events(action_name):
		if ev_data.get("type") == InputEventKey and existing is InputEventKey:
			if existing.keycode == ev_data.get("keycode"):
				return true
	return false

func _create_event(ev_data: Dictionary) -> InputEvent:
	if ev_data.get("type") == InputEventKey:
		var event := InputEventKey.new()
		event.keycode = ev_data.get("keycode")
		event.physical_keycode = ev_data.get("keycode")
		return event
	return null
