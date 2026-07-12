extends Area2D

## World pickup. Player presses action (E / Enter) while overlapping.

@export var item_id: String = "placeholder_item"
@export var display_name: String = "Item"

@onready var item_sprite: ItemSprite = $ItemSprite


func _ready() -> void:
	add_to_group("pickup")
	if item_sprite:
		item_sprite.configure(item_id)


func try_pick_up() -> bool:
	if Inventory.try_pick_up(item_id):
		queue_free()
		return true
	return false
