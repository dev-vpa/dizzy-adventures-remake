extends Control

## Simple win banner after escaping Treasure Island.

@onready var _title: Label = $Center/VBox/Title
@onready var _menu_button: Button = $Center/VBox/MenuButton


func _ready() -> void:
	if _title:
		_title.text = "You escaped!\nTreasure Island Dizzy"
	if _menu_button:
		_menu_button.pressed.connect(_on_menu)
		_menu_button.grab_focus()


func _on_menu() -> void:
	GameManager.quit_to_main_menu()
