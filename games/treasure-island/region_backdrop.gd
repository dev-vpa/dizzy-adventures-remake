extends Node2D

## Full-screen 512×384 PNG backdrop for a TI biome (nearest-neighbor).

const BACKDROPS_PATH := "res://games/treasure-island/art/backdrops/"

@export_enum("beach", "tree", "ocean", "cavern", "hut") var region: String = "beach"

var _sprite: Sprite2D


func _ready() -> void:
	z_index = -10
	_sprite = Sprite2D.new()
	_sprite.centered = false
	_sprite.position = Vector2.ZERO
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_sprite)
	_apply_texture()


func _apply_texture() -> void:
	if _sprite == null:
		return
	var path := BACKDROPS_PATH.path_join("%s.png" % region)
	if not ResourceLoader.exists(path):
		push_error("RegionBackdrop: missing %s" % path)
		return
	_sprite.texture = load(path) as Texture2D
