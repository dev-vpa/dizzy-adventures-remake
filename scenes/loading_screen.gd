extends Control

const SUMMARY := (
	"Unofficial, non-commercial fan project.\n"
	+ "Not affiliated with or endorsed by Codemasters or the Oliver Twins."
)

const TRADEMARK := (
	"\"Dizzy\", \"The Yolkfolk\" and all related characters and titles are "
	+ "trademarks of Oliver Twins Limited and The Codemasters Software Company "
	+ "Limited. All rights reserved."
)

var _can_continue := false

@onready var _summary_label: Label = $ContentMargin/VBox/DisclaimerPanel/TextVBox/Summary
@onready var _trademark_label: Label = $ContentMargin/VBox/DisclaimerPanel/TextVBox/Trademark
@onready var _continue_button: Button = $ContinueButton


func _ready() -> void:
	_summary_label.text = SUMMARY
	_trademark_label.text = TRADEMARK
	_continue_button.disabled = true
	if PlatformUI.is_touch_device():
		_continue_button.custom_minimum_size = Vector2(208, PlatformUI.MIN_TOUCH_SIZE)
		_continue_button.offset_left = -116.0
		_continue_button.offset_right = 116.0
		_continue_button.offset_top = -68.0
	$StartTimer.start(2.0)


func _unhandled_input(event: InputEvent) -> void:
	if _can_continue and (event.is_action_pressed("action") or event.is_action_pressed("ui_accept")):
		_continue()


func _on_continue_pressed() -> void:
	_continue()


func _on_start_timer_timeout() -> void:
	_can_continue = true
	_continue_button.disabled = false
	_continue_button.grab_focus()


func _continue() -> void:
	if not _can_continue:
		return
	GameManager.enter_gameplay()
