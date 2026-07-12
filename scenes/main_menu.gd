extends Control


func _ready() -> void:
	$MarginContainer/VBox/NewGameButton.grab_focus()


func _on_new_game_pressed() -> void:
	GameManager.show_game_select()


func _on_quit_pressed() -> void:
	get_tree().quit()
