extends Node

## Window setup: maximize to current screen; stretch settings handle scaling + letterbox.


func _ready() -> void:
	call_deferred("_setup_window")


func _setup_window() -> void:
	var screen_index := DisplayServer.window_get_current_screen()
	DisplayServer.window_set_current_screen(screen_index)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
