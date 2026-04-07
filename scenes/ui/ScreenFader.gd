extends ColorRect

var _active_tween: Tween

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	color = Color(0.0, 0.0, 0.0, 0.0)
	visible = false

func fade_to_black(duration: float = 0.35) -> Tween:
	return _fade_to_alpha(1.0, duration)

func fade_from_black(duration: float = 0.35) -> Tween:
	return _fade_to_alpha(0.0, duration)

func clear_immediately() -> void:
	_kill_active_tween()
	color = Color(0.0, 0.0, 0.0, 0.0)
	visible = false

func force_black() -> void:
	_kill_active_tween()
	color = Color(0.0, 0.0, 0.0, 1.0)
	visible = true

func is_transitioning() -> bool:
	return _active_tween != null and _active_tween.is_running()

func _fade_to_alpha(target_alpha: float, duration: float) -> Tween:
	_kill_active_tween()
	visible = true
	color = Color(0.0, 0.0, 0.0, color.a)
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_SINE)
	_active_tween.set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(self, "color", Color(0.0, 0.0, 0.0, target_alpha), duration)
	if is_zero_approx(target_alpha):
		_active_tween.finished.connect(_hide_after_fade, CONNECT_ONE_SHOT)
	return _active_tween

func _kill_active_tween() -> void:
	if _active_tween != null and _active_tween.is_running():
		_active_tween.kill()
	_active_tween = null

func _hide_after_fade() -> void:
	if is_zero_approx(color.a):
		visible = false
