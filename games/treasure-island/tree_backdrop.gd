extends Node2D

## Placeholder tree-village backdrop — warm greens and browns.


func _draw() -> void:
	draw_rect(Rect2(0, 0, 512, 384), Color(0.42, 0.58, 0.38, 1))
	draw_rect(Rect2(0, 300, 512, 84), Color(0.32, 0.26, 0.18, 1))
	# Tree trunks
	for x in [80, 200, 340, 440]:
		draw_rect(Rect2(x - 8, 220, 16, 120), Color(0.38, 0.28, 0.18, 1))
		draw_rect(Rect2(x - 20, 180, 40, 50), Color(0.28, 0.48, 0.22, 1))
