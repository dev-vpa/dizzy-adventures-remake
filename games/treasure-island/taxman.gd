extends "res://core/interactables/npc.gd"

## Taxman — win when boat is ready and all coins collected.


func try_interact() -> bool:
	if not _player_near:
		return false
	if not WorldState.get_flag("boat_ready"):
		_show_message("Come back when your boat is ready.")
		return true
	if Collectibles.collected < Collectibles.total:
		_show_message(
			"I need all %d coins. You have %d."
			% [Collectibles.total, Collectibles.collected]
		)
		return true
	_show_message("Fare paid! You escape the island!")
	WorldState.set_flag("escaped")
	var tree := get_tree()
	if tree:
		tree.create_timer(0.9).timeout.connect(_on_win_delay, CONNECT_ONE_SHOT)
	else:
		GameManager.declare_win()
	return true


func _on_win_delay() -> void:
	GameManager.declare_win()


func _show_message(text: String) -> void:
	message = text
	if _message_label:
		_message_label.text = text
	if _bubble:
		_bubble.visible = true
	_update_hint()
