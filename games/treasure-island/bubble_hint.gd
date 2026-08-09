extends Label

## Dig-bubbles hint — hides after ocean_bubbles, uses touch-aware copy.

@export var flag_id: String = "ocean_bubbles"
@export var visible_when_true: bool = false


func _ready() -> void:
	text = PlatformUI.hint_text(
		"Select Spade (Tab) → Use (U)\nto dig bubbles here",
		"Select Spade (tap slot) → Use\nto dig bubbles here"
	)
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
