class_name GameConfig
extends Resource

## Per-game rules loaded from games/<slug>/.

@export var id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var inventory_slots: int = 1
@export var starting_lives: int = 3
@export var starting_screen_id: String = "start"
@export var collectible_name: String = ""
@export var collectible_total: int = 0
@export var levels_path: String = ""
@export var enabled: bool = true
