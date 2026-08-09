extends Control

## Win banner after escaping Treasure Island.

@onready var _title: Label = $Center/VictoryPanel/Margin/VBox/Title
@onready var _subtitle: Label = $Center/VictoryPanel/Margin/VBox/Subtitle
@onready var _menu_button: Button = $Center/VictoryPanel/Margin/VBox/MenuButton


func _ready() -> void:
	if _title:
		_title.text = "You escaped!"
	if _subtitle:
		_subtitle.text = "Treasure Island Dizzy\n30 coins paid — the Taxman lets you leave."
	if _menu_button:
		_menu_button.pressed.connect(_on_menu)
		if PlatformUI.is_touch_device():
			_menu_button.custom_minimum_size = Vector2(200, PlatformUI.MIN_TOUCH_SIZE)
		_menu_button.grab_focus()


func _on_menu() -> void:
	AudioManager.play_sfx("ui_click")
	GameManager.quit_to_main_menu()
