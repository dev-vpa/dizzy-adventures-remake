class_name GameScreen
extends Node2D

## Base flick-screen. Override exits in the editor or via @export.

@export var exit_left: String = ""
@export var exit_right: String = ""
@export var exit_up: String = ""
@export var exit_down: String = ""


func get_exits() -> Dictionary:
	var exits := {}
	if not exit_left.is_empty():
		exits["left"] = exit_left
	if not exit_right.is_empty():
		exits["right"] = exit_right
	if not exit_up.is_empty():
		exits["up"] = exit_up
	if not exit_down.is_empty():
		exits["down"] = exit_down
	return exits
