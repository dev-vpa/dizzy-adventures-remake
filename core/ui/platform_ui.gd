class_name PlatformUI
extends RefCounted

## Helpers for multiplatform UX (desktop + touch + web).

const MIN_TOUCH_SIZE := 44.0


static func is_touch_device() -> bool:
	return DisplayServer.is_touchscreen_available()


static func prefers_touch_layout() -> bool:
	return is_touch_device()


static func show_desktop_quit() -> bool:
	return not OS.has_feature("mobile") and not OS.has_feature("web")


static func hint_text(desktop: String, touch: String) -> String:
	return touch if is_touch_device() else desktop
