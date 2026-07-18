class_name TestAssert
extends RefCounted

## Minimal assertions for headless test runs (no external test framework).

static var failure_count: int = 0
static var pass_count: int = 0


static func reset() -> void:
	failure_count = 0
	pass_count = 0


static func ok(condition: bool, message: String) -> void:
	if condition:
		pass_count += 1
	else:
		failure_count += 1
		push_error("FAIL: %s" % message)


static func eq(actual: Variant, expected: Variant, message: String = "") -> void:
	var label := message if not message.is_empty() else "expected %s, got %s" % [expected, actual]
	ok(actual == expected, label)


static func ne(actual: Variant, expected: Variant, message: String = "") -> void:
	var label := message if not message.is_empty() else "expected not %s" % expected
	ok(actual != expected, label)


static func true_(condition: bool, message: String) -> void:
	ok(condition, message)


static func false_(condition: bool, message: String) -> void:
	ok(not condition, message)
