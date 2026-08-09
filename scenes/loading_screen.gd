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
@onready var _loading_strip: LoadingStrip = $LoadingStrip
@onready var _input_hint: Label = $InputHint
@onready var _start_timer: Timer = $StartTimer


func _ready() -> void:
	_summary_label.text = SUMMARY
	_trademark_label.text = TRADEMARK
	_continue_button.disabled = true
	_loading_strip.set_progress(0.0)
	_input_hint.text = PlatformUI.hint_text("Enter — Continue", "Tap Continue when ready")
	if PlatformUI.is_touch_device():
		_continue_button.custom_minimum_size = Vector2(416, PlatformUI.MIN_TOUCH_SIZE)
		_continue_button.offset_left = -116.0
		_continue_button.offset_right = 116.0
		_continue_button.offset_top = -68.0
	_start_timer.start(2.0)


func _process(_delta: float) -> void:
	if _start_timer.is_stopped():
		_loading_strip.set_progress(1.0)
		return
	var duration := maxf(_start_timer.wait_time, 0.001)
	_loading_strip.set_progress(1.0 - _start_timer.time_left / duration)


func _unhandled_input(event: InputEvent) -> void:
	if _can_continue and (event.is_action_pressed("action") or event.is_action_pressed("ui_accept")):
		_continue()


func _on_continue_pressed() -> void:
	_continue()


func _on_start_timer_timeout() -> void:
	_can_continue = true
	_loading_strip.set_progress(1.0)
	set_process(false)
	_continue_button.disabled = false
	_continue_button.grab_focus()


func _continue() -> void:
	if not _can_continue:
		return
	AudioManager.play_sfx("ui_click")
	# TI title (New Game / Continue); other games go straight in.
	if GameManager.active_config and GameManager.active_config.id == "treasure-island":
		GameManager.show_title_screen()
	else:
		GameManager.begin_new_game()
