extends Node2D

const REFERENCE_VIEWPORT_SIZE := Vector2(480.0, 270.0)

const PLAYER_KNIGHT_SPRITE_PATH := "res://assets/art/player/universal-lpc-sprite_male_01_full.png"
const PLAYER_BATTLEMAGE_SPRITE_PATH := "res://assets/art/battle/LPC_starhat/sample.png"
const ENEMY_KOBOLD_SPRITE_PATH := "res://assets/art/battle/LPC imp/attack - vanilla.png"
const ENEMY_SHAMAN_SPRITE_PATH := "res://assets/art/battle/goblinsword.png"
const MINE_BACKGROUND_PATH := "res://assets/art/battle/monster2_combat_backgrounds/volcano.png"

const UI_PANEL_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/panel_brown.png"
const UI_INSET_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/panelInset_brown.png"
const UI_BUTTON_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/buttonLong_brown.png"
const UI_BUTTON_PRESSED_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/buttonLong_brown_pressed.png"
const UI_BUTTON_DISABLED_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/buttonLong_grey.png"

const BATTLE_KIND_STANDARD := "standard"
const BATTLE_KIND_BOSS_PLACEHOLDER := "boss_placeholder"
const BATTLE_KIND_BOSS_SHAMAN := "boss_shaman"
const BATTLE_KIND_DEBUG := "debug"

const MINE_ENCOUNTER_PROGRESS_FLAG := "mine_encounter_progress"
const MINE_BOSS_READY_FLAG := "mine_boss_ready"
const MINE_BOSS_RESOLVED_FLAG := "mine_boss_resolved"
const MINE_EXIT_UNLOCKED_FLAG := "mine_exit_unlocked"
const SHAMAN_KILLED_FLAG := "shaman_killed"

const KOBOLD_MAX_HP := 30
const KOBOLD_ATTACK_DAMAGE := 6
const KOBOLD_DEFENCE := 3
const KOBOLD_RESISTANCE := 2
const KOBOLD_DEFEND_BONUS := 2
const SHAMAN_MAX_HP := 54
const SHAMAN_ATTACK_DAMAGE := 8
const SHAMAN_DEFENCE := 4
const SHAMAN_RESISTANCE := 3
const SHAMAN_HEAL_AMOUNT := 16
const SHAMAN_HEAL_THRESHOLD_RATIO := 0.4
const SHAMAN_HEX_DAMAGE := 4
const SHAMAN_HEX_PENALTY := 2
const SHAMAN_HEX_TURNS := 2
const SHAMAN_GOLD_REWARD_MIN := 18
const SHAMAN_GOLD_REWARD_MAX := 26
const HEALTH_POTION_HEAL := 20

const KNIGHT_PLAYER_REGION := Rect2i(64, 64, 64, 64)
const BATTLEMAGE_PLAYER_REGION := Rect2i(50, 135, 50, 45)
const KOBOLD_ENEMY_REGION := Rect2i(64, 128, 64, 64)
const SHAMAN_ENEMY_REGION := Rect2i(0, 0, 64, 64)
const PLAYER_TARGET_HEIGHT := 88.0
const ENEMY_TARGET_HEIGHT := 78.0
const SHAMAN_TARGET_HEIGHT := 88.0
const BATTLE_CONTENT_Y_OFFSET := -18.0

const PLAYER_IDLE_POSITION := Vector2(146.0, 154.0)
const ENEMY_IDLE_POSITION := Vector2(338.0, 146.0)
const PLAYER_HP_UI_POSITION := Vector2(66.0, 56.0)
const ENEMY_HP_UI_POSITION := Vector2(274.0, 56.0)

const FIGHTER_ABILITY_LABEL := "Shield Bash"
const BATTLEMAGE_ABILITY_LABEL := "Arcane Strike"

const FLASH_SHADER := preload("res://scenes/battle/HitFlash.gdshader")

var _context: Dictionary = {}
var _ui_root: Control
var _battle_camera: Camera2D
var _player_sprite: Sprite2D
var _enemy_sprite: Sprite2D
var _player_hp_fill: ColorRect
var _player_hp_label: Label
var _player_name_label: Label
var _enemy_hp_fill: ColorRect
var _enemy_hp_label: Label
var _enemy_name_label: Label
var _turn_label: Label
var _log_label: RichTextLabel
var _main_menu_panel: PanelContainer
var _main_menu_grid: GridContainer
var _submenu_panel: PanelContainer
var _submenu_list: VBoxContainer
var _attack_button: Button
var _spell_button: Button
var _item_button: Button
var _flee_button: Button
var _ability_button: Button
var _center_banner: Label
var _loot_panel: PanelContainer
var _loot_label: Label
var _boss_placeholder_panel: PanelContainer
var _boss_placeholder_label: Label
var _game_over_panel: PanelContainer
var _game_over_label: Label
var _try_again_button: Button
var _quit_button: Button

var _panel_texture: Texture2D
var _inset_texture: Texture2D
var _button_texture: Texture2D
var _button_pressed_texture: Texture2D
var _button_disabled_texture: Texture2D
var _background_texture: Texture2D
var _player_base_position := Vector2.ZERO
var _enemy_base_position := Vector2.ZERO
var _player_base_scale := Vector2.ONE
var _enemy_base_scale := Vector2.ONE
var _player_scale_multiplier := 1.4
var _enemy_scale_multiplier := 1.5
var _log_lines: Array[String] = []
var _player_turn_count := 0
var _ability_cooldown_remaining := 0
var _enemy_hp := KOBOLD_MAX_HP
var _enemy_max_hp := KOBOLD_MAX_HP
var _enemy_attack_damage := KOBOLD_ATTACK_DAMAGE
var _enemy_defence := KOBOLD_DEFENCE
var _enemy_resistance := KOBOLD_RESISTANCE
var _enemy_defend_bonus := KOBOLD_DEFEND_BONUS
var _enemy_display_name := "Kobold"
var _enemy_intro_log := "A kobold rushes from the dark."
var _enemy_defend_active := false
var _enemy_staggered := false
var _input_locked := true
var _battle_over := false
var _boss_placeholder_mode := false
var _shaman_boss_mode := false
var _shaman_heal_used := false
var _player_hex_turns_remaining := 0
var _bob_time := 0.0
var _player_class_id := ""
var _last_viewport_size := Vector2.ZERO

func _ready() -> void:
    randomize()
    _context = SceneManager.consume_state_payload()
    _load_ui_textures()
    _build_scene()
    _configure_battle_state()
    _layout_scene()
    _refresh_all_ui()

    if not get_viewport().size_changed.is_connected(_on_viewport_size_changed):
        get_viewport().size_changed.connect(_on_viewport_size_changed)

    call_deferred("_start_battle_flow")

func _process(delta: float) -> void:
    _bob_time += delta
    if is_instance_valid(_player_sprite):
        _player_sprite.position = _player_base_position + Vector2(0.0, sin(_bob_time * 2.8) * _scale_y(3.0))
    if is_instance_valid(_enemy_sprite) and not _battle_over:
        _enemy_sprite.position = _enemy_base_position + Vector2(0.0, sin(_bob_time * 3.0 + 0.8) * _scale_y(2.5))
	if is_instance_valid(_player_sprite):
		_player_sprite.position = _player_base_position + Vector2(0.0, sin(_bob_time * 2.8) * _scale_y(3.0))
	if is_instance_valid(_enemy_sprite) and not _battle_over:
		_enemy_sprite.position = _enemy_base_position + Vector2(0.0, sin(_bob_time * 3.0 + 0.8) * _scale_y(2.5))

func _draw() -> void:
	var viewport_size := get_viewport_rect().size
	if _background_texture != null:
		draw_texture_rect(_background_texture, Rect2(Vector2.ZERO, viewport_size), true)
		draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.08, 0.07, 0.08, 0.18), true)
	else:
		draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.11, 0.12, 0.13), true)
		draw_rect(Rect2(Vector2(0.0, 0.0), Vector2(viewport_size.x, viewport_size.y * 0.6)), Color(0.18, 0.18, 0.19, 0.85), true)

	draw_rect(
		Rect2(Vector2(0.0, viewport_size.y * 0.6), Vector2(viewport_size.x, viewport_size.y * 0.4)),
		Color(0.16, 0.12, 0.10, 0.92),
		true
	)

func _unhandled_input(event: InputEvent) -> void:
	if _input_locked or _battle_over:
		return

	if event.is_action_pressed("ui_cancel") and _submenu_panel.visible:
		get_viewport().set_input_as_handled()
		_show_main_menu()

func _load_ui_textures() -> void:
	_panel_texture = load(UI_PANEL_TEXTURE_PATH) as Texture2D
	_inset_texture = load(UI_INSET_TEXTURE_PATH) as Texture2D
	_button_texture = load(UI_BUTTON_TEXTURE_PATH) as Texture2D
	_button_pressed_texture = load(UI_BUTTON_PRESSED_TEXTURE_PATH) as Texture2D
	_button_disabled_texture = load(UI_BUTTON_DISABLED_TEXTURE_PATH) as Texture2D

func _build_scene() -> void:
	_battle_camera = Camera2D.new()
	_battle_camera.name = "BattleCamera"
	_battle_camera.enabled = true
	_battle_camera.position_smoothing_enabled = false
	_battle_camera.make_current()
	add_child(_battle_camera)

	_player_sprite = Sprite2D.new()
	_player_sprite.centered = true
	_player_sprite.texture = _make_fallback_texture(64, 64, Color(0.58, 0.53, 0.47))
	_player_sprite.material = _make_flash_material()
	add_child(_player_sprite)

	_enemy_sprite = Sprite2D.new()
	_enemy_sprite.centered = true
	_enemy_sprite.texture = _make_fallback_texture(64, 64, Color(0.45, 0.15, 0.14))
	_enemy_sprite.material = _make_flash_material()
	add_child(_enemy_sprite)

	_background_texture = _load_texture(MINE_BACKGROUND_PATH) if _environment_id() == "mine" else null

	var ui_layer := CanvasLayer.new()
	ui_layer.layer = 5
	add_child(ui_layer)

	_ui_root = Control.new()
	_ui_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui_root.mouse_filter = Control.MOUSE_FILTER_PASS
	ui_layer.add_child(_ui_root)

	_build_hp_widgets()
	_build_log_panel()
	_build_turn_label()
	_build_main_menu()
	_build_submenu()
	_build_center_overlays()

func _build_hp_widgets() -> void:
	var player_widgets := _create_hp_widget("Player")
	_player_name_label = player_widgets["name_label"]
	_player_hp_fill = player_widgets["fill"]
	_player_hp_label = player_widgets["value_label"]

	var enemy_widgets := _create_hp_widget("Enemy")
	_enemy_name_label = enemy_widgets["name_label"]
	_enemy_hp_fill = enemy_widgets["fill"]
	_enemy_hp_label = enemy_widgets["value_label"]

func _create_hp_widget(default_name: String) -> Dictionary:
	var container := Control.new()
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.custom_minimum_size = Vector2(_scale_x(140.0), _scale_y(42.0))
	_ui_root.add_child(container)

	var name_label := Label.new()
	name_label.text = default_name
	name_label.add_theme_font_size_override("font_size", int(_scale_font(8.0)))
	container.add_child(name_label)

	var bar_back := ColorRect.new()
	bar_back.color = Color(0.08, 0.06, 0.05, 0.82)
	container.add_child(bar_back)

	var fill := ColorRect.new()
	fill.color = Color(0.22, 0.74, 0.28, 1.0)
	bar_back.add_child(fill)

	var value_label := Label.new()
	value_label.add_theme_font_size_override("font_size", int(_scale_font(8.0)))
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	container.add_child(value_label)

	return {
		"container": container,
		"name_label": name_label,
		"fill": fill,
		"value_label": value_label,
	}

func _build_log_panel() -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(_panel_texture))
	_ui_root.add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	_log_label = RichTextLabel.new()
	_log_label.fit_content = false
	_log_label.bbcode_enabled = false
	_log_label.scroll_active = true
	_log_label.selection_enabled = false
	_log_label.add_theme_font_size_override("normal_font_size", int(_scale_font(8.0)))
	margin.add_child(_log_label)
	panel.name = "LogPanel"

func _build_turn_label() -> void:
	_turn_label = Label.new()
	_turn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_turn_label.add_theme_font_size_override("font_size", int(_scale_font(9.0)))
	_ui_root.add_child(_turn_label)

func _build_main_menu() -> void:
	_main_menu_panel = PanelContainer.new()
	_main_menu_panel.add_theme_stylebox_override("panel", _make_panel_style(_panel_texture))
	_ui_root.add_child(_main_menu_panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	_main_menu_panel.add_child(margin)

	_main_menu_grid = GridContainer.new()
	_main_menu_grid.columns = 5
	_main_menu_grid.add_theme_constant_override("h_separation", 6)
	_main_menu_grid.add_theme_constant_override("v_separation", 6)
	margin.add_child(_main_menu_grid)

	_attack_button = _create_action_button("Attack", "_on_attack_pressed")
	_spell_button = _create_action_button("Spell", "_on_spell_pressed")
	_item_button = _create_action_button("Item", "_on_item_pressed")
	_flee_button = _create_action_button("Flee", "_on_flee_pressed")
	_ability_button = _create_action_button("Ability", "_on_ability_pressed")

func _build_submenu() -> void:
	_submenu_panel = PanelContainer.new()
	_submenu_panel.visible = false
	_submenu_panel.add_theme_stylebox_override("panel", _make_panel_style(_panel_texture))
	_ui_root.add_child(_submenu_panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	_submenu_panel.add_child(margin)

	_submenu_list = VBoxContainer.new()
	_submenu_list.add_theme_constant_override("separation", 6)
	margin.add_child(_submenu_list)

func _build_center_overlays() -> void:
	_center_banner = Label.new()
	_center_banner.visible = false
	_center_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_center_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_center_banner.add_theme_font_size_override("font_size", int(_scale_font(14.0)))
	_ui_root.add_child(_center_banner)

	_loot_panel = PanelContainer.new()
	_loot_panel.visible = false
	_loot_panel.add_theme_stylebox_override("panel", _make_panel_style(_panel_texture))
	_ui_root.add_child(_loot_panel)

	var loot_margin := MarginContainer.new()
	loot_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	loot_margin.add_theme_constant_override("margin_left", 14)
	loot_margin.add_theme_constant_override("margin_top", 12)
	loot_margin.add_theme_constant_override("margin_right", 14)
	loot_margin.add_theme_constant_override("margin_bottom", 12)
	_loot_panel.add_child(loot_margin)

	_loot_label = Label.new()
	_loot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_loot_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_loot_label.add_theme_font_size_override("font_size", int(_scale_font(9.0)))
	loot_margin.add_child(_loot_label)

	_boss_placeholder_panel = PanelContainer.new()
	_boss_placeholder_panel.visible = false
	_boss_placeholder_panel.add_theme_stylebox_override("panel", _make_panel_style(_panel_texture))
	_ui_root.add_child(_boss_placeholder_panel)

	var boss_margin := MarginContainer.new()
	boss_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	boss_margin.add_theme_constant_override("margin_left", 16)
	boss_margin.add_theme_constant_override("margin_top", 14)
	boss_margin.add_theme_constant_override("margin_right", 16)
	boss_margin.add_theme_constant_override("margin_bottom", 14)
	_boss_placeholder_panel.add_child(boss_margin)

	_boss_placeholder_label = Label.new()
	_boss_placeholder_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_placeholder_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_boss_placeholder_label.text = "Boss encounter — Stage 6"
	_boss_placeholder_label.add_theme_font_size_override("font_size", int(_scale_font(10.0)))
	boss_margin.add_child(_boss_placeholder_label)

	_game_over_panel = PanelContainer.new()
	_game_over_panel.visible = false
	_game_over_panel.add_theme_stylebox_override("panel", _make_panel_style(_panel_texture))
	_ui_root.add_child(_game_over_panel)

	var game_over_margin := MarginContainer.new()
	game_over_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_over_margin.add_theme_constant_override("margin_left", 16)
	game_over_margin.add_theme_constant_override("margin_top", 14)
	game_over_margin.add_theme_constant_override("margin_right", 16)
	game_over_margin.add_theme_constant_override("margin_bottom", 14)
	_game_over_panel.add_child(game_over_margin)

	var game_over_content := VBoxContainer.new()
	game_over_content.add_theme_constant_override("separation", 10)
	game_over_margin.add_child(game_over_content)

	_game_over_label = Label.new()
	_game_over_label.text = "You have fallen."
	_game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_game_over_label.add_theme_font_size_override("font_size", int(_scale_font(10.0)))
	game_over_content.add_child(_game_over_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 8)
	game_over_content.add_child(button_row)

	_try_again_button = _create_menu_button("Try Again")
	_try_again_button.pressed.connect(_on_try_again_pressed)
	button_row.add_child(_try_again_button)

	_quit_button = _create_menu_button("Quit")
	_quit_button.pressed.connect(_on_quit_pressed)
	button_row.add_child(_quit_button)

func _configure_battle_state() -> void:
	_player_class_id = PlayerData.resolve_vertical_slice_class_id()
	if _player_class_id == "":
		PlayerData.ensure_spike_defaults()
		_player_class_id = PlayerData.resolve_vertical_slice_class_id()

	_apply_battle_sprite_art()
	PlayerData.ensure_vertical_slice_inventory()
	if PlayerData.current_hp <= 0:
		PlayerData.restore_hp_full()

	_boss_placeholder_mode = _encounter_kind() == BATTLE_KIND_BOSS_PLACEHOLDER
	_player_name_label.text = PlayerData.get_display_class()
	_enemy_name_label.text = "Kobold" if not _boss_placeholder_mode else "Boss Gate"
	_append_log("A kobold rushes from the dark." if not _boss_placeholder_mode else "The sealed chamber stirs.")

func _layout_scene() -> void:
	var viewport_size := get_viewport_rect().size
	_last_viewport_size = viewport_size
	queue_redraw()
	var content_offset := Vector2(0.0, _scale_y(BATTLE_CONTENT_Y_OFFSET))

	_battle_camera.position = viewport_size * 0.5
	_player_base_position = _scaled_position(PLAYER_IDLE_POSITION) + content_offset
	_enemy_base_position = _scaled_position(ENEMY_IDLE_POSITION) + content_offset
	_player_base_scale = Vector2.ONE * minf(_scale_x(_player_scale_multiplier), _scale_y(_player_scale_multiplier))
	_enemy_base_scale = Vector2.ONE * minf(_scale_x(_enemy_scale_multiplier), _scale_y(_enemy_scale_multiplier))
	_player_sprite.scale = _player_base_scale
	_enemy_sprite.scale = _enemy_base_scale

	_position_hp_widget(_player_name_label.get_parent(), _scaled_position(PLAYER_HP_UI_POSITION) + content_offset)
	_position_hp_widget(_enemy_name_label.get_parent(), _scaled_position(ENEMY_HP_UI_POSITION) + content_offset)

	var turn_width := _scale_x(140.0)
	_turn_label.position = Vector2((viewport_size.x - turn_width) * 0.5, _scale_y(180.0 + BATTLE_CONTENT_Y_OFFSET))
	_turn_label.size = Vector2(turn_width, _scale_y(18.0))

	var log_panel := _ui_root.get_node("LogPanel") as PanelContainer
	log_panel.position = Vector2(_scale_x(42.0), _scale_y(190.0 + BATTLE_CONTENT_Y_OFFSET))
	log_panel.size = Vector2(_scale_x(396.0), _scale_y(48.0))

	_main_menu_panel.position = Vector2(_scale_x(28.0), _scale_y(222.0))
	_main_menu_panel.size = Vector2(_scale_x(424.0), _scale_y(40.0))
	_layout_submenu_panel(viewport_size)

	_center_banner.position = Vector2(_scale_x(120.0), _scale_y(98.0 + BATTLE_CONTENT_Y_OFFSET))
	_center_banner.size = Vector2(_scale_x(240.0), _scale_y(32.0))

	_loot_panel.position = Vector2(_scale_x(126.0), _scale_y(116.0 + BATTLE_CONTENT_Y_OFFSET))
	_loot_panel.size = Vector2(_scale_x(228.0), _scale_y(52.0))

	_boss_placeholder_panel.position = Vector2(_scale_x(110.0), _scale_y(110.0 + BATTLE_CONTENT_Y_OFFSET))
	_boss_placeholder_panel.size = Vector2(_scale_x(260.0), _scale_y(52.0))

	_game_over_panel.position = Vector2(_scale_x(108.0), _scale_y(92.0 + BATTLE_CONTENT_Y_OFFSET))
	_game_over_panel.size = Vector2(_scale_x(264.0), _scale_y(86.0))

	_try_again_button.custom_minimum_size = Vector2(_scale_x(92.0), _scale_y(26.0))
	_quit_button.custom_minimum_size = Vector2(_scale_x(92.0), _scale_y(26.0))

	for child in _main_menu_grid.get_children():
		if child is Button:
			(child as Button).custom_minimum_size = Vector2(_scale_x(72.0), _scale_y(20.0))
			(child as Button).add_theme_font_size_override("font_size", int(_scale_font(8.0)))

	for child in _submenu_list.get_children():
		if child is Button:
			(child as Button).custom_minimum_size = Vector2(_scale_x(180.0), _scale_y(20.0))
			(child as Button).add_theme_font_size_override("font_size", int(_scale_font(8.0)))

func _layout_submenu_panel(viewport_size: Vector2) -> void:
	var button_count := maxi(_submenu_list.get_child_count(), 1)
	var panel_width := _scale_x(240.0)
	var button_height := _scale_y(20.0)
	var vertical_padding := _scale_y(10.0)
	var separation := _scale_y(6.0)
	var content_height := (button_height * button_count) + (separation * maxi(0, button_count - 1))
	var panel_height := (vertical_padding * 2.0) + content_height
	_submenu_panel.size = Vector2(panel_width, panel_height)
	_submenu_panel.position.x = (viewport_size.x - panel_width) * 0.5
	var desired_y := _main_menu_panel.position.y - panel_height - _scale_y(6.0)
	var min_top := _scale_y(8.0)
	var max_top := maxf(min_top, viewport_size.y - panel_height - _scale_y(8.0))
	_submenu_panel.position.y = clampf(desired_y, min_top, max_top)

func _apply_battle_sprite_art() -> void:
	if _player_class_id == PlayerData.CLASS_BATTLEMAGE:
		_player_sprite.texture = _load_cropped_texture(
			PLAYER_BATTLEMAGE_SPRITE_PATH,
			BATTLEMAGE_PLAYER_REGION,
			_make_fallback_texture(32, 40, Color(0.21, 0.31, 0.55)),
			true,
			false
		)
		_player_sprite.flip_h = false
		_player_scale_multiplier = _reference_scale_for_height(_player_sprite.texture, PLAYER_TARGET_HEIGHT, 2.0)
	else:
		_player_sprite.texture = _load_cropped_texture(
			PLAYER_KNIGHT_SPRITE_PATH,
			KNIGHT_PLAYER_REGION,
			_make_fallback_texture(64, 64, Color(0.58, 0.53, 0.47))
		)
		_player_sprite.flip_h = true
		_player_scale_multiplier = _reference_scale_for_height(_player_sprite.texture, PLAYER_TARGET_HEIGHT, 1.4)

	_enemy_sprite.texture = _load_cropped_texture(
		ENEMY_KOBOLD_SPRITE_PATH,
		KOBOLD_ENEMY_REGION,
		_make_fallback_texture(64, 64, Color(0.45, 0.15, 0.14))
	)
	_enemy_sprite.flip_h = true
	_enemy_scale_multiplier = _reference_scale_for_height(_enemy_sprite.texture, ENEMY_TARGET_HEIGHT, 1.5)

func _position_hp_widget(container: Node, top_left: Vector2) -> void:
	var widget := container as Control
	widget.position = top_left
	widget.size = Vector2(_scale_x(140.0), _scale_y(40.0))

	var name_label := widget.get_child(0) as Label
	name_label.position = Vector2.ZERO
	name_label.size = Vector2(widget.size.x, _scale_y(10.0))

	var bar_back := widget.get_child(1) as ColorRect
	bar_back.position = Vector2(0.0, _scale_y(14.0))
	bar_back.size = Vector2(widget.size.x, _scale_y(10.0))

	var fill := bar_back.get_child(0) as ColorRect
	fill.position = Vector2.ZERO
	fill.size = bar_back.size

	var value_label := widget.get_child(2) as Label
	value_label.position = Vector2(0.0, _scale_y(26.0))
	value_label.size = Vector2(widget.size.x, _scale_y(12.0))

func _refresh_all_ui() -> void:
	_refresh_hp_ui()
	_refresh_log_ui()
	_refresh_turn_label()
	_refresh_main_menu_buttons()

func _refresh_hp_ui() -> void:
	_update_hp_widget(_player_hp_fill, _player_hp_label, PlayerData.current_hp, PlayerData.get_max_hp())
	_update_hp_widget(_enemy_hp_fill, _enemy_hp_label, _enemy_hp, KOBOLD_MAX_HP)

func _update_hp_widget(fill: ColorRect, value_label: Label, current_hp: int, max_hp: int) -> void:
	var ratio := 0.0 if max_hp <= 0 else clampf(float(current_hp) / float(max_hp), 0.0, 1.0)
	fill.size.x = maxf(1.0, (fill.get_parent() as ColorRect).size.x * ratio)
	fill.color = Color(1.0 - ratio * 0.75, 0.18 + ratio * 0.62, 0.18, 1.0)
	value_label.text = "%d / %d" % [current_hp, max_hp]

func _refresh_log_ui() -> void:
	_log_label.text = "\n".join(_log_lines)
	_log_label.scroll_to_line(maxi(0, _log_lines.size() - 1))

func _refresh_turn_label() -> void:
	if _battle_over:
		return

	_turn_label.text = "Enemy Turn" if _input_locked else "Your Turn"

func _refresh_main_menu_buttons() -> void:
	if _attack_button == null:
		return

	var can_act := not _input_locked and not _battle_over and not _boss_placeholder_mode
	_attack_button.disabled = not can_act
	_spell_button.disabled = not can_act or not PlayerData.has_battle_magik()
	_spell_button.tooltip_text = "" if PlayerData.has_battle_magik() else "No Magik ability."
	_item_button.disabled = not can_act or PlayerData.get_item_count(PlayerData.HEALTH_POTION_ID) <= 0
	_item_button.tooltip_text = "" if PlayerData.get_item_count(PlayerData.HEALTH_POTION_ID) > 0 else "No items."
	_flee_button.disabled = not can_act
	_ability_button.disabled = not can_act or _ability_cooldown_remaining > 0
	_ability_button.text = _ability_button_text()
	_ability_button.tooltip_text = "" if _ability_cooldown_remaining <= 0 else "Cooldown: %d turn(s)." % _ability_cooldown_remaining

func _ability_button_text() -> String:
	var base_label := FIGHTER_ABILITY_LABEL if _player_class_id == PlayerData.CLASS_FIGHTER else BATTLEMAGE_ABILITY_LABEL
	if _ability_cooldown_remaining > 0:
		return "%s (%d)" % [base_label, _ability_cooldown_remaining]
	return base_label

func _append_log(message: String) -> void:
	_log_lines.append(message)
	while _log_lines.size() > 4:
		_log_lines.remove_at(0)
	_refresh_log_ui()

func _show_main_menu() -> void:
	_submenu_panel.visible = false
	_main_menu_panel.visible = true
	_refresh_main_menu_buttons()
	call_deferred("_focus_first_available_button")

func _show_submenu(entries: Array[Dictionary]) -> void:
	for child in _submenu_list.get_children():
		child.queue_free()

	for entry_value in entries:
		var entry: Dictionary = entry_value
		var button := _create_menu_button(str(entry.get("label", "Option")))
		button.custom_minimum_size = Vector2(_scale_x(180.0), _scale_y(20.0))
		button.pressed.connect(_on_submenu_option_pressed.bind(str(entry.get("action", ""))))
		button.tooltip_text = str(entry.get("tooltip", ""))
		button.disabled = bool(entry.get("disabled", false))
		_submenu_list.add_child(button)

	var back_button := _create_menu_button("Back")
	back_button.custom_minimum_size = Vector2(_scale_x(180.0), _scale_y(20.0))
	back_button.pressed.connect(_show_main_menu)
	_submenu_list.add_child(back_button)

	_layout_submenu_panel(get_viewport_rect().size)
	_main_menu_panel.visible = false
	_submenu_panel.visible = true
	call_deferred("_focus_first_submenu_button")

func _focus_first_available_button() -> void:
	for button in [_attack_button, _spell_button, _item_button, _flee_button, _ability_button]:
		if button != null and not button.disabled:
			button.grab_focus()
			return

func _focus_first_submenu_button() -> void:
	for child in _submenu_list.get_children():
		if child is Button and not (child as Button).disabled:
			(child as Button).grab_focus()
			return

func _start_battle_flow() -> void:
	var screen_fader = SceneManager.get_screen_fader()
	if screen_fader != null:
		screen_fader.force_black()
		var fade_tween: Tween = screen_fader.fade_from_black(0.35)
		await fade_tween.finished

	if _boss_placeholder_mode:
		_run_boss_placeholder_sequence()
		return

	_begin_player_turn()

func _begin_player_turn() -> void:
	_player_turn_count += 1
	if _player_turn_count > 1 and _ability_cooldown_remaining > 0:
		_ability_cooldown_remaining -= 1

	_input_locked = false
	_show_main_menu()
	_append_log("Your turn.")
	_refresh_all_ui()

func _begin_enemy_turn() -> void:
	_input_locked = true
	_main_menu_panel.visible = false
	_submenu_panel.visible = false
	_refresh_turn_label()
	await get_tree().create_timer(0.5).timeout

	if _battle_over:
		return

	if randf() <= 0.2:
		_run_enemy_defend()
	else:
		_run_enemy_attack()

func _run_enemy_attack() -> void:
	if _enemy_staggered and randf() <= 0.5:
		_enemy_staggered = false
		_append_log("Kobold stumbles and misses.")
		await get_tree().create_timer(0.4).timeout
		_begin_player_turn()
		return

	_enemy_staggered = false
	PlayerData.take_battle_damage(KOBOLD_ATTACK_DAMAGE)
	SignalBus.action_performed.emit({"type": "take_damage", "source": "kobold"})
	_flash_sprite(_player_sprite)
	_refresh_hp_ui()
	_append_log("Kobold attacks for %d damage." % KOBOLD_ATTACK_DAMAGE)
	if KOBOLD_ATTACK_DAMAGE >= 10:
		_shake_camera(8.0)

	if PlayerData.current_hp <= 0:
		_run_defeat_sequence()
		return

	await get_tree().create_timer(0.55).timeout
	_begin_player_turn()

func _run_enemy_defend() -> void:
	_enemy_defend_active = true
	_enemy_staggered = false
	_append_log("Kobold braces behind a jagged guard.")
	await get_tree().create_timer(0.45).timeout
	_begin_player_turn()

func _on_attack_pressed() -> void:
	if _input_locked:
		return
	_resolve_player_attack()

func _on_spell_pressed() -> void:
	if _input_locked or not PlayerData.has_battle_magik():
		return

	_show_submenu([
		{
			"label": "Flamebolt",
			"action": "cast_flamebolt",
		},
	])

func _on_item_pressed() -> void:
	if _input_locked:
		return

	_show_submenu([
		{
			"label": "Health Potion x%d" % PlayerData.get_item_count(PlayerData.HEALTH_POTION_ID),
			"action": "use_health_potion",
			"disabled": PlayerData.get_item_count(PlayerData.HEALTH_POTION_ID) <= 0,
		},
	])

func _on_flee_pressed() -> void:
	if _input_locked:
		return
	_attempt_flee()

func _on_ability_pressed() -> void:
	if _input_locked or _ability_cooldown_remaining > 0:
		return

	if _player_class_id == PlayerData.CLASS_FIGHTER:
		_resolve_shield_bash()
	else:
		_resolve_arcane_strike()

func _on_submenu_option_pressed(action_id: String) -> void:
	match action_id:
		"cast_flamebolt":
			_resolve_flamebolt()
		"use_health_potion":
			_use_health_potion()

func _resolve_player_attack() -> void:
	_input_locked = true
	SignalBus.action_performed.emit({"type": "attack", "context": "battle"})
	var damage := _calculate_physical_damage(_player_strength_for_attack() + PlayerData.get_battle_weapon_modifier())
	_apply_damage_to_enemy(damage, "You attack for %d damage." % damage, true)

func _resolve_flamebolt() -> void:
	_input_locked = true
	SignalBus.action_performed.emit({"type": "cast", "spell": "flamebolt"})
	var spell_power := 6 if _player_class_id == PlayerData.CLASS_BATTLEMAGE else 8
	var base_damage := int(round(StatRegistry.get_stat("magik.spellcasting"))) + spell_power
	var damage := maxi(1, base_damage - KOBOLD_RESISTANCE)
	_apply_damage_to_enemy(damage, "Flamebolt scorches the kobold for %d damage." % damage, true)

func _use_health_potion() -> void:
	if PlayerData.get_item_count(PlayerData.HEALTH_POTION_ID) <= 0:
		_show_main_menu()
		return

	if PlayerData.current_hp >= PlayerData.get_max_hp():
		_append_log("You are already at full health.")
		_show_main_menu()
		return

	_input_locked = true
	PlayerData.consume_item(PlayerData.HEALTH_POTION_ID, 1)
	var healed := PlayerData.heal_hp(HEALTH_POTION_HEAL)
	_refresh_hp_ui()
	_append_log("You drink a potion and recover %d HP." % healed)
	await get_tree().create_timer(0.45).timeout
	_finish_player_turn()

func _attempt_flee() -> void:
	_input_locked = true
	SignalBus.action_performed.emit({"type": "flee_attempt"})
	var resolve := int(round(StatRegistry.get_stat("will.resolve")))
	var flee_chance := clampi(60 + ((resolve - 5) * 5), 10, 95)
	if randi_range(1, 100) <= flee_chance:
		_append_log("You fled successfully.")
		await get_tree().create_timer(0.45).timeout
		_return_to_map("You fled successfully.", str(_context.get("suppressed_trigger_type", "")), int(_context.get("suppressed_trigger_index", -1)))
		return

	_append_log("You fail to flee and lose the turn.")
	await get_tree().create_timer(0.45).timeout
	_finish_player_turn()

func _resolve_shield_bash() -> void:
	_input_locked = true
	SignalBus.action_performed.emit({"type": "shield_bash"})
	var damage := _calculate_physical_damage(_player_strength_for_attack() + 3)
	_enemy_staggered = true
	_ability_cooldown_remaining = 4
	_apply_damage_to_enemy(damage, "Shield Bash hits for %d damage and staggers the kobold." % damage, true, true)

func _resolve_arcane_strike() -> void:
	_input_locked = true
	SignalBus.action_performed.emit({"type": "arcane_strike"})
	var physical_damage := _calculate_physical_damage(_player_strength_for_attack() + PlayerData.get_battle_weapon_modifier())
	var magik_damage := 4
	var total_damage := physical_damage + magik_damage
	_ability_cooldown_remaining = 3
	_apply_damage_to_enemy(total_damage, "Arcane Strike lands for %d physical + %d magik damage." % [physical_damage, magik_damage], true, true)

func _calculate_physical_damage(attack_power: int) -> int:
	var defence := KOBOLD_DEFENCE + (KOBOLD_DEFEND_BONUS if _enemy_defend_active else 0)
	return maxi(1, attack_power - defence)

func _player_strength_for_attack() -> int:
	var base_strength := int(round(StatRegistry.get_stat("physical.strength")))
	if _player_class_id == PlayerData.CLASS_FIGHTER:
		base_strength += 2
	return base_strength

func _apply_damage_to_enemy(damage: int, log_text: String, consume_defend_bonus: bool, is_heavy: bool = false) -> void:
	_enemy_hp = maxi(0, _enemy_hp - damage)
	_flash_sprite(_enemy_sprite)
	if damage >= 10 or is_heavy:
		_shake_camera(8.0)
	_refresh_hp_ui()
	_append_log(log_text)

	if consume_defend_bonus:
		_enemy_defend_active = false

	if _enemy_hp <= 0:
		_run_victory_sequence()
		return

	await get_tree().create_timer(0.5).timeout
	_finish_player_turn()

func _finish_player_turn() -> void:
	if _battle_over:
		return
	_enemy_defend_active = false
	_begin_enemy_turn()

func _run_victory_sequence() -> void:
	_battle_over = true
	_input_locked = true
	_main_menu_panel.visible = false
	_submenu_panel.visible = false
	_turn_label.text = ""

	var death_tween := create_tween()
	death_tween.tween_property(_enemy_sprite, "scale", Vector2.ZERO, 0.3)
	await death_tween.finished

	_center_banner.text = "Victory!"
	_center_banner.visible = true
	await get_tree().create_timer(1.5).timeout
	_center_banner.visible = false

	var gold_reward := randi_range(10, 15)
	PlayerData.gold += gold_reward
	SignalBus.action_performed.emit({"type": "battle_victory"})

	if _encounter_kind() == BATTLE_KIND_STANDARD:
		var encounter_index := int(_context.get("encounter_index", -1))
		var new_progress := maxi(int(PlayerData.get_flag(MINE_ENCOUNTER_PROGRESS_FLAG, 0)), encounter_index + 1)
		PlayerData.set_flag(MINE_ENCOUNTER_PROGRESS_FLAG, new_progress)
		if new_progress >= 3 and not PlayerData.get_flag(MINE_BOSS_READY_FLAG, false):
			PlayerData.set_flag(MINE_BOSS_READY_FLAG, true)

	_loot_label.text = "Victory!\nGold found: %d" % gold_reward
	_loot_panel.visible = true
	await get_tree().create_timer(1.2).timeout
	_loot_panel.visible = false

	var status_text := "Victory! You recover %d gold." % gold_reward
	if _encounter_kind() == BATTLE_KIND_STANDARD and int(PlayerData.get_flag(MINE_ENCOUNTER_PROGRESS_FLAG, 0)) >= 3:
		status_text = "Victory! You recover %d gold. Boss chamber unlocked." % gold_reward

	_return_to_map(status_text, str(_context.get("suppressed_trigger_type", "")), int(_context.get("suppressed_trigger_index", -1)))

func _run_defeat_sequence() -> void:
	_battle_over = true
	_input_locked = true
	_main_menu_panel.visible = false
	_submenu_panel.visible = false
	_turn_label.text = ""

	for _flash_index in range(3):
		_player_sprite.modulate = Color(1.0, 0.3, 0.3, 1.0)
		await get_tree().create_timer(0.12).timeout
		_player_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		await get_tree().create_timer(0.12).timeout

	_center_banner.text = "Defeated."
	_center_banner.visible = true
	await get_tree().create_timer(0.8).timeout
	_center_banner.visible = false

	_game_over_panel.visible = true
	_try_again_button.grab_focus()

func _run_boss_placeholder_sequence() -> void:
	_battle_over = true
	_input_locked = true
	_main_menu_panel.visible = false
	_submenu_panel.visible = false
	_turn_label.text = ""
	_boss_placeholder_panel.visible = true
	_append_log("Boss encounter — Stage 6.")
	await get_tree().create_timer(2.0).timeout
	_boss_placeholder_panel.visible = false
	_return_to_map("Boss encounter — Stage 6.", str(_context.get("suppressed_trigger_type", "")), int(_context.get("suppressed_trigger_index", -1)))

func _return_to_map(status_text: String, suppressed_trigger_type: String, suppressed_trigger_index: int) -> void:
	_return_to_map_async(status_text, suppressed_trigger_type, suppressed_trigger_index)

func _return_to_map_async(status_text: String, suppressed_trigger_type: String, suppressed_trigger_index: int) -> void:
	var screen_fader = SceneManager.get_screen_fader()
	if screen_fader != null:
		var fade_tween: Tween = screen_fader.fade_to_black(0.35)
		await fade_tween.finished

	PlayerData.current_region = str(_context.get("return_region", PlayerData.current_region))
	PlayerData.current_location = str(_context.get("return_location", PlayerData.current_location))
	SceneManager.change_state("map", {
		"fade_from_black": true,
		"source": "battle",
		"status_text": status_text,
		"return_region": PlayerData.current_region,
		"return_location": PlayerData.current_location,
		"return_position": _context.get("return_position", Vector2.ZERO),
		"suppressed_trigger_type": suppressed_trigger_type,
		"suppressed_trigger_index": suppressed_trigger_index,
	})

func _on_try_again_pressed() -> void:
	PlayerData.reset_vertical_slice_battle_resources()
	SceneManager.clear_state_payload()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_viewport_size_changed() -> void:
	_layout_scene()
	_refresh_all_ui()

func _create_action_button(label: String, callback_name: String) -> Button:
	var button := _create_menu_button(label)
	button.pressed.connect(Callable(self, callback_name))
	_main_menu_grid.add_child(button)
	return button

func _create_menu_button(label: String) -> Button:
	var button := Button.new()
	button.text = label
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_stylebox_override("normal", _make_button_style(_button_texture))
	button.add_theme_stylebox_override("hover", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))
	button.add_theme_stylebox_override("pressed", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))
	button.add_theme_stylebox_override("disabled", _make_button_style(_button_disabled_texture if _button_disabled_texture != null else _button_texture))
	button.add_theme_stylebox_override("focus", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))
	button.custom_minimum_size = Vector2(_scale_x(72.0), _scale_y(20.0))
	button.add_theme_font_size_override("font_size", int(_scale_font(8.0)))
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

func _make_flash_material() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = FLASH_SHADER
	return material

func _flash_sprite(sprite: Sprite2D) -> void:
	var material: ShaderMaterial = sprite.material as ShaderMaterial
	if material == null:
		return

	material.set_shader_parameter("flash_strength", 1.0)
	var flash_tween := create_tween()
	flash_tween.tween_method(Callable(self, "_set_flash_strength").bind(material), 1.0, 0.0, 0.12)

func _set_flash_strength(value: float, material: ShaderMaterial) -> void:
	material.set_shader_parameter("flash_strength", value)

func _shake_camera(intensity: float) -> void:
	var shake_tween := create_tween()
	for _index in range(4):
		shake_tween.tween_property(
			_battle_camera,
			"offset",
			Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity)),
			0.04
		)
	shake_tween.tween_property(_battle_camera, "offset", Vector2.ZERO, 0.05)

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
			if image.get_pixel(x, y).a <= 0.0:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)

	if max_x < 0 or max_y < 0:
		return image

	return image.get_region(Rect2i(min_x, min_y, (max_x - min_x) + 1, (max_y - min_y) + 1))

func _reference_scale_for_height(texture: Texture2D, target_height: float, fallback_scale: float) -> float:
	if texture == null or texture.get_height() <= 0:
		return fallback_scale

	return target_height / float(texture.get_height())

func _make_fallback_texture(width: int, height: int, color: Color) -> Texture2D:
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)

func _encounter_kind() -> String:
	return str(_context.get("encounter_kind", BATTLE_KIND_DEBUG))

func _environment_id() -> String:
	return str(_context.get("environment_id", "mine"))

func _scaled_position(reference_position: Vector2) -> Vector2:
	return Vector2(_scale_x(reference_position.x), _scale_y(reference_position.y))

func _scale_x(reference_x: float) -> float:
	return reference_x * get_viewport_rect().size.x / REFERENCE_VIEWPORT_SIZE.x

func _scale_y(reference_y: float) -> float:
	return reference_y * get_viewport_rect().size.y / REFERENCE_VIEWPORT_SIZE.y

func _scale_font(reference_size: float) -> float:
	return minf(_scale_x(reference_size), _scale_y(reference_size))
