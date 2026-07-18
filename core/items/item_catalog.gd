class_name ItemCatalog
extends RefCounted

## Display names and metadata for pickup items (expand per game in Phase 2+).

const DISPLAY_NAMES: Dictionary = {
	"snorkel": "Snorkel",
	"coin": "Coin",
	"plant_1": "Protected Species",
	"plant_2": "Protected Species",
	"plant_3": "Protected Species",
	"plant_4": "Protected Species",
	"empty_chest": "Empty Solid Chest",
	"toothpaste": "Tube of Toothpaste",
	"misty_window": "Misty Glass Window",
	"mushrooms": "Clump of Mushrooms",
	"wooden_rail_1": "Wooden Safety Rail",
	"wooden_rail_2": "Wooden Safety Rail",
	"tree_trunk_1": "Bit of Tree Trunk",
	"tree_trunk_2": "Bit of Tree Trunk",
	"glass_sword": "Sharp Glass Sword",
	"video_camera": "Small Video Camera",
	"salt_spade": "Salt Water Spade",
	"heavy_rock": "Big Red Heavy Rock",
	"dehydrated_boat": "Dehydrated Boat",
	"empty_bucket": "Empty Old Bucket",
	"holy_bible": "Old Holy Bible",
	"woodcutters_axe": "Woodcutters Axe",
	"cursed_treasure": "Cursed Treasure",
	"outboard_motor": "Outboard Motor",
	"golden_key": "Large Golden Key",
	"dynamite": "Sticks of Dynamite",
	"detonator": "Infra Red Detonator",
	"microwave": "Microwave Oven",
	"petrol": "Gallon of Petrol",
	"gold_bag": "Bag of Gold Coins",
	"ignition_key": "Ignition Key",
	"skull_1": "Imitation Skull",
	"skull_2": "Imitation Skull",
	"magazine": "Sinclair Abuser Magazine",
}

const ICON_IDS: Dictionary = {
	"snorkel": "snorkel",
	"coin": "coin",
}


static func get_display_name(item_id: String) -> String:
	return DISPLAY_NAMES.get(item_id, item_id.capitalize())


static func get_icon_id(item_id: String) -> String:
	return ICON_IDS.get(item_id, "default")
