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
	"Pier": true,
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

## Top-level ColorRect décor → props/*.png
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
	"RockDecor": "rock",
	"HutL": "hut",
	"HutR": "hut",
	"Shelf": "hatch",
	"Counter": "hatch",
	"Cave": "rock",
}


static func apply_screen(root: Node) -> void:
	var biome := _detect_biome(root)
	_skin_node(root, biome)


static func _detect_biome(root: Node) -> String:
	for child in root.get_children():
		if child.has_method("_apply_texture") and "region" in child:
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
		var n := String(node.name)
		var is_ground := GROUND_NAMES.has(n)
		var is_ledge := LEDGE_NAMES.has(n) or n.contains("Platform")
		if is_ground or is_ledge:
			_skin_platform(node as StaticBody2D, biome, is_ledge and not is_ground)
	if node is ColorRect and PROP_RECTS.has(String(node.name)):
		_skin_prop_rect(node as ColorRect, PROP_RECTS[String(node.name)])
	if node is Area2D and node.is_in_group("hazard_zone"):
		_skin_hazard(node as Area2D)
	if node is Area2D and ("npc_name" in node):
		_skin_npc(node as Area2D)
	# Shop door panel (child ColorRect on facade).
	if node is ColorRect and String(node.name) == "DoorVisual":
		_skin_prop_rect(node as ColorRect, "door")
	for child in node.get_children():
		_skin_node(child, biome)


static func _skin_prop_rect(rect: ColorRect, prop_name: String) -> void:
	var path := PROPS.path_join("%s.png" % prop_name)
	if not ResourceLoader.exists(path):
		return
	var parent := rect.get_parent()
	if parent == null:
		return
	var marker := "PropSprite_%s" % rect.name
	if parent.get_node_or_null(marker) != null:
		return
	var tex: Texture2D = load(path)
	var tw := float(tex.get_width())
	var th := float(tex.get_height())
	if tw <= 0.0 or th <= 0.0:
		return
	var grect := rect.get_global_rect()
	var w := grect.size.x
	var h := grect.size.y
	if w <= 0.0 or h <= 0.0:
		return
	var fit := minf(w / tw, h / th)
	# Prefer whole-pixel scale for chunky look.
	fit = maxf(1.0, floorf(fit + 0.001)) if fit >= 1.0 else fit
	var draw_w := tw * fit
	var draw_h := th * fit
	var sprite := Sprite2D.new()
	sprite.name = marker
	sprite.texture = tex
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(fit, fit)
	var top_left: Vector2
	if parent is Node2D:
		top_left = (parent as Node2D).to_local(grect.position)
	else:
		top_left = rect.position
	sprite.position = top_left + Vector2((w - draw_w) * 0.5, (h - draw_h) * 0.5)
	parent.add_child(sprite)
	rect.visible = false


static func _skin_platform(body: StaticBody2D, biome: String, ledge: bool) -> void:
	# Ledges sit in the walk gap — one-way so Dizzy is not wedged under them.
	if ledge:
		_enable_one_way(body)
	var visual := body.get_node_or_null("Visual")
	if visual == null or not (visual is ColorRect):
		return
	if body.get_node_or_null("VisualSprite") != null:
		return
	var rect := visual as ColorRect
	var tex_name := _tile_for_biome(biome, ledge)
	var path := TILES.path_join("%s.png" % tex_name)
	if not ResourceLoader.exists(path):
		return
	var tex: Texture2D = load(path)
	var w := absf(rect.offset_right - rect.offset_left)
	var h := absf(rect.offset_bottom - rect.offset_top)
	if w <= 0.0:
		w = rect.size.x
	if h <= 0.0:
		h = rect.size.y
	var sprite := Sprite2D.new()
	sprite.name = "VisualSprite"
	sprite.texture = tex
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	sprite.region_enabled = true
	sprite.region_rect = Rect2(0, 0, w, h)
	sprite.position = Vector2(
		minf(rect.offset_left, rect.offset_right),
		minf(rect.offset_top, rect.offset_bottom)
	)
	body.add_child(sprite)
	rect.visible = false


static func _enable_one_way(body: StaticBody2D) -> void:
	for child in body.get_children():
		if child is CollisionShape2D:
			var cs := child as CollisionShape2D
			cs.one_way_collision = true
			cs.one_way_collision_margin = 2.0


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
	if not ResourceLoader.exists(path):
		return
	var visual := area.get_node_or_null("Visual")
	if visual is ColorRect:
		(visual as ColorRect).visible = false
	var existing := area.get_node_or_null("HazardSprite")
	if existing:
		existing.queue_free()
	var sprite := Sprite2D.new()
	sprite.name = "HazardSprite"
	sprite.texture = load(path)
	sprite.centered = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var center := Vector2(256, 340)
	if "zone_center" in area:
		center = area.get("zone_center")
	sprite.position = center
	area.add_child(sprite)


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
		existing.queue_free()
	var sprite := Sprite2D.new()
	sprite.name = "NpcSprite"
	sprite.texture = load(path)
	sprite.centered = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = Vector2(0, -24)
	area.add_child(sprite)
