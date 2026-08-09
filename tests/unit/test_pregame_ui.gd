class_name TestPregameUi
extends RefCounted

const TestAssert := preload("res://tests/test_assert.gd")
const TI_CONFIG := preload("res://games/treasure-island/treasure_island_config.tres")

const MENU_BACKDROP := "res://shared/ui/art/menu_night.png"
const MENU_DIZZY := "res://shared/ui/art/menu_dizzy.png"
const MENU_THEME := "res://shared/ui/menu_theme.tres"
const VICTORY_BACKDROP := "res://shared/ui/art/victory_escape.png"


static func run() -> void:
	_assert_generated_assets()
	_assert_shared_menu_art()
	_assert_loading_screen()
	_assert_ti_title()
	_assert_win_screen()


static func _assert_generated_assets() -> void:
	for path in [
		MENU_BACKDROP,
		MENU_DIZZY,
		"res://shared/ui/art/boot_splash.png",
		VICTORY_BACKDROP,
		"res://games/treasure-island/art/icons/select_ti.png",
	]:
		TestAssert.true_(ResourceLoader.exists(path), "pre-game asset exists: %s" % path)
	TestAssert.eq(
		ProjectSettings.get_setting("application/boot_splash/image"),
		"res://shared/ui/art/boot_splash.png",
		"generated boot splash is configured"
	)
	TestAssert.ne(TI_CONFIG.icon, null, "Treasure Island has a generated select icon")
	if TI_CONFIG.icon != null:
		TestAssert.true_(
			TI_CONFIG.icon.resource_path.ends_with("select_ti.png"),
			"Treasure Island config uses select_ti.png"
		)


static func _assert_shared_menu_art() -> void:
	for scene_path in [
		"res://scenes/main_menu.tscn",
		"res://scenes/game_select.tscn",
		"res://scenes/loading_screen.tscn",
	]:
		var screen := _instantiate(scene_path)
		if screen == null:
			continue
		var backdrop := screen.get_node_or_null("Backdrop") as TextureRect
		TestAssert.ne(backdrop, null, "%s has pixel backdrop" % scene_path)
		if backdrop != null and backdrop.texture != null:
			TestAssert.eq(
				backdrop.texture.resource_path,
				MENU_BACKDROP,
				"%s uses shared night art" % scene_path
			)
		TestAssert.ne(screen.theme, null, "%s uses shared menu theme" % scene_path)
		if screen.theme != null:
			TestAssert.eq(screen.theme.resource_path, MENU_THEME, "%s theme path" % scene_path)
		for old_name in ["Background", "SkyGlow", "SandBar"]:
			TestAssert.eq(
				screen.get_node_or_null(old_name),
				null,
				"%s removes legacy %s block" % [scene_path, old_name]
			)
		screen.free()

	var main := _instantiate("res://scenes/main_menu.tscn")
	if main != null:
		var hero := main.get_node_or_null("MarginContainer/VBox/HeroHolder/DizzyHero") as TextureRect
		TestAssert.ne(hero, null, "main menu has Dizzy pixel art")
		if hero != null and hero.texture != null:
			TestAssert.eq(hero.texture.resource_path, MENU_DIZZY, "main menu uses front-facing Dizzy")
		var new_game := main.get_node("MarginContainer/VBox/NewGameButton") as Button
		TestAssert.true_(
			new_game.custom_minimum_size.y >= 44.0,
			"main menu primary action is touch-sized"
		)
		main.free()


static func _assert_loading_screen() -> void:
	var loading := _instantiate("res://scenes/loading_screen.tscn")
	if loading == null:
		return
	var strip := loading.get_node_or_null("LoadingStrip")
	TestAssert.ne(strip, null, "disclaimer has tape-loading strip")
	if strip != null and strip.has_method("set_progress"):
		strip.call("set_progress", 0.5)
		TestAssert.eq(strip.call("get_progress"), 0.5, "loading strip tracks progress")
		strip.call("set_progress", 1.0)
		TestAssert.eq(strip.call("get_progress"), 1.0, "loading strip reaches full progress")
		var inner := Rect2(4.0, 4.0, 252.0, 8.0)
		var last_rect: Rect2 = strip.call("_block_rect", inner, 15)
		TestAssert.eq(last_rect.end.x, inner.end.x, "last loading block reaches the inner edge")
	var button := loading.get_node("ContinueButton") as Button
	TestAssert.true_(
		button.custom_minimum_size.y >= 44.0,
		"disclaimer continue action is touch-sized"
	)
	TestAssert.ne(loading.get_node_or_null("InputHint"), null, "disclaimer has input hint")
	loading.free()


static func _assert_ti_title() -> void:
	var title := _instantiate("res://games/treasure-island/title_screen.tscn")
	if title == null:
		return
	TestAssert.ne(title.theme, null, "TI title uses shared menu theme")
	TestAssert.ne(title.get_node_or_null("Center/TitlePanel"), null, "TI title has pixel panel")
	var hero := (
		title.get_node_or_null(
			"Center/TitlePanel/Margin/VBox/TitleRow/HeroHolder/DizzyHero"
		)
		as TextureRect
	)
	TestAssert.ne(hero, null, "TI title has Dizzy art")
	if hero != null and hero.texture != null:
		TestAssert.eq(hero.texture.resource_path, MENU_DIZZY, "TI title uses front-facing Dizzy")
	for name in ["ContinueButton", "NewGameButton", "BackButton"]:
		var path := "Center/TitlePanel/Margin/VBox/%s" % name
		var button := title.get_node(path) as Button
		TestAssert.true_(
			button.custom_minimum_size.y >= 44.0,
			"TI title %s is touch-sized" % name
		)
	title.free()


static func _assert_win_screen() -> void:
	var win := _instantiate("res://scenes/win_screen.tscn")
	if win == null:
		return
	var backdrop := win.get_node_or_null("Backdrop") as TextureRect
	TestAssert.ne(backdrop, null, "win screen replaces the flat backdrop with pixel art")
	if backdrop != null and backdrop.texture != null:
		TestAssert.eq(
			backdrop.texture.resource_path,
			VICTORY_BACKDROP,
			"win screen uses the generated escape tableau"
		)
	TestAssert.ne(win.theme, null, "win screen uses shared menu theme")
	TestAssert.ne(win.get_node_or_null("Center/VictoryPanel"), null, "win screen has a framed panel")
	TestAssert.eq(win.find_children("*", "ColorRect", true, false).size(), 0, "win screen has no flat blocks")
	var button := win.get_node("Center/VictoryPanel/Margin/VBox/MenuButton") as Button
	TestAssert.true_(button.custom_minimum_size.y >= 44.0, "win screen action is touch-sized")
	win.free()


static func _instantiate(path: String) -> Control:
	var packed := load(path) as PackedScene
	TestAssert.ne(packed, null, "pre-game scene loads: %s" % path)
	if packed == null:
		return null
	return packed.instantiate() as Control
