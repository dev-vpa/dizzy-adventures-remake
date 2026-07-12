extends Area2D

## World pickup. Player presses action (E / Enter / Pick) while overlapping.

@export var item_id: String = "placeholder_item"
@export var display_name: String = "Item"
@export var is_collectible: bool = false
@export var world_id: String = ""

@onready var item_sprite: ItemSprite = $ItemSprite
@onready var _hint: Label = $HintLabel

var _player_near := false


func _ready() -> void:
	add_to_group("pickup")
	var id := _get_world_id()
	if WorldState.is_collected(id):
		queue_free()
		return
	if not is_collectible and Inventory.has_item(item_id):
		queue_free()
		return
	if item_sprite:
		item_sprite.configure_for_world(item_id)
	_update_hint()


func _process(_delta: float) -> void:
	_update_hint()


func _update_hint() -> void:
	if _hint == null:
		return
	var show := _player_near
	if not is_collectible:
		show = show and not Inventory.is_full()
	elif Collectibles.total > 0 and Collectibles.collected >= Collectibles.total:
		show = false
	if PlatformUI.is_touch_device():
		_hint.text = "Pick"
	else:
		_hint.text = "E"
	_hint.visible = show


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_near = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_near = false


func try_pick_up() -> bool:
	if is_collectible:
		if Collectibles.try_collect(item_id):
			WorldState.mark_collected(_get_world_id())
			queue_free()
			return true
		return false
	if Inventory.try_pick_up(item_id):
		WorldState.mark_collected(_get_world_id())
		queue_free()
		return true
	return false


func _get_world_id() -> String:
	if not world_id.is_empty():
		return world_id
	if ScreenManager.current_screen_id.is_empty():
		return ""
	return "%s/%s" % [ScreenManager.current_screen_id, name]
