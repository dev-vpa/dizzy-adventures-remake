extends CanvasLayer

## On-screen buttons for touch devices (Android / mobile web).

const HELD_ACTIONS := ["move_left", "move_right"]

var _held: Array[String] = []


func _ready() -> void:
	visible = PlatformUI.is_touch_device()
	if not visible:
		set_process(false)


func _process(_delta: float) -> void:
	for action in _held:
		Input.action_press(action)


func _tap_action(action: String) -> void:
	var press := InputEventAction.new()
	press.action = action
	press.pressed = true
	Input.parse_input_event(press)
	var release := InputEventAction.new()
	release.action = action
	release.pressed = false
	Input.parse_input_event(release)


func _hold_start(action: String) -> void:
	if action not in _held:
		_held.append(action)
	Input.action_press(action)


func _hold_end(action: String) -> void:
	_held.erase(action)
	Input.action_release(action)


func _on_left_down() -> void:
	_hold_start("move_left")


func _on_left_up() -> void:
	_hold_end("move_left")


func _on_right_down() -> void:
	_hold_start("move_right")


func _on_right_up() -> void:
	_hold_end("move_right")


func _on_jump_pressed() -> void:
	_tap_action("jump")


func _on_action_pressed() -> void:
	for node in get_tree().get_nodes_in_group("player"):
		if node.has_method("request_action"):
			node.call("request_action")
	_tap_action("action")
