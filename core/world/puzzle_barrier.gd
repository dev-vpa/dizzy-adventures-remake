extends StaticBody2D

## Collision + visual that clears when a WorldState flag becomes true.

@export var clear_flag: String = ""


func _ready() -> void:
	add_to_group("puzzle_barrier")
	if not WorldState.flag_changed.is_connected(_on_flag_changed):
		WorldState.flag_changed.connect(_on_flag_changed)
	_apply()


func _exit_tree() -> void:
	if WorldState.flag_changed.is_connected(_on_flag_changed):
		WorldState.flag_changed.disconnect(_on_flag_changed)


func _on_flag_changed(flag_id: String, _value: bool) -> void:
	if flag_id == clear_flag:
		_apply()


func _apply() -> void:
	var cleared := not clear_flag.is_empty() and WorldState.get_flag(clear_flag)
	visible = not cleared
	for child in get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).disabled = cleared
		elif child is CanvasItem:
			(child as CanvasItem).visible = not cleared
