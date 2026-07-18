class_name TestItemCatalog
extends RefCounted

const TestAssert := preload("res://tests/test_assert.gd")
const ItemCatalogScript := preload("res://core/items/item_catalog.gd")

static func run() -> void:
	TestAssert.eq(ItemCatalogScript.get_display_name("snorkel"), "Snorkel", "snorkel display name")
	TestAssert.eq(ItemCatalogScript.get_display_name("glass_sword"), "Sharp Glass Sword", "sword display name")
	TestAssert.eq(ItemCatalogScript.get_icon_id("coin"), "coin", "coin icon id")
	var unknown := "unknown_item_xyz"
	TestAssert.eq(
		ItemCatalogScript.get_display_name(unknown),
		unknown.capitalize(),
		"fallback capitalize"
	)
