extends Control

const DISCLAIMER := """Dizzy Adventures Remake

Unofficial, non-commercial fan project.
Not affiliated with or endorsed by Codemasters or the Oliver Twins.

\"Dizzy\", \"The Yolkfolk\" and all related characters and titles are
trademarks of Oliver Twins Limited and The Codemasters Software Company
Limited. All rights reserved."""

var _can_continue := false


func _ready() -> void:
	$MarginContainer/VBox/DisclaimerPanel/ScrollContainer/DisclaimerLabel.text = DISCLAIMER
	$MarginContainer/VBox/ContinueButton.disabled = true
	if PlatformUI.is_touch_device():
		$MarginContainer/VBox/ContinueButton.custom_minimum_size = Vector2(200, 48)
	$StartTimer.start(2.0)


func _unhandled_input(event: InputEvent) -> void:
	if _can_continue and (event.is_action_pressed("action") or event.is_action_pressed("ui_accept")):
		_continue()


func _on_continue_pressed() -> void:
	_continue()


func _on_start_timer_timeout() -> void:
	_can_continue = true
	$MarginContainer/VBox/ContinueButton.disabled = false
	$MarginContainer/VBox/ContinueButton.grab_focus()


func _continue() -> void:
	if not _can_continue:
		return
	GameManager.enter_gameplay()
