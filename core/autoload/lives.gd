extends Node

## Player lives per active game (configured from GameConfig).

signal lives_changed

var max_lives: int = 1
var current_lives: int = 1


func configure(starting_lives: int) -> void:
	max_lives = maxi(starting_lives, 1)
	current_lives = max_lives
	lives_changed.emit()


func reset() -> void:
	current_lives = max_lives
	lives_changed.emit()


func lose_life() -> bool:
	current_lives = maxi(current_lives - 1, 0)
	lives_changed.emit()
	return current_lives <= 0
