class_name ItemSprite
extends Node2D

## Procedural pixel icon for world pickups.

const GRID := 14

var icon_id: String = "default"
var _pixel_size: float = 2.5
var _time: float = 0.0
var bob_enabled: bool = true


func _ready() -> void:
	set_process(true)


func configure(item_id: String) -> void:
	icon_id = ItemCatalog.get_icon_id(item_id)
	_pixel_size = 1.5
	queue_redraw()


func configure_for_world(item_id: String) -> void:
	icon_id = ItemCatalog.get_icon_id(item_id)
	_pixel_size = 2.5
	bob_enabled = true
	queue_redraw()


func _process(delta: float) -> void:
	if bob_enabled:
		_time += delta
		queue_redraw()


func _draw() -> void:
	var bob := sin(_time * 3.0) * 1.5 if bob_enabled else 0.0
	var content := Vector2(GRID * _pixel_size, GRID * _pixel_size)
	var area := Rect2(Vector2(-content.x * 0.5, -content.y * 0.72 + bob), content)
	ItemIconDraw.draw_icon(self, icon_id, area, _pixel_size, true)
