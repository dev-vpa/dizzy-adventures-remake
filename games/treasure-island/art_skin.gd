class_name ArtSkin
extends RefCounted

## Runtime pixel skins for platforms, hazards, and NPCs on TI screens.

const TILES := "res://games/treasure-island/art/tiles/"
const HAZARDS := "res://games/treasure-island/art/hazards/"
const NPCS := "res://games/treasure-island/art/npc/"
const PROPS := "res://games/treasure-island/art/props/"

const GROUND_NAMES := {
	"Ground": true,
	"Floor": true,
}

const LEDGE_NAMES := {
	"Platform": true,
	"Ledge": true,
	"Balcony": true,
	"Bridge": true,
	"Roof": true,
	"BarrelStack": true,
	"Hut": true,
	"Counter": true,
	"RockBlock": true,
	"Boulder": true,
	"ShopFacade": true,
	"TreeStump": true,
}

## Collidable bodies that need a shaped prop rather than a repeated biome tile.
const BODY_PROPS := {
	"Hut": "hut",
	"Boulder": "boulder",
	"Rock": "boulder",
	"RockBlock": "boulder",
	"TreeStump": "stump",
}

## Long collidable surfaces with a dedicated repeatable material.
const BODY_TILES := {
	"Pier": "pier",
	"Bridge": "bridge",
	"Roof": "roof",
	"BarrelStack": "barrel_stack",
	"Counter": "counter",
}

## Node2D containers whose child named Visual is a shaped prop.
const NODE_VISUAL_PROPS := {
	"ShopFacade": "shop_facade",
}

## Standalone ColorRect décor → props/*.png.
const PROP_RECTS := {
	"BoatHull": "boat",
	"Motor": "motor",
	"Grave": "grave",
	"Totem": "totem",
	"HatchLid": "hatch",
	"BubbleA": "bubble",
	"BubbleB": "bubble",
	"BubbleC": "bubble",
	"Barrel": "barrel",
	"BarrelA": "barrel",
	"BarrelB": "barrel",
	"RockDecor": "rock",
	"Hut": "hut",
	"HutL": "hut",
	"HutR": "hut",
}

## Repeated decorative strips and gameplay glows → tiles/*.png.
const TILED_RECTS := {
	"Shelf": "shelf",
	"Counter": "counter",
	"BalconyDecor": "rail",
	"UpPad": "zone_glow_green",
	"DownPad": "zone_glow_green",
	"AscendPad": "zone_glow_blue",
}

## Legacy blocks superseded by richer backdrops or an integrated prop.
const HIDDEN_RECTS := {
	"Wall": true,
	"Sky": true,
	"Cave": true,
	"Cross": true,
	"GraveCross": true,
	"DoorVisual": true,
}


static func apply_screen(root: Node) -> void:
	var biome := _detect_biome(root)
	_skin_node(root, biome)


static func _detect_biome(root: Node) -> String:
	for child in root.get_children():
		if child.has_method("_apply_texture"):
			var script := child.get_script() as Script
			var script_path := script.resource_path if script != null else ""
			if script_path.contains("underwater_backdrop"):
				return "ocean"
			for candidate in ["tree", "cavern", "hut", "beach"]:
				if script_path.contains("%s_backdrop" % candidate):
					return candidate
		if "region" in child:
			var region: String = str(child.get("region"))
			if not region.is_empty():
				return region
	var sid := ScreenManager.current_screen_id
	if sid.begins_with("tree_"):
		return "tree"
	if sid.begins_with("ocean_") or sid.begins_with("underwater_"):
		return "ocean"
	if (
		sid.begins_with("cavern_")
		or sid.begins_with("bridge_cavern_")
		or sid.begins_with("mine_")
		or sid == "blackbeard_kitchen"
		or sid == "cave_entrance"
	):
		return "cavern"
	if sid == "shop_interior":
		return "hut"
	return "beach"


static func _tile_for_biome(biome: String, ledge: bool) -> String:
	var base := "sand"
	match biome:
		"tree":
			base = "dirt"
		"ocean":
			base = "sand"
		"cavern":
			base = "cave"
		"hut":
			base = "wood"
		_:
			base = "sand"
	if ledge:
		return "%s_ledge" % base
	return base


static func _skin_node(node: Node, biome: String) -> void:
	if node is StaticBody2D:
		_skin_static_body(node as StaticBody2D, biome)
	if node is Node2D and NODE_VISUAL_PROPS.has(String(node.name)):
		_skin_named_visual(node, NODE_VISUAL_PROPS[String(node.name)])
	if node is Area2D:
		var area := node as Area2D
		if "requires_snorkel" in area:
			_skin_water(area, biome)
		elif "hazard_label" in area or area.is_in_group("hazard_zone"):
			_skin_hazard(area)
		elif "npc_name" in area:
			_skin_npc(area)
	if node is ColorRect:
		_skin_color_rect(node as ColorRect)
	for child in node.get_children():
		_skin_node(child, biome)


static func _skin_static_body(body: StaticBody2D, biome: String) -> void:
	var body_name := String(body.name)
	var is_ground := GROUND_NAMES.has(body_name)
	var is_ledge := LEDGE_NAMES.has(body_name) or body_name.contains("Platform")
	if is_ledge:
		# Ledges sit in the walk gap — one-way so Dizzy is not wedged under them.
		_enable_one_way(body)
	if BODY_PROPS.has(body_name):
		_skin_body_visual(body, PROPS.path_join("%s.png" % BODY_PROPS[body_name]), false)
	elif BODY_TILES.has(body_name):
		_skin_body_visual(body, TILES.path_join("%s.png" % BODY_TILES[body_name]), true)
	elif is_ground or is_ledge:
		var tex_name := _tile_for_biome(biome, is_ledge and not is_ground)
		_skin_body_visual(body, TILES.path_join("%s.png" % tex_name), true)


static func _skin_named_visual(node: Node, prop_name: String) -> void:
	var visual := node.get_node_or_null("Visual")
	if visual is ColorRect:
		_skin_texture_rect(
			visual as ColorRect,
			PROPS.path_join("%s.png" % prop_name),
			false
		)


static func _skin_color_rect(rect: ColorRect) -> void:
	var rect_name := String(rect.name)
	if HIDDEN_RECTS.has(rect_name):
		rect.visible = false
	elif PROP_RECTS.has(rect_name):
		_skin_prop_rect(rect, PROP_RECTS[rect_name])
	elif TILED_RECTS.has(rect_name):
		_skin_tiled_rect(rect, TILED_RECTS[rect_name])


static func _skin_prop_rect(rect: ColorRect, prop_name: String) -> void:
	_skin_texture_rect(rect, PROPS.path_join("%s.png" % prop_name), false)


static func _skin_tiled_rect(rect: ColorRect, tile_name: String) -> void:
	_skin_texture_rect(rect, TILES.path_join("%s.png" % tile_name), true)


static func _skin_body_visual(body: StaticBody2D, path: String, tiled: bool) -> void:
	var visual := body.get_node_or_null("Visual")
	if visual is ColorRect:
		_skin_texture_rect(visual as ColorRect, path, tiled)


static func _skin_texture_rect(rect: ColorRect, path: String, tiled: bool) -> void:
	if not ResourceLoader.exists(path):
		return
	if rect.get_node_or_null("ArtTexture") != null:
		return
	var art := TextureRect.new()
	art.name = "ArtTexture"
	art.texture = load(path) as Texture2D
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_TILE if tiled else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if tiled:
		art.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	rect.color = Color(rect.color.r, rect.color.g, rect.color.b, 0.0)
	rect.add_child(art)
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


static func _enable_one_way(body: StaticBody2D) -> void:
	for child in body.get_children():
		if child is CollisionShape2D:
			var cs := child as CollisionShape2D
			cs.one_way_collision = true
			cs.one_way_collision_margin = 2.0


static func _skin_water(area: Area2D, biome: String) -> void:
	var visual := area.get_node_or_null("Visual")
	if not (visual is ColorRect):
		return
	if biome == "ocean":
		# The authored ocean backdrop already carries depth, shafts, and bubbles.
		(visual as ColorRect).visible = false
	else:
		_skin_tiled_rect(visual as ColorRect, "water")


static func _skin_hazard(area: Area2D) -> void:
	var label := "Trap"
	if "hazard_label" in area:
		label = str(area.get("hazard_label"))
	var file := "trap"
	var lower := label.to_lower()
	if "fish" in lower:
		file = "fish"
	elif "crab" in lower:
		file = "crab"
	elif "cuttle" in lower:
		file = "cuttlefish"
	var path := HAZARDS.path_join("%s.png" % file)
	var visual := area.get_node_or_null("Visual")
	if visual is ColorRect:
		# Keeping art inside Visual makes patrol movement and clear_flag visibility
		# move together with the collision instead of leaving a stale sprite behind.
		_skin_texture_rect(visual as ColorRect, path, false)


static func _skin_npc(area: Area2D) -> void:
	var npc_name := str(area.get("npc_name")).to_lower()
	var file := "shopkeeper"
	if "tax" in npc_name:
		file = "taxman"
	var path := NPCS.path_join("%s.png" % file)
	if not ResourceLoader.exists(path):
		return
	for child_name in ["BodyVisual", "HeadVisual"]:
		var node := area.get_node_or_null(child_name)
		if node:
			node.visible = false
	var existing := area.get_node_or_null("NpcSprite")
	if existing:
		return
	var sprite := Sprite2D.new()
	sprite.name = "NpcSprite"
	sprite.texture = load(path)
	sprite.centered = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = Vector2(0, -48)
	area.add_child(sprite)
