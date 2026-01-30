extends Node

const REQUIRED_ACTIONS := {
	"ui_up": [
		{"type": InputEventKey, "keycode": Key.W},
		{"type": InputEventKey, "keycode": Key.UP}
	],
	"ui_down": [
		{"type": InputEventKey, "keycode": Key.S},
		{"type": InputEventKey, "keycode": Key.DOWN}
	],
	"ui_left": [
		{"type": InputEventKey, "keycode": Key.A},
		{"type": InputEventKey, "keycode": Key.LEFT}
	],
	"ui_right": [
		{"type": InputEventKey, "keycode": Key.D},
		{"type": InputEventKey, "keycode": Key.RIGHT}
	],
	"interact": [
		{"type": InputEventKey, "keycode": Key.E}
	],
	"build": [
		{"type": InputEventKey, "keycode": Key.B}
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
