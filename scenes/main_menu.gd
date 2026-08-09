extends Control

var _time := 0.0

@onready var _hero: TextureRect = $MarginContainer/VBox/HeroHolder/DizzyHero


func _ready() -> void:
	$MarginContainer/VBox/QuitButton.visible = PlatformUI.show_desktop_quit()
	if PlatformUI.is_touch_device():
		for button: Button in [
			$MarginContainer/VBox/NewGameButton,
			$MarginContainer/VBox/QuitButton,
		]:
			button.custom_minimum_size = Vector2(464, PlatformUI.MIN_TOUCH_SIZE)
	$MarginContainer/VBox/NewGameButton.grab_focus()


func _process(delta: float) -> void:
	_time += delta
	_hero.position.y = 2.0 + roundf(sin(_time * 2.2) * 4.0)


func _on_new_game_pressed() -> void:
	GameManager.show_game_select()


func _on_quit_pressed() -> void:
	get_tree().quit()
