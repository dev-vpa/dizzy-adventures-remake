extends Area2D

## World pickup. Player presses action (E / Enter) while overlapping.

@export var item_id: String = "placeholder_item"
@export var display_name: String = "Item"

@onready var label: Label = $Label


func _ready() -> void:
	add_to_group("pickup")
	if label:
		label.text = display_name


func try_pick_up() -> bool:
	if Inventory.try_pick_up(item_id):
		queue_free()
		return true
	return false
