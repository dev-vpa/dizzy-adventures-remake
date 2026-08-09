class_name ItemSprite
extends Node2D

## World / HUD item icon — PNG from TI art folder when present, else procedural.

const GRID := 14
const ITEMS_PATH := "res://games/treasure-island/art/items/"

var icon_id: String = "default"
var _pixel_size: float = 2.5
var _time: float = 0.0
var bob_enabled: bool = true
var _texture: Texture2D


func _ready() -> void:
	set_process(true)
	_load_texture()


func configure(item_id: String) -> void:
	icon_id = ItemCatalog.get_icon_id(item_id)
	_pixel_size = 1.5
	_load_texture()
	queue_redraw()


func configure_for_world(item_id: String) -> void:
	icon_id = ItemCatalog.get_icon_id(item_id)
	_pixel_size = 2.5
	bob_enabled = true
	_load_texture()
	queue_redraw()


func _load_texture() -> void:
	_texture = null
	var path := ITEMS_PATH.path_join("%s.png" % icon_id)
	if not ResourceLoader.exists(path):
		path = ITEMS_PATH.path_join("%s.png" % "default")
	if ResourceLoader.exists(path):
		_texture = load(path) as Texture2D


func _process(delta: float) -> void:
	if bob_enabled:
		_time += delta
		queue_redraw()


func _draw() -> void:
	var bob := sin(_time * 3.0) * 1.5 if bob_enabled else 0.0
	if _texture != null:
		var tw := float(_texture.get_width())
		var th := float(_texture.get_height())
		var scale := _pixel_size * (GRID / 16.0) * (16.0 / tw) * 2.2
		var size := Vector2(tw * scale, th * scale)
		var pos := Vector2(-size.x * 0.5, -size.y * 0.72 + bob)
		draw_texture_rect(_texture, Rect2(pos, size), false)
		return
	var content := Vector2(GRID * _pixel_size, GRID * _pixel_size)
	var area := Rect2(Vector2(-content.x * 0.5, -content.y * 0.72 + bob), content)
	ItemIconDraw.draw_icon(self, icon_id, area, _pixel_size, true)
