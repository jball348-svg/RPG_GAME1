extends Control

const COMPACT_VIEWPORT_WIDTH := 640.0
const COMPACT_VIEWPORT_HEIGHT := 360.0

const UI_PANEL_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/panel_brown.png"
const UI_BUTTON_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/buttonLong_brown.png"
const UI_BUTTON_PRESSED_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/buttonLong_brown_pressed.png"
const UI_BUTTON_DISABLED_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/buttonLong_grey.png"

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

const FAMILY_ROWS: Array[Dictionary] = [
	{"key": "physical", "label": "Physical"},
	{"key": "magik", "label": "Magik"},
	{"key": "intelligence", "label": "Intelligence"},
	{"key": "social", "label": "Social"},
	{"key": "will", "label": "Will"},
	{"key": "holy", "label": "Holy"},
]

const EQUIPMENT_ROWS: Array[Dictionary] = [
	{"key": "head", "label": "Head"},
	{"key": "chest", "label": "Armour"},
	{"key": "legs", "label": "Legs"},
	{"key": "feet", "label": "Boots"},
	{"key": "weapon", "label": "Weapon"},
	{"key": "offhand", "label": "Offhand"},
	{"key": "ring", "label": "Ring"},
	{"key": "amulet", "label": "Amulet"},
]

const MINE_ENCOUNTER_PROGRESS_FLAG := "mine_encounter_progress"
const MINE_BOSS_RESOLVED_FLAG := "mine_boss_resolved"
const MINE_CLEARED_FLAG := "mine_cleared"
const MAIN_QUEST_PATH_OPEN_FLAG := "main_quest_path_open"

var _panel_texture: Texture2D
var _button_texture: Texture2D
var _button_pressed_texture: Texture2D
var _button_disabled_texture: Texture2D

var _is_open := false
var _use_compact_layout := false
var _current_tab := TAB_STATS

var _scroll_container: ScrollContainer
var _level_value_label: Label
var _xp_value_label: Label
var _points_value_label: Label
var _alignment_value_label: Label
var _gold_value_label: Label
var _family_value_labels: Dictionary = {}
var _family_buttons: Dictionary = {}
var _equipment_value_labels: Dictionary = {}
var _quest_title_label: Label
var _quest_objective_label: Label
var _map_placeholder_label: Label
var _tab_buttons: Dictionary = {}
var _tab_pages: Dictionary = {}

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_load_textures()
	_connect_signals()
	_rebuild_layout(true)
	_refresh()

	if not get_viewport().size_changed.is_connected(_on_viewport_size_changed):
		get_viewport().size_changed.connect(_on_viewport_size_changed)

func _unhandled_input(event: InputEvent) -> void:
	if not _is_open:
		return

	if event.is_action_pressed("toggle_hud") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		set_open(false)

func is_open() -> bool:
	return _is_open

func toggle() -> void:
	set_open(not _is_open)

func open_to_tab(tab_id: String) -> void:
	_set_current_tab(tab_id)
	set_open(true)

func set_open(open: bool) -> void:
	if open and SceneManager.current_state_name != "map":
		return

	_is_open = open
	visible = _is_open
	mouse_filter = Control.MOUSE_FILTER_STOP if _is_open else Control.MOUSE_FILTER_IGNORE
	_refresh_debug_panel_visibility()

	if _is_open:
		_refresh()

func _load_textures() -> void:
	_panel_texture = _load_texture(UI_PANEL_TEXTURE_PATH)
	_button_texture = _load_texture(UI_BUTTON_TEXTURE_PATH)
	_button_pressed_texture = _load_texture(UI_BUTTON_PRESSED_TEXTURE_PATH)
	_button_disabled_texture = _load_texture(UI_BUTTON_DISABLED_TEXTURE_PATH)

func _connect_signals() -> void:
	SignalBus.stat_changed.connect(_on_stat_changed)
	SignalBus.flag_set.connect(_on_flag_changed)
	SignalBus.level_up.connect(_on_level_up)
	SignalBus.state_changed.connect(_on_state_changed)

func _on_stat_changed(_stat_path: String, _new_value: float) -> void:
	_refresh()

func _on_flag_changed(_flag_name: String, _value: Variant) -> void:
	_refresh()

func _on_level_up(_level: int) -> void:
	_refresh()

func _on_state_changed(_from_state: String, to_state: String) -> void:
	if to_state != "map":
		set_open(false)
		return

	_refresh_debug_panel_visibility()
	_refresh()

func _on_viewport_size_changed() -> void:
	_rebuild_layout()
	_refresh_debug_panel_visibility()

func _rebuild_layout(force: bool = false) -> void:
	var use_compact := _is_compact_layout()
	if not force and use_compact == _use_compact_layout:
		return

	_use_compact_layout = use_compact
	_family_value_labels.clear()
	_family_buttons.clear()
	_equipment_value_labels.clear()
	_tab_buttons.clear()
	_tab_pages.clear()
	_level_value_label = null
	_xp_value_label = null
	_points_value_label = null
	_alignment_value_label = null
	_gold_value_label = null
	_quest_title_label = null
	_quest_objective_label = null
	_map_placeholder_label = null
	_scroll_container = null

	while get_child_count() > 0:
		var child := get_child(0)
		remove_child(child)
		child.queue_free()

	_build_ui()
	if _is_open:
		_refresh()

func _build_ui() -> void:
	var horizontal_margin := 10 if _use_compact_layout else 52
	var vertical_margin := 10 if _use_compact_layout else 32
	var spacing := 6 if _use_compact_layout else 10

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.04, 0.05, 0.07, 0.74)
	add_child(backdrop)

	var frame := MarginContainer.new()
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.add_theme_constant_override("margin_left", horizontal_margin)
	frame.add_theme_constant_override("margin_top", vertical_margin)
	frame.add_theme_constant_override("margin_right", horizontal_margin)
	frame.add_theme_constant_override("margin_bottom", vertical_margin)
	add_child(frame)

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_panel_style(_panel_texture))
	frame.add_child(panel)

	var panel_margin := MarginContainer.new()
	panel_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_margin.add_theme_constant_override("margin_left", 12 if _use_compact_layout else 18)
	panel_margin.add_theme_constant_override("margin_top", 10 if _use_compact_layout else 14)
	panel_margin.add_theme_constant_override("margin_right", 12 if _use_compact_layout else 18)
	panel_margin.add_theme_constant_override("margin_bottom", 10 if _use_compact_layout else 14)
	panel.add_child(panel_margin)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", spacing)
	panel_margin.add_child(root)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", spacing)
	root.add_child(header)

	var title := Label.new()
	title.text = "Vertical Slice Ledger"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 10 if _use_compact_layout else 13)
	header.add_child(title)

	var close_hint := Label.new()
	close_hint.text = "H / Esc to close"
	close_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	close_hint.add_theme_font_size_override("font_size", 7 if _use_compact_layout else 8)
	header.add_child(close_hint)

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6 if _use_compact_layout else 8)
	root.add_child(tabs)

	for tab_id_value in TAB_ORDER:
		var tab_id := str(tab_id_value)
		var button := _create_menu_button(str(TAB_LABELS.get(tab_id, tab_id.capitalize())))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_tab_button_pressed.bind(tab_id))
		tabs.add_child(button)
		_tab_buttons[tab_id] = button

	_scroll_container = ScrollContainer.new()
	_scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	root.add_child(_scroll_container)

	var page_host := VBoxContainer.new()
	page_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll_container.add_child(page_host)

	var stats_page := _build_stats_page()
	page_host.add_child(stats_page)
	_tab_pages[TAB_STATS] = stats_page

	var equipment_page := _build_equipment_page()
	page_host.add_child(equipment_page)
	_tab_pages[TAB_EQUIPMENT] = equipment_page

	var quest_page := _build_quest_page()
	page_host.add_child(quest_page)
	_tab_pages[TAB_QUEST] = quest_page

	var map_page := _build_map_page()
	page_host.add_child(map_page)
	_tab_pages[TAB_MAP] = map_page

	_set_current_tab(_current_tab, false)

func _build_stats_page() -> Control:
	var page := VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 8 if _use_compact_layout else 12)

	var summary_panel := _create_content_panel()
	page.add_child(summary_panel)

	var summary_content := _get_panel_content(summary_panel)
	_level_value_label = _add_value_row(summary_content, "Level")
	_xp_value_label = _add_value_row(summary_content, "XP")
	_points_value_label = _add_value_row(summary_content, "Unspent Points")
	_alignment_value_label = _add_value_row(summary_content, "Alignment")
	_gold_value_label = _add_value_row(summary_content, "Gold")

	var family_panel := _create_content_panel()
	page.add_child(family_panel)

	var family_content := _get_panel_content(family_panel)
	var family_title := Label.new()
	family_title.text = "Stat Families"
	family_title.add_theme_font_size_override("font_size", 8 if _use_compact_layout else 9)
	family_content.add_child(family_title)

	for row in FAMILY_ROWS:
		var family_key := str(row.get("key", ""))
		var family_label := str(row.get("label", family_key.capitalize()))

		var family_row := HBoxContainer.new()
		family_row.add_theme_constant_override("separation", 6)
		family_content.add_child(family_row)

		var label := Label.new()
		label.text = family_label
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 8 if _use_compact_layout else 9)
		family_row.add_child(label)

		var value_label := Label.new()
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value_label.custom_minimum_size = Vector2(72.0 if _use_compact_layout else 88.0, 0.0)
		value_label.add_theme_font_size_override("font_size", 8 if _use_compact_layout else 9)
		family_row.add_child(value_label)
		_family_value_labels[family_key] = value_label

		var button := _create_small_button("+1")
		button.pressed.connect(_on_family_allocate_pressed.bind(family_key))
		family_row.add_child(button)
		_family_buttons[family_key] = button

	return page

func _build_equipment_page() -> Control:
	var page := VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 8 if _use_compact_layout else 10)

	var panel := _create_content_panel()
	page.add_child(panel)

	var content := _get_panel_content(panel)
	for row in EQUIPMENT_ROWS:
		var slot_key := str(row.get("key", ""))
		var value_label := _add_value_row(content, str(row.get("label", slot_key.capitalize())))
		_equipment_value_labels[slot_key] = value_label

	return page

func _build_quest_page() -> Control:
	var page := VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var panel := _create_content_panel()
	page.add_child(panel)

	var content := _get_panel_content(panel)
	_quest_title_label = Label.new()
	_quest_title_label.add_theme_font_size_override("font_size", 9 if _use_compact_layout else 10)
	content.add_child(_quest_title_label)

	_quest_objective_label = Label.new()
	_quest_objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_quest_objective_label.add_theme_font_size_override("font_size", 8 if _use_compact_layout else 9)
	content.add_child(_quest_objective_label)

	return page

func _build_map_page() -> Control:
	var page := VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var panel := _create_content_panel()
	page.add_child(panel)

	var content := _get_panel_content(panel)
	_map_placeholder_label = Label.new()
	_map_placeholder_label.text = "Map - coming soon"
	_map_placeholder_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_map_placeholder_label.add_theme_font_size_override("font_size", 8 if _use_compact_layout else 9)
	content.add_child(_map_placeholder_label)

	return page

func _create_content_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_panel_style(_panel_texture))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10 if _use_compact_layout else 14)
	margin.add_theme_constant_override("margin_top", 8 if _use_compact_layout else 10)
	margin.add_theme_constant_override("margin_right", 10 if _use_compact_layout else 14)
	margin.add_theme_constant_override("margin_bottom", 8 if _use_compact_layout else 10)
	panel.add_child(margin)

	var content := VBoxContainer.new()
	content.name = "Content"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 6 if _use_compact_layout else 8)
	margin.add_child(content)

	return panel

func _get_panel_content(panel: PanelContainer) -> VBoxContainer:
	return panel.get_node("MarginContainer/Content") as VBoxContainer

func _add_value_row(parent: VBoxContainer, label_text: String) -> Label:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	parent.add_child(row)

	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 8 if _use_compact_layout else 9)
	row.add_child(label)

	var value_label := Label.new()
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.custom_minimum_size = Vector2(100.0 if _use_compact_layout else 116.0, 0.0)
	value_label.add_theme_font_size_override("font_size", 8 if _use_compact_layout else 9)
	row.add_child(value_label)

	return value_label

func _create_menu_button(label: String) -> Button:
	var button := Button.new()
	button.text = label
	button.focus_mode = Control.FOCUS_ALL
	button.custom_minimum_size = Vector2(0.0, 22.0 if _use_compact_layout else 24.0)
	button.add_theme_font_size_override("font_size", 7 if _use_compact_layout else 8)
	button.add_theme_stylebox_override("normal", _make_button_style(_button_texture))
	button.add_theme_stylebox_override("hover", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))
	button.add_theme_stylebox_override("pressed", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))
	button.add_theme_stylebox_override("disabled", _make_button_style(_button_disabled_texture if _button_disabled_texture != null else _button_texture))
	button.add_theme_stylebox_override("focus", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))
	return button

func _create_small_button(label: String) -> Button:
	var button := _create_menu_button(label)
	button.custom_minimum_size = Vector2(48.0 if _use_compact_layout else 52.0, 22.0 if _use_compact_layout else 24.0)
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

func _load_texture(resource_path: String) -> Texture2D:
	var image := Image.load_from_file(resource_path)
	if image == null or image.is_empty():
		return null
	return ImageTexture.create_from_image(image)

func _on_tab_button_pressed(tab_id: String) -> void:
	_set_current_tab(tab_id)
	_refresh()

func _set_current_tab(requested_tab: String, ensure_refresh: bool = true) -> void:
	_current_tab = _resolve_tab_id(requested_tab)
	for tab_id_value in _tab_pages.keys():
		var tab_id := str(tab_id_value)
		var page := _tab_pages[tab_id] as Control
		if page != null:
			page.visible = tab_id == _current_tab
	for tab_id_value in _tab_buttons.keys():
		var tab_id := str(tab_id_value)
		var button := _tab_buttons[tab_id] as Button
		if button != null:
			button.disabled = tab_id == _current_tab
	if ensure_refresh:
		_refresh()

func _resolve_tab_id(requested_tab: String) -> String:
	if TAB_ORDER.has(requested_tab):
		return requested_tab
	return TAB_STATS

func _is_compact_layout() -> bool:
	var viewport_size := get_viewport_rect().size
	return viewport_size.x <= COMPACT_VIEWPORT_WIDTH or viewport_size.y <= COMPACT_VIEWPORT_HEIGHT

func _refresh() -> void:
	if _level_value_label == null:
		return

	_level_value_label.text = str(PlayerData.level)
	_xp_value_label.text = "%d / %d" % [PlayerData.xp, PlayerData.xp_to_next_level]
	_points_value_label.text = "%d available" % PlayerData.unspent_stat_points
	_points_value_label.modulate = Color(0.96, 0.84, 0.48, 1.0) if PlayerData.unspent_stat_points > 0 else Color(1.0, 1.0, 1.0, 1.0)
	_alignment_value_label.text = AlignmentSystem.get_alignment_label()
	_gold_value_label.text = str(PlayerData.gold)

	for row in FAMILY_ROWS:
		var family_key := str(row.get("key", ""))
		var value_label := _family_value_labels.get(family_key) as Label
		if value_label != null:
			value_label.text = "%.1f" % StatRegistry.get_family_average(family_key)

		var button := _family_buttons.get(family_key) as Button
		if button != null:
			button.disabled = PlayerData.unspent_stat_points <= 0

	for row in EQUIPMENT_ROWS:
		var slot_key := str(row.get("key", ""))
		var slot_value := str(PlayerData.equipment.get(slot_key, ""))
		var value_label := _equipment_value_labels.get(slot_key) as Label
		if value_label != null:
			value_label.text = "Empty" if slot_value == "" else slot_value

	var quest_state := _resolve_active_quest()
	if _quest_title_label != null:
		_quest_title_label.text = str(quest_state.get("title", "Into the Mine"))
	if _quest_objective_label != null:
		_quest_objective_label.text = str(quest_state.get("objective", "Enter the mine and clear the first chamber."))

	if _map_placeholder_label != null:
		_map_placeholder_label.text = "Map - coming soon"

func _resolve_active_quest() -> Dictionary:
	var mine_encounter_progress := int(PlayerData.get_flag(MINE_ENCOUNTER_PROGRESS_FLAG, 0))
	var mine_boss_resolved := bool(PlayerData.get_flag(MINE_BOSS_RESOLVED_FLAG, false))
	var mine_cleared := bool(PlayerData.get_flag(MINE_CLEARED_FLAG, false))
	var main_quest_path_open := bool(PlayerData.get_flag(MAIN_QUEST_PATH_OPEN_FLAG, false))

	if mine_cleared and main_quest_path_open:
		return {
			"title": "Beyond the Mine",
			"objective": "Travel onward from the crossroads.",
		}
	if mine_boss_resolved and not mine_cleared:
		return {
			"title": "Into the Mine",
			"objective": "Leave the mine.",
		}
	if mine_encounter_progress >= 3 and not mine_boss_resolved:
		return {
			"title": "Into the Mine",
			"objective": "Confront the Shaman in the boss chamber.",
		}
	if mine_encounter_progress == 1 or mine_encounter_progress == 2:
		return {
			"title": "Into the Mine",
			"objective": "Clear the remaining Kobold chambers.",
		}
	return {
		"title": "Into the Mine",
		"objective": "Enter the mine and clear the first chamber.",
	}

func _on_family_allocate_pressed(family_key: String) -> void:
	if PlayerData.unspent_stat_points <= 0:
		return
	if not StatRegistry.apply_family_allocation(family_key):
		return

	PlayerData.unspent_stat_points -= 1
	SaveManager.save_game()
	_refresh()

func _refresh_debug_panel_visibility() -> void:
	var overlay_host := SceneManager.get_overlay_host()
	if overlay_host == null:
		return

	var debug_panel = overlay_host.get_node_or_null("DebugPanel")
	if debug_panel != null and debug_panel.has_method("refresh_visibility"):
		debug_panel.refresh_visibility()
