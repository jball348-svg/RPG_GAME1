extends Control

const REFERENCE_VIEWPORT_SIZE := Vector2(480.0, 270.0)

const PLAYER_START_POS := Vector2(44.0, 143.0)
const PLAYER_END_POS := Vector2(156.0, 143.0)
const PLAYER_ACCENT_OFFSET := Vector2(4.0, 5.0)
const PLAYER_ACCENT_SIZE := Vector2(28.0, 8.0)
const SENTRY_START_POS := Vector2(342.0, 114.0)
const SENTRY_END_POS := Vector2(298.0, 114.0)

const PATH_TINT_PURE := Color(0.68, 0.56, 0.33, 1.0)
const PATH_TINT_MIXED := Color(0.25, 0.53, 0.50, 1.0)
const CLASS_TINT_FALLBACK := Color(0.64, 0.62, 0.60, 1.0)
const CLASS_TINTS := {
	"knight": Color(0.71, 0.42, 0.36, 1.0),
	"warrior": Color(0.70, 0.44, 0.33, 1.0),
	"mage": Color(0.42, 0.46, 0.73, 1.0),
	"rogue": Color(0.33, 0.58, 0.36, 1.0),
	"cleric": Color(0.75, 0.73, 0.44, 1.0),
	"ranger": Color(0.43, 0.62, 0.39, 1.0),
}

const MINE_REGION := "kobold_mine"
const MINE_LOCATION := "mine_entry_chamber"

var _status_label: Label
var _dialogue_label: Label
var _continue_button: Button
var _dialogue_panel: PanelContainer
var _player_actor: ColorRect
var _player_accent: ColorRect
var _sentry_actor: ColorRect
var _fade_rect: ColorRect

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	PlayerData.current_location = "town_north_gate_cutscene"
	PlayerData.current_region = "frontier_village"

	_build_ui()
	_connect_signals()
	_reset_sequence()
	_apply_player_visuals()
	_refresh_status()
	_play_sequence()

func _scaled(reference_vector: Vector2) -> Vector2:
	var viewport_size := get_viewport_rect().size
	return Vector2(
		reference_vector.x * viewport_size.x / REFERENCE_VIEWPORT_SIZE.x,
		reference_vector.y * viewport_size.y / REFERENCE_VIEWPORT_SIZE.y,
	)

func _build_ui() -> void:
	if get_child_count() > 0:
		return

	var viewport_size := get_viewport_rect().size
	var floor_top_y := viewport_size.y * 0.58

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.07, 0.07, 0.10, 1.0)
	add_child(backdrop)

	var fog_band := ColorRect.new()
	fog_band.position = Vector2(0.0, 0.0)
	fog_band.size = Vector2(viewport_size.x, floor_top_y)
	fog_band.color = Color(0.13, 0.15, 0.24, 1.0)
	add_child(fog_band)

	var floor := ColorRect.new()
	floor.position = Vector2(0.0, floor_top_y)
	floor.size = Vector2(viewport_size.x, viewport_size.y - floor_top_y)
	floor.color = Color(0.20, 0.17, 0.12, 1.0)
	add_child(floor)

	var title := Label.new()
	title.position = _scaled(Vector2(14.0, 10.0))
	title.size = _scaled(Vector2(300.0, 20.0))
	title.text = "Mine Entrance Transition"
	add_child(title)

	_status_label = Label.new()
	_status_label.position = _scaled(Vector2(14.0, 28.0))
	_status_label.size = _scaled(Vector2(300.0, 56.0))
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(_status_label)

	_player_actor = ColorRect.new()
	_player_actor.size = _scaled(Vector2(36.0, 56.0))
	add_child(_player_actor)

	_player_accent = ColorRect.new()
	_player_accent.position = _scaled(PLAYER_ACCENT_OFFSET)
	_player_accent.size = _scaled(PLAYER_ACCENT_SIZE)
	_player_actor.add_child(_player_accent)

	_sentry_actor = ColorRect.new()
	_sentry_actor.size = _scaled(Vector2(40.0, 64.0))
	_sentry_actor.color = Color(0.46, 0.43, 0.37, 1.0)
	add_child(_sentry_actor)

	_dialogue_panel = PanelContainer.new()
	_dialogue_panel.position = _scaled(Vector2(60.0, 188.0))
	_dialogue_panel.size = _scaled(Vector2(360.0, 70.0))
	_dialogue_panel.visible = false
	add_child(_dialogue_panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	_dialogue_panel.add_child(margin)

	var content := VBoxContainer.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.add_theme_constant_override("separation", 4)
	margin.add_child(content)

	var speaker := Label.new()
	speaker.text = "Gate Sentry"
	content.add_child(speaker)

	_dialogue_label = Label.new()
	_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_dialogue_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(_dialogue_label)

	_continue_button = Button.new()
	_continue_button.text = "Enter Mine"
	_continue_button.disabled = true
	_continue_button.pressed.connect(_on_continue_pressed)
	content.add_child(_continue_button)

	_fade_rect = ColorRect.new()
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	add_child(_fade_rect)

func _connect_signals() -> void:
	SignalBus.clock_ticked.connect(_on_clock_ticked)
	SignalBus.flag_set.connect(_on_flag_changed)

func _reset_sequence() -> void:
	_player_actor.position = _scaled(PLAYER_START_POS)
	_sentry_actor.position = _scaled(SENTRY_START_POS)
	_dialogue_label.text = ""
	_dialogue_panel.visible = false
	_continue_button.disabled = true
	_fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)

func _apply_player_visuals() -> void:
	_player_actor.color = PATH_TINT_PURE if PlayerData.is_pure() else PATH_TINT_MIXED
	_player_accent.color = _resolve_class_tint()

func _resolve_class_tint() -> Color:
	var class_key := _resolve_class_key()
	for known_key in CLASS_TINTS.keys():
		if class_key.find(known_key) != -1:
			return CLASS_TINTS[known_key]

	return CLASS_TINT_FALLBACK

func _resolve_class_key() -> String:
	if PlayerData.specialisation != "":
		return PlayerData.specialisation.to_lower()

	if PlayerData.chosen_class != "":
		return PlayerData.chosen_class.to_lower()

	if PlayerData.mixed_classes.size() > 0:
		return str(PlayerData.mixed_classes[0]).to_lower()

	return ""

func _play_sequence() -> void:
	var tween := create_tween()
	tween.tween_property(_player_actor, "position", _scaled(PLAYER_END_POS), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.15)
	tween.tween_property(_sentry_actor, "position", _scaled(SENTRY_END_POS), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.18)
	tween.tween_callback(_on_sequence_finished)

func _on_sequence_finished() -> void:
	_dialogue_panel.visible = true
	_dialogue_label.text = _dialogue_for_current_path()
	_continue_button.disabled = false
	_continue_button.grab_focus()

func _dialogue_for_current_path() -> String:
	var class_label := PlayerData.get_display_class()
	if class_label == "":
		class_label = "wanderer"

	if PlayerData.is_mixed():
		return "Mixed oath and %s training noted. Keep your balance down there; the tunnels choose no side." % class_label

	return "Pure oath and %s discipline noted. Hold your resolve and the mine will open before you." % class_label

func _on_continue_pressed() -> void:
	_continue_button.disabled = true

	var fade_tween := create_tween()
	fade_tween.tween_property(_fade_rect, "color", Color(0.0, 0.0, 0.0, 1.0), 0.35)
	fade_tween.finished.connect(_handoff_to_mine_map)

func _handoff_to_mine_map() -> void:
	PlayerData.current_location = MINE_LOCATION
	PlayerData.current_region = MINE_REGION
	SceneManager.change_state("map")

func _on_clock_ticked(_time: Dictionary) -> void:
	_refresh_status()

func _on_flag_changed(flag_name: String, _value: Variant) -> void:
	if flag_name == "chosen_path":
		_apply_player_visuals()
		_refresh_status()

func _refresh_status() -> void:
	var time_data: Dictionary = GameClock.get_time()
	var path_label := PlayerData.chosen_path.capitalize()
	if path_label == "":
		path_label = "unset"

	_status_label.text = "Clock: %s\nPath: %s\nClass Accent: %s" % [
		time_data.get("display", "unknown"),
		path_label,
		"none" if PlayerData.get_display_class() == "" else PlayerData.get_display_class(),
	]
