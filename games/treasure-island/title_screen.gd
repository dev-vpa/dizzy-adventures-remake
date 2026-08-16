extends Control

## Treasure Island title — New Game / Continue after disclaimer.

var _time := 0.0

@onready var _backdrop: TextureRect = $Backdrop
@onready var _fallback: ColorRect = $FallbackSky
@onready var _continue_btn: Button = $Center/TitlePanel/Margin/VBox/ContinueButton
@onready var _new_btn: Button = $Center/TitlePanel/Margin/VBox/NewGameButton
@onready var _back_btn: Button = $Center/TitlePanel/Margin/VBox/BackButton
@onready var _hero: TextureRect = $Center/TitlePanel/Margin/VBox/TitleRow/HeroHolder/DizzyHero
@onready var _input_hint: Label = $Center/TitlePanel/Margin/VBox/InputHint


func _ready() -> void:
	_load_backdrop()
	AudioManager.play_music()
	var game_id := ""
	if GameManager.active_config:
		game_id = GameManager.active_config.id
	var can_continue := SaveGame.has_save(game_id)
	_continue_btn.disabled = not can_continue
	_continue_btn.pressed.connect(_on_continue)
	_new_btn.pressed.connect(_on_new)
	_back_btn.pressed.connect(_on_back)
	_input_hint.text = PlatformUI.hint_text("Esc — Back", "Tap a button to continue")
	var is_touch := PlatformUI.is_touch_device()
	_input_hint.visible = not is_touch
	if is_touch:
		for btn in [_continue_btn, _new_btn, _back_btn]:
			btn.custom_minimum_size = Vector2(464, PlatformUI.MIN_TOUCH_SIZE)
	if can_continue:
		_continue_btn.grab_focus()
	else:
		_new_btn.grab_focus()


func _process(delta: float) -> void:
	_time += delta
	_hero.position.y = 4.0 + roundf(sin(_time * 2.0) * 4.0)


func _load_backdrop() -> void:
	var path := "res://games/treasure-island/art/backdrops/beach.png"
	if ResourceLoader.exists(path):
		_backdrop.texture = load(path) as Texture2D
		_fallback.visible = false
	else:
		_backdrop.visible = false
		_fallback.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back()


func _on_continue() -> void:
	AudioManager.play_sfx("ui_click")
	GameManager.begin_continue_game()


func _on_new() -> void:
	AudioManager.play_sfx("ui_click")
	GameManager.begin_new_game()


func _on_back() -> void:
	AudioManager.play_sfx("ui_click")
	GameManager.show_game_select()
