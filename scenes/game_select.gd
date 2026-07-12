extends Control


func _ready() -> void:
	_populate_list()


func _populate_list() -> void:
	var list: ItemList = $MarginContainer/VBox/GameList
	list.clear()
	for config in GameManager.get_available_games():
		var idx := list.add_item(config.title)
		list.set_item_metadata(idx, config)


func _on_game_list_item_activated(index: int) -> void:
	var list: ItemList = $MarginContainer/VBox/GameList
	var config: GameConfig = list.get_item_metadata(index)
	GameManager.start_game(config)


func _on_back_pressed() -> void:
	GameManager.quit_to_main_menu()
