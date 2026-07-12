extends Node

## Collectible counter per active game (from GameConfig).

signal collectibles_changed

var collectible_name: String = ""
var total: int = 0
var collected: int = 0


func configure(name: String, goal_total: int) -> void:
	collectible_name = name
	total = maxi(goal_total, 0)
	reset()


func reset() -> void:
	collected = 0
	collectibles_changed.emit()


func try_collect(_item_id: String = "coin") -> bool:
	if total > 0 and collected >= total:
		return false
	collected += 1
	collectibles_changed.emit()
	return true


func get_label() -> String:
	if collectible_name.is_empty():
		return "%d/%d" % [collected, total]
	return "%s: %d/%d" % [collectible_name.capitalize(), collected, total]
