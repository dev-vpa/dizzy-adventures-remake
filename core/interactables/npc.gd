extends Area2D

## NPC interactable — action key / Pick shows a speech bubble.

@export var npc_name: String = "NPC"
@export_multiline var message: String = "Hello!"

@onready var _hint: Label = $HintLabel
@onready var _bubble: PanelContainer = $SpeechBubble
@onready var _message_label: Label = $SpeechBubble/MessageLabel

var _player_near := false


func _ready() -> void:
	add_to_group("interactable")
	if _message_label:
		_message_label.text = message
	if _bubble:
		_bubble.visible = false
	_update_hint()


func _process(_delta: float) -> void:
	_update_hint()


func _update_hint() -> void:
	if _hint == null:
		return
	_hint.text = PlatformUI.hint_text("E", "Pick")
	_hint.visible = _player_near and (_bubble == null or not _bubble.visible)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_near = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_near = false
		if _bubble:
			_bubble.visible = false


func try_interact() -> bool:
	if not _player_near:
		return false
	if _bubble:
		_bubble.visible = true
	_update_hint()
	return true
