extends Control

const PLAYER_START_POS := Vector2(104.0, 284.0)
const PLAYER_END_POS := Vector2(260.0, 284.0)
const NPC_START_POS := Vector2(652.0, 222.0)
const NPC_END_POS := Vector2(584.0, 222.0)

var _status_label: Label
var _dialogue_label: Label
var _continue_button: Button
var _dialogue_panel: PanelContainer
var _player_actor: ColorRect
var _npc_actor: ColorRect

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	PlayerData.current_location = "spike_cutscene"
	PlayerData.current_region = "gate_approach"

	_build_ui()
	_connect_signals()
	_reset_sequence()
	_refresh_status()
	_play_sequence()

func _build_ui() -> void:
	if get_child_count() > 0:
		return

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.08, 0.08, 0.12, 1.0)
	add_child(backdrop)

	var sky_band := ColorRect.new()
	sky_band.position = Vector2(0.0, 0.0)
	sky_band.size = Vector2(960.0, 220.0)
	sky_band.color = Color(0.16, 0.18, 0.30, 1.0)
	add_child(sky_band)

	var floor := ColorRect.new()
	floor.position = Vector2(0.0, 312.0)
	floor.size = Vector2(960.0, 228.0)
	floor.color = Color(0.22, 0.18, 0.12, 1.0)
	add_child(floor)

	var title := Label.new()
	title.position = Vector2(28.0, 18.0)
	title.size = Vector2(440.0, 28.0)
	title.text = "Day 4 Cutscene Proof"
	add_child(title)

	_status_label = Label.new()
	_status_label.position = Vector2(28.0, 48.0)
	_status_label.size = Vector2(460.0, 72.0)
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(_status_label)

	_player_actor = ColorRect.new()
	_player_actor.size = Vector2(72.0, 112.0)
	_player_actor.color = Color(0.21, 0.63, 0.86, 1.0)
	add_child(_player_actor)

	_npc_actor = ColorRect.new()
	_npc_actor.size = Vector2(80.0, 128.0)
	_npc_actor.color = Color(0.78, 0.70, 0.38, 1.0)
	add_child(_npc_actor)

	_dialogue_panel = PanelContainer.new()
	_dialogue_panel.position = Vector2(148.0, 372.0)
	_dialogue_panel.size = Vector2(664.0, 132.0)
	_dialogue_panel.visible = false
	add_child(_dialogue_panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	_dialogue_panel.add_child(margin)

	var content := VBoxContainer.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)

	var speaker := Label.new()
	speaker.text = "Gate Sentry"
	content.add_child(speaker)

	_dialogue_label = Label.new()
	_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_dialogue_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(_dialogue_label)

	_continue_button = Button.new()
	_continue_button.text = "Continue"
	_continue_button.disabled = true
	_continue_button.pressed.connect(_on_continue_pressed)
	content.add_child(_continue_button)

func _connect_signals() -> void:
	SignalBus.clock_ticked.connect(_on_clock_ticked)
	SignalBus.flag_set.connect(_on_flag_changed)

func _reset_sequence() -> void:
	_player_actor.position = PLAYER_START_POS
	_npc_actor.position = NPC_START_POS
	_dialogue_label.text = ""
	_dialogue_panel.visible = false
	_continue_button.disabled = true

func _play_sequence() -> void:
	var tween := create_tween()
	tween.tween_property(_player_actor, "position", PLAYER_END_POS, 0.85).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.20)
	tween.tween_property(_npc_actor, "position", NPC_END_POS, 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.25)
	tween.finished.connect(_on_sequence_finished)

func _on_sequence_finished() -> void:
	_dialogue_panel.visible = true
	_dialogue_label.text = _dialogue_for_current_path()
	_continue_button.disabled = false
	_continue_button.grab_focus()

func _dialogue_for_current_path() -> String:
	if PlayerData.is_mixed():
		return "Mixed path recognized. The sentry watches you carefully before letting you pass."
	return "Pure path recognized. The sentry waves you through without hesitation."

func _on_continue_pressed() -> void:
	SceneManager.change_state("map")

func _on_clock_ticked(_time: Dictionary) -> void:
	_refresh_status()

func _on_flag_changed(flag_name: String, _value: Variant) -> void:
	if flag_name == "chosen_path":
		_refresh_status()

func _refresh_status() -> void:
	var time_data: Dictionary = GameClock.get_time()
	_status_label.text = "Clock: %s\nPath: %s" % [
		time_data.get("display", "unknown"),
		PlayerData.chosen_path.capitalize(),
	]
