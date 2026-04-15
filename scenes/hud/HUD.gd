extends Control

const TAB_STATS := "stats"
const TAB_EQUIPMENT := "equipment"
const TAB_QUEST := "quest"
const TAB_MAP := "map"
const TAB_ORDER := [TAB_STATS, TAB_EQUIPMENT, TAB_QUEST, TAB_MAP]
const TAB_LABELS := {
	TAB_STATS: "Stats",
	TAB_EQUIPMENT: "Equipment",
	TAB_QUEST: "Quest",
	TAB_MAP: "Map",
}

const FAMILY_ORDER := ["physical", "magik", "intelligence", "social", "will", "holy"]
const FAMILY_LABELS := {
	"physical": "Physical",
	"magik": "Magik",
	"intelligence": "Intelligence",
	"social": "Social",
	"will": "Will",
	"holy": "Holy",
}

const EQUIPMENT_ORDER := ["head", "chest", "legs", "feet", "weapon", "offhand", "ring", "amulet"]
const EQUIPMENT_LABELS := {
	"head": "Head",
	"chest": "Armour",
	"legs": "Legs",
	"feet": "Boots",
	"weapon": "Weapon",
	"offhand": "Offhand",
	"ring": "Ring",
	"amulet": "Amulet",
}

const UI_PANEL_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/panel_brown.png"
const UI_INSET_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/panelInset_brown.png"
const UI_BUTTON_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/buttonLong_brown.png"
const UI_BUTTON_PRESSED_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/buttonLong_brown_pressed.png"
const UI_BUTTON_DISABLED_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/buttonLong_grey.png"
const FIGHTER_PORTRAIT_PATH := "res://assets/art/external/stage_8_5/fighter_walk_sheet.png"
const BATTLEMAGE_PORTRAIT_PATH := "res://assets/art/external/stage_8_5/battlemage_walk_sheet.png"
const PORTRAIT_REGION := Rect2i(256, 128, 64, 64)

const MINE_ENCOUNTER_PROGRESS_FLAG := "mine_encounter_progress"
const MINE_BOSS_RESOLVED_FLAG := "mine_boss_resolved"
const MINE_CLEARED_FLAG := "mine_cleared"
const MAIN_QUEST_PATH_OPEN_FLAG := "main_quest_path_open"

var _is_open := false
var _current_tab := TAB_STATS
var _family_rows: Dictionary = {}
var _equipment_rows: Dictionary = {}
var _panel_texture: Texture2D
var _inset_texture: Texture2D
var _button_texture: Texture2D
var _button_pressed_texture: Texture2D
var _button_disabled_texture: Texture2D

@onready var _backdrop: ColorRect = $Backdrop
@onready var _center: CenterContainer = $Center
@onready var _frame: PanelContainer = $Center/Frame
@onready var _title_label: Label = $Center/Frame/FrameMargin/Content/HeaderRow/TitleLabel
@onready var _close_button: Button = $Center/Frame/FrameMargin/Content/HeaderRow/CloseButton
@onready var _tabs: TabContainer = $Center/Frame/FrameMargin/Content/Tabs
@onready var _player_portrait: TextureRect = $Center/Frame/FrameMargin/Content/Tabs/Stats/StatsBody/SummaryRow/PlayerPortrait
@onready var _level_value: Label = $Center/Frame/FrameMargin/Content/Tabs/Stats/StatsBody/SummaryRow/SummaryGrid/LevelValue
@onready var _xp_value: Label = $Center/Frame/FrameMargin/Content/Tabs/Stats/StatsBody/SummaryRow/SummaryGrid/XPValue
@onready var _points_value: Label = $Center/Frame/FrameMargin/Content/Tabs/Stats/StatsBody/SummaryRow/SummaryGrid/PointsValue
@onready var _alignment_value: Label = $Center/Frame/FrameMargin/Content/Tabs/Stats/StatsBody/SummaryRow/SummaryGrid/AlignmentValue
@onready var _law_chaos_value: Label = $Center/Frame/FrameMargin/Content/Tabs/Stats/StatsBody/SummaryRow/SummaryGrid/LawChaosValue
@onready var _moral_value: Label = $Center/Frame/FrameMargin/Content/Tabs/Stats/StatsBody/SummaryRow/SummaryGrid/MoralValue
@onready var _gold_value: Label = $Center/Frame/FrameMargin/Content/Tabs/Stats/StatsBody/SummaryRow/SummaryGrid/GoldValue
@onready var _points_banner: Label = $Center/Frame/FrameMargin/Content/Tabs/Stats/StatsBody/PointsBanner
@onready var _families_list: VBoxContainer = $Center/Frame/FrameMargin/Content/Tabs/Stats/StatsBody/FamiliesList
@onready var _equipment_list: VBoxContainer = $Center/Frame/FrameMargin/Content/Tabs/Equipment/EquipmentBody/EquipmentList
@onready var _quest_title: Label = $Center/Frame/FrameMargin/Content/Tabs/Quest/QuestBody/QuestTitle
@onready var _quest_objective: Label = $Center/Frame/FrameMargin/Content/Tabs/Quest/QuestBody/QuestObjective
@onready var _quest_status: Label = $Center/Frame/FrameMargin/Content/Tabs/Quest/QuestBody/QuestStatus
@onready var _map_placeholder: Label = $Center/Frame/FrameMargin/Content/Tabs/Map/MapBody/MapPlaceholder

@onready var _tab_stats_button: Button = $Center/Frame/FrameMargin/Content/NavigationRow/TabStatsButton
@onready var _tab_equipment_button: Button = $Center/Frame/FrameMargin/Content/NavigationRow/TabEquipmentButton
@onready var _tab_quest_button: Button = $Center/Frame/FrameMargin/Content/NavigationRow/TabQuestButton
@onready var _tab_map_button: Button = $Center/Frame/FrameMargin/Content/NavigationRow/TabMapButton

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_load_ui_textures()
	_apply_styles()
	_build_family_rows()
	_build_equipment_rows()
	_configure_tabs()
	_connect_signals()
	_refresh_all()
	_layout_for_viewport()
	if not get_viewport().size_changed.is_connected(_on_viewport_size_changed):
		get_viewport().size_changed.connect(_on_viewport_size_changed)

func toggle() -> void:
	set_open(not _is_open)

func set_open(open: bool) -> void:
	if open and not _can_open():
		return
	_is_open = open
	visible = open
	mouse_filter = Control.MOUSE_FILTER_STOP if open else Control.MOUSE_FILTER_IGNORE
	_backdrop.visible = open
	if open:
		_refresh_all()
		_tabs.current_tab = _tab_index_for_id(_current_tab)
		_refresh_tab_buttons()
		_close_button.grab_focus()

func open_to_tab(tab_id: String) -> void:
	_current_tab = _resolve_tab_id(tab_id)
	_tabs.current_tab = _tab_index_for_id(_current_tab)
	set_open(true)
	_refresh_tab_buttons()

func is_open() -> bool:
	return _is_open

func _unhandled_input(event: InputEvent) -> void:
	if not _is_open:
		return
	if event.is_action_pressed("toggle_hud") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		set_open(false)

func _load_ui_textures() -> void:
	_panel_texture = _load_texture(UI_PANEL_TEXTURE_PATH)
	_inset_texture = _load_texture(UI_INSET_TEXTURE_PATH)
	_button_texture = _load_texture(UI_BUTTON_TEXTURE_PATH)
	_button_pressed_texture = _load_texture(UI_BUTTON_PRESSED_TEXTURE_PATH)
	_button_disabled_texture = _load_texture(UI_BUTTON_DISABLED_TEXTURE_PATH)

func _apply_styles() -> void:
	_frame.add_theme_stylebox_override("panel", _make_panel_style(_panel_texture))
	_title_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.84, 1.0))
	for button in [_close_button, _tab_stats_button, _tab_equipment_button, _tab_quest_button, _tab_map_button]:
		_apply_button_style(button)

func _build_family_rows() -> void:
	for family_key in FAMILY_ORDER:
		var row_panel := PanelContainer.new()
		row_panel.add_theme_stylebox_override("panel", _make_inset_style(_inset_texture))
		_families_list.add_child(row_panel)

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_bottom", 8)
		row_panel.add_child(margin)

		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 8)
		margin.add_child(row)

		var label := Label.new()
		label.text = str(FAMILY_LABELS.get(family_key, family_key.capitalize()))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)

		var value_label := Label.new()
		value_label.custom_minimum_size = Vector2(64.0, 0.0)
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(value_label)

		var allocate_button := Button.new()
		allocate_button.text = "+1"
		allocate_button.custom_minimum_size = Vector2(72.0, 0.0)
		allocate_button.focus_mode = Control.FOCUS_ALL
		allocate_button.pressed.connect(_on_allocate_pressed.bind(family_key))
		_apply_button_style(allocate_button)
		row.add_child(allocate_button)

		_family_rows[family_key] = {
			"value": value_label,
			"button": allocate_button,
		}

func _build_equipment_rows() -> void:
	for slot in EQUIPMENT_ORDER:
		var row_panel := PanelContainer.new()
		row_panel.add_theme_stylebox_override("panel", _make_inset_style(_inset_texture))
		_equipment_list.add_child(row_panel)

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_bottom", 8)
		row_panel.add_child(margin)

		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 8)
		margin.add_child(row)

		var label := Label.new()
		label.text = str(EQUIPMENT_LABELS.get(slot, slot.capitalize()))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)

		var value_label := Label.new()
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(value_label)

		_equipment_rows[slot] = value_label

func _configure_tabs() -> void:
	for index in range(TAB_ORDER.size()):
		_tabs.set_tab_title(index, str(TAB_LABELS.get(TAB_ORDER[index], TAB_ORDER[index].capitalize())))
	_tabs.tab_changed.connect(_on_tab_changed)
	_close_button.pressed.connect(_on_close_pressed)

func _connect_signals() -> void:
	SignalBus.stat_changed.connect(_on_refresh_requested)
	SignalBus.flag_set.connect(_on_refresh_requested_flag)
	SignalBus.level_up.connect(_on_level_up)
	SignalBus.state_changed.connect(_on_state_changed)
	
	_tab_stats_button.pressed.connect(_on_tab_button_pressed.bind(TAB_STATS))
	_tab_equipment_button.pressed.connect(_on_tab_button_pressed.bind(TAB_EQUIPMENT))
	_tab_quest_button.pressed.connect(_on_tab_button_pressed.bind(TAB_QUEST))
	_tab_map_button.pressed.connect(_on_tab_button_pressed.bind(TAB_MAP))

func _on_viewport_size_changed() -> void:
	_layout_for_viewport()

func _layout_for_viewport() -> void:
	var viewport_size := get_viewport_rect().size
	var frame_width := clampf(viewport_size.x - 32.0, 320.0, 880.0)
	var frame_height := clampf(viewport_size.y - 32.0, 220.0, 640.0)
	_frame.custom_minimum_size = Vector2(frame_width, frame_height)

func _on_close_pressed() -> void:
	set_open(false)

func _on_tab_changed(tab_index: int) -> void:
	if tab_index < 0 or tab_index >= TAB_ORDER.size():
		return
	_current_tab = str(TAB_ORDER[tab_index])
	_refresh_tab_buttons()

func _on_tab_button_pressed(tab_id: String) -> void:
	_current_tab = tab_id
	_tabs.current_tab = _tab_index_for_id(tab_id)
	_refresh_tab_buttons()

func _refresh_tab_buttons() -> void:
	var buttons = {
		TAB_STATS: _tab_stats_button,
		TAB_EQUIPMENT: _tab_equipment_button,
		TAB_QUEST: _tab_quest_button,
		TAB_MAP: _tab_map_button
	}
	
	for id in buttons:
		var btn: Button = buttons[id]
		if id == _current_tab:
			btn.add_theme_stylebox_override("normal", _make_button_style(_button_pressed_texture))
		else:
			btn.add_theme_stylebox_override("normal", _make_button_style(_button_texture))

func _on_allocate_pressed(family_key: String) -> void:
	if PlayerData.unspent_stat_points <= 0:
		return
	if not StatRegistry.apply_family_allocation(family_key):
		return
	PlayerData.unspent_stat_points -= 1
	SaveManager.save_game()
	_refresh_all()

func _on_refresh_requested(_stat_path: String, _new_value: float) -> void:
	if _is_open:
		_refresh_all()

func _on_refresh_requested_flag(_flag_name: String, _value: Variant) -> void:
	if _is_open:
		_refresh_all()

func _on_level_up(_level: int) -> void:
	_refresh_all()

func _on_state_changed(_from_state: String, to_state: String) -> void:
	if to_state != "map":
		set_open(false)

func _refresh_all() -> void:
	_refresh_stats_tab()
	_refresh_equipment_tab()
	_refresh_quest_tab()
	_map_placeholder.text = "Map - coming soon"

func _refresh_stats_tab() -> void:
	var axes := AlignmentSystem.get_axis_labels()
	_level_value.text = str(PlayerData.level)
	_xp_value.text = "%d / %d" % [PlayerData.xp, PlayerData.xp_to_next_level]
	_points_value.text = str(PlayerData.unspent_stat_points)
	_alignment_value.text = AlignmentSystem.get_alignment_label()
	_law_chaos_value.text = str(axes.get("law_chaos", "Neutral"))
	_moral_value.text = str(axes.get("moral", "Neutral"))
	_gold_value.text = str(PlayerData.gold)
	_points_banner.visible = PlayerData.unspent_stat_points > 0
	_player_portrait.texture = _load_player_portrait()

	for family_key in FAMILY_ORDER:
		var row: Dictionary = _family_rows.get(family_key, {})
		var value_label := row.get("value") as Label
		var button := row.get("button") as Button
		if value_label != null:
			value_label.text = "%.1f" % StatRegistry.get_family_average(family_key)
		if button != null:
			button.disabled = PlayerData.unspent_stat_points <= 0
			button.visible = PlayerData.unspent_stat_points > 0

func _refresh_equipment_tab() -> void:
	for slot in EQUIPMENT_ORDER:
		var value_label := _equipment_rows.get(slot) as Label
		if value_label == null:
			continue
		var item_name := str(PlayerData.equipment.get(slot, ""))
		value_label.text = item_name if item_name != "" else "Empty"

func _refresh_quest_tab() -> void:
	var encounter_progress := clampi(int(PlayerData.get_flag(MINE_ENCOUNTER_PROGRESS_FLAG, 0)), 0, 3)
	var mine_boss_resolved := bool(PlayerData.get_flag(MINE_BOSS_RESOLVED_FLAG, false))
	var mine_cleared := bool(PlayerData.get_flag(MINE_CLEARED_FLAG, false))
	var main_quest_open := bool(PlayerData.get_flag(MAIN_QUEST_PATH_OPEN_FLAG, false))

	_quest_title.text = "Beyond the Mine" if mine_cleared and main_quest_open else "Into the Mine"
	if encounter_progress == 0:
		_quest_objective.text = "Enter the mine and clear the first chamber."
	elif encounter_progress <= 2 and not mine_boss_resolved:
		_quest_objective.text = "Clear the remaining Kobold chambers."
	elif encounter_progress >= 3 and not mine_boss_resolved:
		_quest_objective.text = "Confront the Shaman in the boss chamber."
	elif mine_boss_resolved and not mine_cleared:
		_quest_objective.text = "Leave the mine."
	else:
		_quest_objective.text = "Travel onward from the crossroads."

	_quest_status.text = "Current location: %s" % PlayerData.current_location.replace("_", " ").capitalize()

func _load_player_portrait() -> Texture2D:
	if PlayerData.resolve_vertical_slice_class_id() == PlayerData.CLASS_BATTLEMAGE:
		return _load_cropped_texture(BATTLEMAGE_PORTRAIT_PATH, PORTRAIT_REGION, _make_fallback_texture(64, 64, Color(0.20, 0.28, 0.48)))
	return _load_cropped_texture(FIGHTER_PORTRAIT_PATH, PORTRAIT_REGION, _make_fallback_texture(64, 64, Color(0.54, 0.44, 0.34)))

func _can_open() -> bool:
	return SceneManager.current_state_name == "map"

func _resolve_tab_id(tab_id: String) -> String:
	return tab_id if TAB_ORDER.has(tab_id) else TAB_STATS

func _tab_index_for_id(tab_id: String) -> int:
	return TAB_ORDER.find(_resolve_tab_id(tab_id))

func _load_texture(resource_path: String) -> Texture2D:
	if ResourceLoader.exists(resource_path, "Texture2D") or ResourceLoader.exists(resource_path):
		var texture := load(resource_path)
		if texture is Texture2D:
			return texture as Texture2D

	var image := Image.load_from_file(ProjectSettings.globalize_path(resource_path))
	if image == null or image.is_empty():
		return null
	return ImageTexture.create_from_image(image)

func _load_cropped_texture(resource_path: String, region: Rect2i, fallback: Texture2D) -> Texture2D:
	var image := Image.load_from_file(resource_path)
	if image == null or image.is_empty():
		return fallback

	var cropped := image.get_region(region)
	if cropped == null or cropped.is_empty():
		return fallback

	return ImageTexture.create_from_image(cropped)

func _make_fallback_texture(width: int, height: int, color: Color) -> Texture2D:
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)

func _apply_button_style(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _make_button_style(_button_texture))
	button.add_theme_stylebox_override("hover", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))
	button.add_theme_stylebox_override("pressed", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))
	button.add_theme_stylebox_override("disabled", _make_button_style(_button_disabled_texture if _button_disabled_texture != null else _button_texture))
	button.add_theme_stylebox_override("focus", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))

func _make_panel_style(texture: Texture2D) -> StyleBox:
	if texture == null:
		var fallback := StyleBoxFlat.new()
		fallback.bg_color = Color(0.16, 0.12, 0.08, 0.96)
		fallback.corner_radius_top_left = 10
		fallback.corner_radius_top_right = 10
		fallback.corner_radius_bottom_right = 10
		fallback.corner_radius_bottom_left = 10
		fallback.content_margin_left = 10
		fallback.content_margin_right = 10
		fallback.content_margin_top = 10
		fallback.content_margin_bottom = 10
		return fallback

	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = 16
	style.texture_margin_top = 8
	style.texture_margin_right = 16
	style.texture_margin_bottom = 8
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	return style

func _make_inset_style(texture: Texture2D) -> StyleBox:
	if texture == null:
		var fallback := StyleBoxFlat.new()
		fallback.bg_color = Color(0.10, 0.08, 0.05, 0.92)
		fallback.corner_radius_top_left = 8
		fallback.corner_radius_top_right = 8
		fallback.corner_radius_bottom_right = 8
		fallback.corner_radius_bottom_left = 8
		fallback.content_margin_left = 8
		fallback.content_margin_right = 8
		fallback.content_margin_top = 8
		fallback.content_margin_bottom = 8
		return fallback

	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = 10
	style.texture_margin_top = 10
	style.texture_margin_right = 10
	style.texture_margin_bottom = 10
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	return style

func _make_button_style(texture: Texture2D) -> StyleBox:
	if texture == null:
		var fallback := StyleBoxFlat.new()
		fallback.bg_color = Color(0.30, 0.20, 0.10, 1.0)
		fallback.corner_radius_top_left = 8
		fallback.corner_radius_top_right = 8
		fallback.corner_radius_bottom_right = 8
		fallback.corner_radius_bottom_left = 8
		fallback.content_margin_left = 10
		fallback.content_margin_right = 10
		fallback.content_margin_top = 6
		fallback.content_margin_bottom = 6
		return fallback

	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = 14
	style.texture_margin_top = 6
	style.texture_margin_right = 14
	style.texture_margin_bottom = 6
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	return style
