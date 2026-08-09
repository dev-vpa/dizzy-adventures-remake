#!/usr/bin/env python3
"""Scale Godot .tscn numeric layout fields by ×2 (512×384 → 1024×768)."""
from __future__ import annotations

import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SCALE = 2.0

# Lines / keys that should NOT have numbers scaled.
SKIP_LINE_SUBSTR = (
	"uid://",
	"ExtResource",
	"SubResource",
	"load_steps",
	"collision_layer",
	"collision_mask",
	"z_index",
	"z_as_relative",
	"layout_mode",
	"anchors_preset",
	"grow_horizontal",
	"grow_vertical",
	"mouse_filter",
	"clip_contents",
	"visible =",
	"disabled =",
	"monitoring",
	"monitorable",
	"one_way",
	"script =",
	"path =",
	"type=",
	"[gd_scene",
	"[node ",
	"[sub_resource",
	"[ext_resource",
	"format=",
)

NUM = r"-?\d+\.?\d*"


def scale_num(m: re.Match) -> str:
	v = float(m.group(0))
	out = v * SCALE
	if abs(out - round(out)) < 1e-6:
		return str(int(round(out)))
	# keep one decimal if input had decimal
	if "." in m.group(0):
		return f"{out:.1f}".rstrip("0").rstrip(".") if out == int(out) else f"{out:.1f}"
	return str(out)


def scale_vector2(text: str) -> str:
	def repl(m: re.Match) -> str:
		a, b = float(m.group(1)), float(m.group(2))
		return f"Vector2({_fmt(a * SCALE)}, {_fmt(b * SCALE)})"

	return re.sub(rf"Vector2\(\s*({NUM})\s*,\s*({NUM})\s*\)", repl, text)


def scale_rect2(text: str) -> str:
	def repl(m: re.Match) -> str:
		vals = [float(m.group(i)) * SCALE for i in range(1, 5)]
		return "Rect2(%s, %s, %s, %s)" % tuple(_fmt(v) for v in vals)

	return re.sub(
		rf"Rect2\(\s*({NUM})\s*,\s*({NUM})\s*,\s*({NUM})\s*,\s*({NUM})\s*\)",
		repl,
		text,
	)


def _fmt(v: float) -> str:
	if abs(v - round(v)) < 1e-6:
		return str(int(round(v)))
	s = f"{v:.3f}".rstrip("0").rstrip(".")
	return s


def scale_offsets(text: str) -> str:
	# offset_left = -256.0  etc.
	def repl(m: re.Match) -> str:
		key, num = m.group(1), float(m.group(2))
		return f"{key} = {_fmt(num * SCALE)}"

	return re.sub(
		rf"(offset_(?:left|right|top|bottom)|theme_override_constants/\w+)\s*=\s*({NUM})",
		repl,
		text,
	)


def scale_font_sizes(text: str) -> str:
	def repl(m: re.Match) -> str:
		return f"theme_override_font_sizes/font_size = {_fmt(float(m.group(1)) * SCALE)}"

	return re.sub(
		r"theme_override_font_sizes/font_size\s*=\s*(\d+)",
		repl,
		text,
	)


def scale_custom_min(text: str) -> str:
	return scale_vector2(
		re.sub(
			rf"(custom_minimum_size\s*=\s*)Vector2\(\s*({NUM})\s*,\s*({NUM})\s*\)",
			lambda m: f"{m.group(1)}Vector2({_fmt(float(m.group(2))*SCALE)}, {_fmt(float(m.group(3))*SCALE)})",
			text,
		)
	)


def scale_simple_assigns(text: str) -> str:
	"""position/size/radius and similar float assigns on their own line."""
	keys = (
		"position",
		"size",
		"radius",
		"patrol_range",
		"zone_center",  # handled as Vector2 already if Vector2(...)
	)

	def line_ok(line: str) -> bool:
		s = line.strip()
		if not s or s.startswith("["):
			return False
		for skip in SKIP_LINE_SUBSTR:
			if skip in s:
				return False
		if "Color(" in s:
			return False
		return True

	out_lines = []
	for line in text.splitlines(keepends=True):
		if not line_ok(line):
			out_lines.append(line)
			continue
		nl = line
		nl = scale_vector2(nl)
		nl = scale_rect2(nl)
		# lone float: radius = 22.0
		nl = re.sub(
			rf"^(\s*radius\s*=\s*)({NUM})(\s*)$",
			lambda m: f"{m.group(1)}{_fmt(float(m.group(2)) * SCALE)}{m.group(3)}",
			nl,
		)
		nl = re.sub(
			rf"^(\s*patrol_range\s*=\s*)({NUM})(\s*)$",
			lambda m: f"{m.group(1)}{_fmt(float(m.group(2)) * SCALE)}{m.group(3)}",
			nl,
		)
		out_lines.append(nl)
	return "".join(out_lines)


def process_file(path: Path) -> None:
	raw = path.read_text(encoding="utf-8")
	# scale_simple_assigns already ×2 Vector2/Rect2 on layout lines once —
	# do not call scale_vector2/rect2 again or values become ×4.
	text = scale_simple_assigns(raw)
	text = scale_offsets(text)
	text = scale_font_sizes(text)
	if text != raw:
		path.write_text(text, encoding="utf-8", newline="\n")
		print("scaled", path.relative_to(REPO))
	else:
		print("unchanged", path.relative_to(REPO))


def main() -> None:
	targets: list[Path] = []
	targets += list((REPO / "games/treasure-island/levels").glob("*.tscn"))
	extra = [
		"core/world/water_zone.tscn",
		"core/world/hazard_zone.tscn",
		"core/player/player.tscn",
		"core/items/pickup_item.tscn",
		"core/interactables/npc.tscn",
		"core/world/puzzle_barrier.tscn",
		"core/ui/touch_controls.tscn",
		"core/ui/hud.tscn",
		"scenes/game_world.tscn",
		"scenes/main_menu.tscn",
		"scenes/game_select.tscn",
		"scenes/loading_screen.tscn",
		"scenes/win_screen.tscn",
		"games/treasure-island/title_screen.tscn",
	]
	for rel in extra:
		p = REPO / rel
		if p.exists():
			targets.append(p)
	for p in targets:
		process_file(p)
	print(f"done ({len(targets)} files)")


if __name__ == "__main__":
	main()
