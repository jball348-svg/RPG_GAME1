extends Control

const SUMMARY_STATS: Array[Dictionary] = [
	{"label": "Movement", "path": "physical.movement"},
	{"label": "Strength", "path": "physical.strength"},
	{"label": "Spellcasting", "path": "magik.spellcasting"},
	{"label": "Attunement", "path": "magik.attunement"},
	{"label": "Mana", "path": "magik.mana"},
	{"label": "Luck", "path": "social.luck"},
]

const EQUIPMENT_ORDER: Array[String] = [
	"weapon",
	"offhand",
	"head",
	"chest",
	"legs",
	"feet",
	"ring",
	"amulet",
]

const COMPACT_VIEWPORT_WIDTH := 640.0
const COMPACT_VIEWPORT_HEIGHT := 360.0

var _status_label: Label
var _identity_label: Label
var _inventory_label: Label
var _stats_label: Label
var _is_open: bool = false
var _use_compact_layout: bool = false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_connect_signals()
	_rebuild_layout(true)
	_refresh()

	if not get_viewport().size_changed.is_connected(_on_viewport_size_changed):
		get_viewport().size_changed.connect(_on_viewport_size_changed)

func is_open() -> bool:
	return _is_open

func toggle() -> void:
	set_open(not _is_open)

func set_open(open: bool) -> void:
	if open and SceneManager.current_state_name != "map":
		return

	_is_open = open
	visible = _is_open
	mouse_filter = Control.MOUSE_FILTER_STOP if _is_open else Control.MOUSE_FILTER_IGNORE

	if _is_open:
		_refresh()

func _build_ui() -> void:
	if get_child_count() > 0:
		return

	_use_compact_layout = _is_compact_layout()
	var horizontal_margin := 12 if _use_compact_layout else 56
	var vertical_margin := 10 if _use_compact_layout else 40
	var section_gap := 8 if _use_compact_layout else 16

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.03, 0.05, 0.07, 0.76)
	add_child(backdrop)

	var frame := MarginContainer.new()
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.add_theme_constant_override("margin_left", horizontal_margin)
	frame.add_theme_constant_override("margin_top", vertical_margin)
	frame.add_theme_constant_override("margin_right", horizontal_margin)
	frame.add_theme_constant_override("margin_bottom", vertical_margin)
	add_child(frame)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", section_gap)
	frame.add_child(root)

	var title := Label.new()
	title.text = "HUD Overlay"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Map stays visible underneath. Movement pauses while HUD is open, but the clock keeps ticking."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD
	root.add_child(subtitle)

	var grid := GridContainer.new()
	grid.columns = 1 if _use_compact_layout else 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", section_gap)
	grid.add_theme_constant_override("v_separation", section_gap)
	root.add_child(grid)

	_status_label = _add_section(grid, "Clock + Status")
	_identity_label = _add_section(grid, "Path + Class")
	_inventory_label = _add_section(grid, "Equipment + Inventory")
	_stats_label = _add_section(grid, "Compact Stat Summary")

func _add_section(parent: GridContainer, title_text: String) -> Label:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(220.0, 96.0) if _use_compact_layout else Vector2(360.0, 180.0)
	parent.add_child(panel)

	var panel_margin := 10 if _use_compact_layout else 16
	var panel_spacing := 6 if _use_compact_layout else 10

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", panel_margin)
	margin.add_theme_constant_override("margin_top", panel_margin)
	margin.add_theme_constant_override("margin_right", panel_margin)
	margin.add_theme_constant_override("margin_bottom", panel_margin)
	panel.add_child(margin)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", panel_spacing)
	margin.add_child(content)

	var title := Label.new()
	title.text = title_text
	content.add_child(title)

	var body := Label.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.autowrap_mode = TextServer.AUTOWRAP_WORD
	body.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	content.add_child(body)

	return body

func _is_compact_layout() -> bool:
	var viewport_size := get_viewport_rect().size
	return viewport_size.x <= COMPACT_VIEWPORT_WIDTH or viewport_size.y <= COMPACT_VIEWPORT_HEIGHT

func _rebuild_layout(force: bool = false) -> void:
	var use_compact := _is_compact_layout()
	if not force and use_compact == _use_compact_layout:
		return

	_use_compact_layout = use_compact
	_status_label = null
	_identity_label = null
	_inventory_label = null
	_stats_label = null

	for child in get_children():
		child.queue_free()

	_build_ui()
	if _is_open:
		_refresh()

func _on_viewport_size_changed() -> void:
	_rebuild_layout()

func _connect_signals() -> void:
	SignalBus.stat_changed.connect(_on_stat_changed)
	SignalBus.clock_ticked.connect(_on_clock_ticked)
	SignalBus.flag_set.connect(_on_flag_changed)
	SignalBus.state_changed.connect(_on_state_changed)

func _on_stat_changed(_stat_path: String, _new_value: float) -> void:
	_refresh()

func _on_clock_ticked(_time: Dictionary) -> void:
	_refresh()

func _on_flag_changed(_flag_name: String, _value: Variant) -> void:
	_refresh()

func _on_state_changed(_from_state: String, to_state: String) -> void:
	if to_state != "map":
		set_open(false)
		return

	_refresh()

func _refresh() -> void:
	if _status_label == null:
		return

	_status_label.text = _build_status_text()
	_identity_label.text = _build_identity_text()
	_inventory_label.text = _build_inventory_text()
	_stats_label.text = _build_stats_text()

func _build_status_text() -> String:
	var time_data: Dictionary = GameClock.get_time()
	return "\n".join([
		"State: %s" % _display_value(SceneManager.current_state_name, "none"),
		"Clock: %s" % time_data.get("display", "unknown"),
		"Location: %s" % _display_value(PlayerData.current_location, "unset"),
		"Region: %s" % _display_value(PlayerData.current_region, "unset"),
	])

func _build_identity_text() -> String:
	return "\n".join([
		"Path: %s" % _display_value(PlayerData.chosen_path, "unset"),
		"Class: %s" % _display_value(PlayerData.get_display_class(), "unset"),
		"Age: %d years / %d days" % [PlayerData.age_years, PlayerData.age_days],
	])

func _build_inventory_text() -> String:
	var lines: PackedStringArray = []
	lines.append("Equipment")

	for slot in EQUIPMENT_ORDER:
		lines.append("%s: %s" % [
			slot.capitalize(),
			_display_value(PlayerData.equipment.get(slot, ""), "empty"),
		])

	lines.append("")
	lines.append("Inventory")
	lines.append("Items: %d" % PlayerData.inventory.size())
	lines.append("Gold: %d" % PlayerData.gold)
	return "\n".join(lines)

func _build_stats_text() -> String:
	var lines: PackedStringArray = []
	for entry in SUMMARY_STATS:
		lines.append("%s: %.2f" % [entry["label"], StatRegistry.get_stat(entry["path"])])
	return "\n".join(lines)

func _display_value(value: String, fallback: String) -> String:
	return fallback if value == "" else value
