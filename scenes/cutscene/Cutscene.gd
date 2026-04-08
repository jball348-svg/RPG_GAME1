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

const CUTSCENE_ID_MINE_ENTRY := "mine_entry"
const CUTSCENE_ID_SHAMAN_INTRO := "shaman_intro"
const CUTSCENE_ID_MINE_EXIT := "mine_exit"
const SHAMAN_INTRO_DIALOGUE_ID := "shaman_intro_cutscene"
const SHAMAN_RECRUIT_DIALOGUE_ID := "shaman_recruit_resolution"
const BATTLE_KIND_BOSS_SHAMAN := "boss_shaman"
const MINE_BOSS_RESOLVED_FLAG := "mine_boss_resolved"
const MINE_EXIT_UNLOCKED_FLAG := "mine_exit_unlocked"
const MINE_CLEARED_FLAG := "mine_cleared"
const MAIN_QUEST_PATH_OPEN_FLAG := "main_quest_path_open"
const SHAMAN_RECRUITED_FLAG := "shaman_recruited"
const FRONTIER_REGION := "frontier_village"
const MINE_REGION := "kobold_mine"
const MINE_LOCATION := "mine_entry_chamber"
const CROSSROADS_REGION := "crossroads_region"
const CROSSROADS_LOCATION := "crossroads_start"
const CUTSCENE_TOWN_GATE_LOCATION := "town_north_gate_cutscene"
const SHAMAN_DIALOGUE_PAUSE_SECONDS := 0.8

const PLAYER_KNIGHT_SPRITE_PATH := "res://assets/art/player/universal-lpc-sprite_male_01_full.png"
const PLAYER_BATTLEMAGE_SPRITE_PATH := "res://assets/art/battle/LPC_starhat/sample.png"
const SHAMAN_SPRITE_PATH := "res://assets/art/battle/goblinsword.png"
const UI_PANEL_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/panel_brown.png"
const UI_BUTTON_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/buttonLong_brown.png"
const UI_BUTTON_PRESSED_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/buttonLong_brown_pressed.png"
const UI_BUTTON_DISABLED_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/buttonLong_grey.png"

const KNIGHT_PLAYER_REGION := Rect2i(64, 64, 64, 64)
const BATTLEMAGE_PLAYER_REGION := Rect2i(50, 135, 50, 45)
const SHAMAN_SPRITE_REGION := Rect2i(0, 0, 64, 64)

const SHAMAN_PLAYER_START_POS := Vector2(92.0, 142.0)
const SHAMAN_PLAYER_END_POS := Vector2(120.0, 142.0)
const SHAMAN_ACTOR_START_POS := Vector2(336.0, 116.0)
const SHAMAN_ACTOR_END_POS := Vector2(302.0, 116.0)
const SHAMAN_PLAYER_SIZE := Vector2(72.0, 88.0)
const SHAMAN_ACTOR_SIZE := Vector2(72.0, 88.0)
const MINE_EXIT_PLAYER_START_POS := Vector2(88.0, 146.0)
const MINE_EXIT_PLAYER_END_POS := Vector2(250.0, 146.0)
const MINE_EXIT_SHAMAN_START_POS := Vector2(56.0, 146.0)
const MINE_EXIT_SHAMAN_END_POS := Vector2(218.0, 146.0)

var _incoming_payload: Dictionary = {}
var _cutscene_id := CUTSCENE_ID_MINE_ENTRY

var _status_label: Label
var _title_label: Label
var _info_panel: PanelContainer
var _speaker_label: Label
var _dialogue_label: Label
var _continue_button: Button
var _dialogue_panel: PanelContainer
var _player_actor: ColorRect
var _player_accent: ColorRect
var _sentry_actor: ColorRect
var _fog_band: ColorRect
var _floor_band: ColorRect
var _player_battle_actor: TextureRect
var _shaman_actor: TextureRect
var _narration_label: Label
var _choice_panel: PanelContainer
var _choice_title_label: Label
var _talk_button: Button
var _fight_button: Button
var _panel_texture: Texture2D
var _button_texture: Texture2D
var _button_pressed_texture: Texture2D
var _button_disabled_texture: Texture2D
var _last_viewport_size := Vector2.ZERO

func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	_incoming_payload = SceneManager.consume_state_payload()
	_cutscene_id = str(_incoming_payload.get("cutscene_id", CUTSCENE_ID_MINE_ENTRY))
	if _cutscene_id == "":
		_cutscene_id = CUTSCENE_ID_MINE_ENTRY

	if _cutscene_id == CUTSCENE_ID_MINE_ENTRY:
		PlayerData.current_location = CUTSCENE_TOWN_GATE_LOCATION
		PlayerData.current_region = FRONTIER_REGION

	_sync_root_to_viewport()
	_load_ui_textures()
	_build_ui()
	_connect_signals()
	_reset_sequence()
	_apply_player_visuals()
	_refresh_status()
	call_deferred("_play_sequence")

	_last_viewport_size = get_viewport_rect().size
	if not get_viewport().size_changed.is_connected(_on_viewport_size_changed):
		get_viewport().size_changed.connect(_on_viewport_size_changed)

func _scaled(reference_vector: Vector2) -> Vector2:
	var viewport_size := get_viewport_rect().size
	return Vector2(
		reference_vector.x * viewport_size.x / REFERENCE_VIEWPORT_SIZE.x,
		reference_vector.y * viewport_size.y / REFERENCE_VIEWPORT_SIZE.y,
	)

func _load_ui_textures() -> void:
	_panel_texture = _load_texture(UI_PANEL_TEXTURE_PATH)
	_button_texture = _load_texture(UI_BUTTON_TEXTURE_PATH)
	_button_pressed_texture = _load_texture(UI_BUTTON_PRESSED_TEXTURE_PATH)
	_button_disabled_texture = _load_texture(UI_BUTTON_DISABLED_TEXTURE_PATH)

func _build_ui() -> void:
	if get_child_count() > 0:
		return

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.07, 0.07, 0.10, 1.0)
	add_child(backdrop)

	_fog_band = ColorRect.new()
	_fog_band.color = Color(0.13, 0.15, 0.24, 1.0)
	add_child(_fog_band)

	_floor_band = ColorRect.new()
	_floor_band.color = Color(0.20, 0.17, 0.12, 1.0)
	add_child(_floor_band)

	_info_panel = PanelContainer.new()
	_info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_info_panel.add_theme_stylebox_override("panel", _make_panel_style(_panel_texture))
	add_child(_info_panel)

	var info_margin := MarginContainer.new()
	info_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	info_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	info_margin.add_theme_constant_override("margin_left", 8)
	info_margin.add_theme_constant_override("margin_top", 6)
	info_margin.add_theme_constant_override("margin_right", 8)
	info_margin.add_theme_constant_override("margin_bottom", 6)
	_info_panel.add_child(info_margin)

	var info_content := VBoxContainer.new()
	info_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	info_content.add_theme_constant_override("separation", 4)
	info_margin.add_child(info_content)

	_title_label = Label.new()
	_title_label.text = "Mine Entrance Transition"
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	info_content.add_child(_title_label)

	_status_label = Label.new()
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	info_content.add_child(_status_label)

	_player_actor = ColorRect.new()
	_player_actor.size = _scaled(Vector2(36.0, 56.0))
	add_child(_player_actor)

	_player_accent = ColorRect.new()
	_player_accent.position = _scaled(PLAYER_ACCENT_OFFSET)
	_player_accent.size = _scaled(PLAYER_ACCENT_SIZE)
	_player_actor.add_child(_player_accent)

	_player_battle_actor = TextureRect.new()
	_player_battle_actor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_player_battle_actor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_player_battle_actor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_player_battle_actor.visible = false
	add_child(_player_battle_actor)

	_sentry_actor = ColorRect.new()
	_sentry_actor.color = Color(0.46, 0.43, 0.37, 1.0)
	add_child(_sentry_actor)

	_shaman_actor = TextureRect.new()
	_shaman_actor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shaman_actor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_shaman_actor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_shaman_actor.visible = false
	add_child(_shaman_actor)

	_narration_label = Label.new()
	_narration_label.visible = false
	_narration_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_narration_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_narration_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(_narration_label)

	_dialogue_panel = PanelContainer.new()
	_dialogue_panel.anchor_left = 0.0
	_dialogue_panel.anchor_top = 1.0
	_dialogue_panel.anchor_right = 1.0
	_dialogue_panel.anchor_bottom = 1.0
	_dialogue_panel.visible = false
	_dialogue_panel.add_theme_stylebox_override("panel", _make_panel_style(_panel_texture))
	add_child(_dialogue_panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	_dialogue_panel.add_child(margin)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 4)
	margin.add_child(content)

	_speaker_label = Label.new()
	_speaker_label.text = "Gate Sentry"
	_speaker_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(_speaker_label)

	_dialogue_label = Label.new()
	_dialogue_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_dialogue_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(_dialogue_label)

	var actions := HBoxContainer.new()
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.alignment = BoxContainer.ALIGNMENT_END
	content.add_child(actions)

	_continue_button = _create_menu_button("Enter Mine")
	_continue_button.disabled = true
	_continue_button.pressed.connect(_on_continue_pressed)
	actions.add_child(_continue_button)

	_choice_panel = PanelContainer.new()
	_choice_panel.visible = false
	_choice_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_choice_panel.add_theme_stylebox_override("panel", _make_panel_style(_panel_texture))
	add_child(_choice_panel)

	var choice_margin := MarginContainer.new()
	choice_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	choice_margin.add_theme_constant_override("margin_left", 12)
	choice_margin.add_theme_constant_override("margin_top", 10)
	choice_margin.add_theme_constant_override("margin_right", 12)
	choice_margin.add_theme_constant_override("margin_bottom", 10)
	_choice_panel.add_child(choice_margin)

	var choice_content := VBoxContainer.new()
	choice_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choice_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	choice_content.alignment = BoxContainer.ALIGNMENT_CENTER
	choice_content.add_theme_constant_override("separation", 8)
	choice_margin.add_child(choice_content)

	_choice_title_label = Label.new()
	_choice_title_label.text = "How do you answer?"
	_choice_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_choice_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choice_content.add_child(_choice_title_label)

	var choice_buttons := HBoxContainer.new()
	choice_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	choice_buttons.add_theme_constant_override("separation", 8)
	choice_content.add_child(choice_buttons)

	_talk_button = _create_menu_button("Speak with the Shaman")
	_talk_button.disabled = true
	_talk_button.pressed.connect(_on_talk_button_pressed)
	choice_buttons.add_child(_talk_button)

	_fight_button = _create_menu_button("Fight")
	_fight_button.disabled = true
	_fight_button.pressed.connect(_on_fight_button_pressed)
	choice_buttons.add_child(_fight_button)

	_layout_for_viewport()

func _connect_signals() -> void:
	SignalBus.clock_ticked.connect(_on_clock_ticked)
	SignalBus.flag_set.connect(_on_flag_changed)

func _sync_root_to_viewport() -> void:
	var viewport_size := get_viewport_rect().size
	position = Vector2.ZERO
	size = viewport_size
	custom_minimum_size = viewport_size

func _on_viewport_size_changed() -> void:
	var new_size := get_viewport_rect().size
	if _last_viewport_size != Vector2.ZERO:
		var ratio := Vector2(
			new_size.x / max(_last_viewport_size.x, 1.0),
			new_size.y / max(_last_viewport_size.y, 1.0),
		)
		_player_actor.position *= ratio
		_player_battle_actor.position *= ratio
		_sentry_actor.position *= ratio
		_shaman_actor.position *= ratio

	_last_viewport_size = new_size
	_sync_root_to_viewport()
	_layout_for_viewport()

func _layout_for_viewport() -> void:
	var viewport_size := get_viewport_rect().size
	var compact_layout := viewport_size.x <= 640.0 or viewport_size.y <= 360.0
	var floor_top_y := viewport_size.y * 0.58

	_fog_band.position = Vector2.ZERO
	_fog_band.size = Vector2(viewport_size.x, floor_top_y)
	_floor_band.position = Vector2(0.0, floor_top_y)
	_floor_band.size = Vector2(viewport_size.x, viewport_size.y - floor_top_y)

	_info_panel.anchor_left = 0.0
	_info_panel.anchor_top = 0.0
	_info_panel.anchor_right = 0.0
	_info_panel.anchor_bottom = 0.0
	var info_margin := 10.0 if compact_layout else 12.0
	var info_width := clampf(viewport_size.x * (0.43 if compact_layout else 0.34), 188.0, 248.0)
	var info_height := 84.0 if compact_layout else 92.0
	_info_panel.offset_left = info_margin
	_info_panel.offset_top = info_margin
	_info_panel.offset_right = info_margin + info_width
	_info_panel.offset_bottom = info_margin + info_height
	_info_panel.custom_minimum_size = Vector2(info_width, info_height)
	_title_label.add_theme_font_size_override("font_size", 8 if compact_layout else 9)
	_status_label.add_theme_font_size_override("font_size", 7 if compact_layout else 8)

	_player_actor.size = _scaled(Vector2(36.0, 56.0))
	_player_accent.position = _scaled(PLAYER_ACCENT_OFFSET)
	_player_accent.size = _scaled(PLAYER_ACCENT_SIZE)
	_player_battle_actor.size = _scaled(SHAMAN_PLAYER_SIZE)
	_sentry_actor.size = _scaled(Vector2(40.0, 64.0))
	_shaman_actor.size = _scaled(SHAMAN_ACTOR_SIZE)
	_narration_label.position = Vector2(_scaled(Vector2(48.0, 0.0)).x, _scaled(Vector2(0.0, 92.0)).y)
	_narration_label.size = Vector2(viewport_size.x - _scaled(Vector2(96.0, 0.0)).x, _scaled(Vector2(0.0, 34.0)).y)
	_narration_label.add_theme_font_size_override("font_size", 10 if compact_layout else 11)

	var horizontal_margin := 16.0 if compact_layout else 40.0
	var bottom_margin := 10.0 if compact_layout else 12.0
	var panel_height := 92.0 if compact_layout else 84.0
	_dialogue_panel.offset_left = horizontal_margin
	_dialogue_panel.offset_right = -horizontal_margin
	_dialogue_panel.offset_top = -panel_height - bottom_margin
	_dialogue_panel.offset_bottom = -bottom_margin
	_dialogue_panel.custom_minimum_size = Vector2(0.0, panel_height)
	_speaker_label.add_theme_font_size_override("font_size", 8 if compact_layout else 9)
	_dialogue_label.add_theme_font_size_override("font_size", 7 if compact_layout else 8)
	_continue_button.add_theme_font_size_override("font_size", 7 if compact_layout else 8)
	_continue_button.custom_minimum_size = Vector2(84.0 if compact_layout else 96.0, 0.0)

	var choice_width := clampf(viewport_size.x * (0.58 if compact_layout else 0.52), 228.0, 320.0)
	var choice_height := 80.0 if compact_layout else 86.0
	var choice_top := clampf(
		viewport_size.y * 0.3,
		info_margin + info_height + 8.0,
		viewport_size.y - choice_height - panel_height - 14.0
	)
	_choice_panel.anchor_left = 0.0
	_choice_panel.anchor_top = 0.0
	_choice_panel.anchor_right = 0.0
	_choice_panel.anchor_bottom = 0.0
	_choice_panel.position = Vector2((viewport_size.x - choice_width) * 0.5, choice_top)
	_choice_panel.size = Vector2(choice_width, choice_height)
	_choice_panel.custom_minimum_size = Vector2(choice_width, choice_height)
	_choice_title_label.add_theme_font_size_override("font_size", 8 if compact_layout else 9)
	_talk_button.custom_minimum_size = Vector2(118.0 if compact_layout else 136.0, 0.0)
	_talk_button.add_theme_font_size_override("font_size", 7 if compact_layout else 8)
	_fight_button.custom_minimum_size = Vector2(84.0 if compact_layout else 96.0, 0.0)
	_fight_button.add_theme_font_size_override("font_size", 7 if compact_layout else 8)

func _reset_sequence() -> void:
	_player_actor.position = _scaled(PLAYER_START_POS)
	_player_actor.visible = false
	_player_accent.visible = false
	_player_battle_actor.position = _scaled(SHAMAN_PLAYER_START_POS)
	_player_battle_actor.visible = false
	_sentry_actor.position = _scaled(SENTRY_START_POS)
	_sentry_actor.visible = false
	_shaman_actor.position = _scaled(SHAMAN_ACTOR_START_POS)
	_shaman_actor.visible = false
	_narration_label.visible = false
	_narration_label.text = ""
	_dialogue_label.text = ""
	_dialogue_panel.visible = false
	_continue_button.text = "Enter Mine"
	_continue_button.disabled = true
	_choice_panel.visible = false
	_talk_button.disabled = true
	_fight_button.disabled = true

func _apply_player_visuals() -> void:
	_player_actor.color = PATH_TINT_PURE if PlayerData.is_pure() else PATH_TINT_MIXED
	_player_accent.color = _resolve_class_tint()
	_player_battle_actor.texture = _load_player_cutscene_texture()
	_shaman_actor.texture = _load_shaman_texture()

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
	match _cutscene_id:
		CUTSCENE_ID_SHAMAN_INTRO:
			_run_shaman_intro_sequence()
		CUTSCENE_ID_MINE_EXIT:
			_run_mine_exit_sequence()
		_:
			_run_mine_entry_sequence()

func _run_mine_entry_sequence() -> void:
	_title_label.text = "Mine Entrance Transition"
	_player_actor.visible = true
	_player_accent.visible = true
	_sentry_actor.visible = true
	_player_actor.position = _scaled(PLAYER_START_POS)
	_sentry_actor.position = _scaled(SENTRY_START_POS)
	_continue_button.text = "Enter Mine"
	var tween := create_tween()
	tween.tween_property(_player_actor, "position", _scaled(PLAYER_END_POS), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.15)
	tween.tween_property(_sentry_actor, "position", _scaled(SENTRY_END_POS), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.18)
	await tween.finished
	_dialogue_panel.visible = true
	_speaker_label.text = "Gate Sentry"
	_dialogue_label.text = _dialogue_for_current_path()
	_continue_button.disabled = false
	_continue_button.grab_focus()

func _run_shaman_intro_sequence() -> void:
	_title_label.text = "Shaman's Chamber"
	_player_battle_actor.visible = true
	_shaman_actor.visible = true
	_player_battle_actor.position = _scaled(SHAMAN_PLAYER_START_POS)
	_shaman_actor.position = _scaled(SHAMAN_ACTOR_START_POS)
	var tween := create_tween()
	tween.tween_property(_player_battle_actor, "position", _scaled(SHAMAN_PLAYER_END_POS), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(_shaman_actor, "position", _scaled(SHAMAN_ACTOR_END_POS), 0.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	await _start_dialogue_and_wait(SHAMAN_INTRO_DIALOGUE_ID)
	await get_tree().create_timer(SHAMAN_DIALOGUE_PAUSE_SECONDS).timeout
	_show_shaman_choice()

func _run_mine_exit_sequence() -> void:
	_title_label.text = "Mine Exit"
	_player_battle_actor.visible = true
	_player_battle_actor.position = _scaled(MINE_EXIT_PLAYER_START_POS)
	_shaman_actor.position = _scaled(MINE_EXIT_SHAMAN_START_POS)

	var shaman_recruited := bool(_incoming_payload.get("shaman_recruited", false))
	_shaman_actor.visible = shaman_recruited

	var screen_fader = SceneManager.get_screen_fader()
	if screen_fader != null:
		screen_fader.force_black()
		var fade_tween: Tween = screen_fader.fade_from_black(0.45)
		await fade_tween.finished

	var tween := create_tween()
	tween.tween_property(_player_battle_actor, "position", _scaled(MINE_EXIT_PLAYER_END_POS), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if shaman_recruited:
		tween.parallel().tween_property(_shaman_actor, "position", _scaled(MINE_EXIT_SHAMAN_END_POS), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished

	_narration_label.text = "The Shaman walks with you into the light." if shaman_recruited else "You emerge alone. The mine is behind you."
	_narration_label.visible = true
	await get_tree().create_timer(1.5).timeout
	_narration_label.visible = false

	if screen_fader != null:
		var fade_to_black: Tween = screen_fader.fade_to_black(0.35)
		await fade_to_black.finished

	PlayerData.set_flag(MINE_CLEARED_FLAG, true)
	PlayerData.set_flag(MAIN_QUEST_PATH_OPEN_FLAG, true)
	PlayerData.current_region = _return_region_from_payload()
	PlayerData.current_location = _return_location_from_payload()
	SceneManager.change_state("map", {
		"fade_from_black": true,
		"source": "cutscene",
		"return_region": PlayerData.current_region,
		"return_location": PlayerData.current_location,
		"return_position": _return_position_from_payload(),
	})

func _dialogue_for_current_path() -> String:
	var class_label := PlayerData.get_display_class()
	if class_label == "":
		class_label = "wanderer"

	if PlayerData.is_mixed():
		return "Mixed oath and %s training noted. Keep your balance down there; the tunnels choose no side." % class_label

	return "Pure oath and %s discipline noted. Hold your resolve and the mine will open before you." % class_label

func _show_shaman_choice() -> void:
	_choice_panel.visible = true
	_talk_button.disabled = false
	_fight_button.disabled = false
	_talk_button.grab_focus()

func _hide_shaman_choice() -> void:
	_choice_panel.visible = false
	_talk_button.disabled = true
	_fight_button.disabled = true

func _on_talk_button_pressed() -> void:
	if _talk_button.disabled:
		return
	_hide_shaman_choice()
	_run_recruit_branch()

func _on_fight_button_pressed() -> void:
	if _fight_button.disabled:
		return
	_hide_shaman_choice()
	_launch_shaman_battle()

func _on_continue_pressed() -> void:
	if _cutscene_id != CUTSCENE_ID_MINE_ENTRY:
		return
	_continue_button.disabled = true
	_handoff_to_mine_map()

func _handoff_to_mine_map() -> void:
	_handoff_to_mine_map_async()

func _handoff_to_mine_map_async() -> void:
	var screen_fader = SceneManager.get_screen_fader()
	if screen_fader != null:
		var fade_tween: Tween = screen_fader.fade_to_black(0.35)
		await fade_tween.finished

	PlayerData.current_location = MINE_LOCATION
	PlayerData.current_region = MINE_REGION
	SceneManager.change_state("map", {
		"fade_from_black": true,
		"source": "cutscene",
		"return_region": MINE_REGION,
		"return_location": MINE_LOCATION,
	})

func _run_recruit_branch() -> void:
	PlayerData.set_flag(SHAMAN_RECRUITED_FLAG, true)
	PlayerData.set_flag(MINE_BOSS_RESOLVED_FLAG, true)
	PlayerData.set_flag(MINE_EXIT_UNLOCKED_FLAG, true)
	PlayerData.set_ghost_flag("world_remembers_shaman_spared", true)
	if PlayerData.is_pure():
		PlayerData.set_ghost_flag("pure_rep_shaman_mercy", true)

	StatRegistry._increment_stat("social.charm", 3.0)
	StatRegistry._increment_stat("magik.attunement", 2.0)
	StatRegistry._recalculate_luck()

	await _start_dialogue_and_wait(SHAMAN_RECRUIT_DIALOGUE_ID)
	_return_to_map_after_resolution("The Shaman lowers his staff. The chamber is quiet.")

func _launch_shaman_battle() -> void:
	_launch_shaman_battle_async()

func _launch_shaman_battle_async() -> void:
	var screen_fader = SceneManager.get_screen_fader()
	if screen_fader != null:
		var fade_tween: Tween = screen_fader.fade_to_black(0.35)
		await fade_tween.finished

	SceneManager.change_state("battle", {
		"encounter_kind": BATTLE_KIND_BOSS_SHAMAN,
		"encounter_index": -1,
		"return_region": _return_region_from_payload(),
		"return_location": _return_location_from_payload(),
		"return_position": _return_position_from_payload(),
		"environment_id": "mine",
		"suppressed_trigger_type": _suppressed_trigger_type_from_payload(),
		"suppressed_trigger_index": _suppressed_trigger_index_from_payload(),
		"fade_from_black": true,
	})

func _return_to_map_after_resolution(status_text: String) -> void:
	_return_to_map_after_resolution_async(status_text)

func _return_to_map_after_resolution_async(status_text: String) -> void:
	var screen_fader = SceneManager.get_screen_fader()
	if screen_fader != null:
		var fade_tween: Tween = screen_fader.fade_to_black(0.35)
		await fade_tween.finished

	PlayerData.current_region = _return_region_from_payload()
	PlayerData.current_location = _return_location_from_payload()
	SceneManager.change_state("map", {
		"fade_from_black": true,
		"source": "cutscene",
		"status_text": status_text,
		"return_region": PlayerData.current_region,
		"return_location": PlayerData.current_location,
		"return_position": _return_position_from_payload(),
		"suppressed_trigger_type": _suppressed_trigger_type_from_payload(),
		"suppressed_trigger_index": _suppressed_trigger_index_from_payload(),
	})

func _start_dialogue_and_wait(dialogue_id: String) -> void:
	DialogueManager.start_dialogue(dialogue_id)
	if not DialogueManager.is_active():
		await get_tree().process_frame
		return
	await SignalBus.dialogue_ended

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

func _return_region_from_payload() -> String:
	var fallback := CROSSROADS_REGION if _cutscene_id == CUTSCENE_ID_MINE_EXIT else PlayerData.current_region
	return str(_incoming_payload.get("return_region", fallback))

func _return_location_from_payload() -> String:
	var fallback := CROSSROADS_LOCATION if _cutscene_id == CUTSCENE_ID_MINE_EXIT else PlayerData.current_location
	return str(_incoming_payload.get("return_location", fallback))

func _return_position_from_payload() -> Vector2:
	var return_position = _incoming_payload.get("return_position", Vector2.ZERO)
	if return_position is Vector2:
		return return_position
	return Vector2.ZERO

func _suppressed_trigger_type_from_payload() -> String:
	return str(_incoming_payload.get("suppressed_trigger_type", ""))

func _suppressed_trigger_index_from_payload() -> int:
	return int(_incoming_payload.get("suppressed_trigger_index", -1))

func _create_menu_button(label: String) -> Button:
	var button := Button.new()
	button.text = label
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_stylebox_override("normal", _make_button_style(_button_texture))
	button.add_theme_stylebox_override("hover", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))
	button.add_theme_stylebox_override("pressed", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))
	button.add_theme_stylebox_override("disabled", _make_button_style(_button_disabled_texture if _button_disabled_texture != null else _button_texture))
	button.add_theme_stylebox_override("focus", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))
	return button

func _make_panel_style(texture: Texture2D) -> StyleBox:
	if texture == null:
		var fallback := StyleBoxFlat.new()
		fallback.bg_color = Color(0.17, 0.13, 0.11, 0.94)
		fallback.border_color = Color(0.36, 0.27, 0.21, 1.0)
		fallback.set_border_width_all(2)
		fallback.set_corner_radius_all(4)
		return fallback

	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = 14
	style.texture_margin_top = 14
	style.texture_margin_right = 14
	style.texture_margin_bottom = 14
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	return style

func _make_button_style(texture: Texture2D) -> StyleBox:
	if texture == null:
		var fallback := StyleBoxFlat.new()
		fallback.bg_color = Color(0.29, 0.22, 0.18, 1.0)
		fallback.border_color = Color(0.48, 0.36, 0.28, 1.0)
		fallback.set_border_width_all(2)
		fallback.set_corner_radius_all(3)
		fallback.content_margin_left = 6
		fallback.content_margin_right = 6
		fallback.content_margin_top = 4
		fallback.content_margin_bottom = 4
		return fallback

	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = 16
	style.texture_margin_top = 8
	style.texture_margin_right = 16
	style.texture_margin_bottom = 8
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	return style

func _load_player_cutscene_texture() -> Texture2D:
	if PlayerData.resolve_vertical_slice_class_id() == PlayerData.CLASS_BATTLEMAGE:
		return _load_cropped_texture(
			PLAYER_BATTLEMAGE_SPRITE_PATH,
			BATTLEMAGE_PLAYER_REGION,
			_make_fallback_texture(32, 40, Color(0.21, 0.31, 0.55)),
			true,
			true
		)

	return _load_cropped_texture(
		PLAYER_KNIGHT_SPRITE_PATH,
		KNIGHT_PLAYER_REGION,
		_make_fallback_texture(64, 64, Color(0.58, 0.53, 0.47))
	)

func _load_shaman_texture() -> Texture2D:
	return _load_cropped_texture(
		SHAMAN_SPRITE_PATH,
		SHAMAN_SPRITE_REGION,
		_make_fallback_texture(64, 80, Color(0.33, 0.17, 0.41)),
		true,
		true
	)

func _load_texture(resource_path: String) -> Texture2D:
	var image := Image.load_from_file(resource_path)
	if image == null or image.is_empty():
		return null
	return ImageTexture.create_from_image(image)

func _load_cropped_texture(resource_path: String, region: Rect2i, fallback: Texture2D, transparent_black: bool = false, trim_to_visible_bounds: bool = false) -> Texture2D:
	var image := Image.load_from_file(resource_path)
	if image == null or image.is_empty():
		return fallback

	var cropped := image.get_region(region)
	if cropped == null or cropped.is_empty():
		return fallback

	if transparent_black:
		_clear_black_background(cropped)

	if trim_to_visible_bounds:
		cropped = _trim_visible_image(cropped)
		if cropped == null or cropped.is_empty():
			return fallback

	return ImageTexture.create_from_image(cropped)

func _clear_black_background(image: Image) -> void:
	image.convert(Image.FORMAT_RGBA8)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			if pixel.a > 0.0 and pixel.r <= 0.01 and pixel.g <= 0.01 and pixel.b <= 0.01:
				image.set_pixel(x, y, Color(pixel.r, pixel.g, pixel.b, 0.0))

func _trim_visible_image(image: Image) -> Image:
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.05:
				min_x = min(min_x, x)
				min_y = min(min_y, y)
				max_x = max(max_x, x)
				max_y = max(max_y, y)

	if max_x < min_x or max_y < min_y:
		return image

	return image.get_region(Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1))

func _make_fallback_texture(width: int, height: int, color: Color) -> Texture2D:
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)
