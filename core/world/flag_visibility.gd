extends CanvasItem

## Shows or hides based on a WorldState puzzle flag.

@export var flag_id: String = ""
@export var visible_when_true: bool = true


func _ready() -> void:
	if not WorldState.flag_changed.is_connected(_on_flag_changed):
		WorldState.flag_changed.connect(_on_flag_changed)
	_apply()


func _exit_tree() -> void:
	if WorldState.flag_changed.is_connected(_on_flag_changed):
		WorldState.flag_changed.disconnect(_on_flag_changed)


func _on_flag_changed(changed_id: String, _value: bool) -> void:
	if changed_id == flag_id:
		_apply()


func _apply() -> void:
	if flag_id.is_empty():
		return
	var on := WorldState.get_flag(flag_id)
	visible = on if visible_when_true else not on
