extends PanelContainer

const PANEL_MARGIN := 8.0
const PANEL_WIDTH_RATIO := 0.3
const PANEL_HEIGHT_RATIO := 0.55
const PANEL_MIN_SIZE := Vector2(180.0, 140.0)
const PANEL_MAX_SIZE := Vector2(260.0, 240.0)

const CATEGORY_ORDER: Array[String] = [
	"physical",
	"magik",
	"intelligence",
	"social",
	"will",
	"holy",
]

const SKILL_ORDER: Dictionary = {
	"physical": ["strength", "endurance", "movement"],
	"magik": ["spellcasting", "attunement", "mana"],
	"intelligence": ["understanding", "tactics", "persuasion"],
	"social": ["charm", "reputation", "empathy", "luck"],
	"will": ["resolve", "focus", "resistance"],
	"holy": ["faith", "intuition", "peace", "justice"],
}

var _content_label: RichTextLabel

func _ready() -> void:
	if not get_viewport().size_changed.is_connected(_on_viewport_size_changed):
		get_viewport().size_changed.connect(_on_viewport_size_changed)

	_apply_layout()

	_build_panel()
	_connect_signals()
	_refresh()

func _on_viewport_size_changed() -> void:
	_apply_layout()

func _apply_layout() -> void:
	var viewport_size := get_viewport_rect().size
	var panel_width: float = clamp(viewport_size.x * PANEL_WIDTH_RATIO, PANEL_MIN_SIZE.x, PANEL_MAX_SIZE.x)
	var panel_height: float = clamp(viewport_size.y * PANEL_HEIGHT_RATIO, PANEL_MIN_SIZE.y, PANEL_MAX_SIZE.y)

	offset_left = viewport_size.x - panel_width - PANEL_MARGIN
	offset_top = PANEL_MARGIN
	offset_right = viewport_size.x - PANEL_MARGIN
	offset_bottom = PANEL_MARGIN + panel_height
	custom_minimum_size = Vector2(panel_width, panel_height)

func _build_panel() -> void:
	if _content_label != null:
		return

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	_content_label = RichTextLabel.new()
	_content_label.anchor_right = 1.0
	_content_label.anchor_bottom = 1.0
	_content_label.bbcode_enabled = false
	_content_label.add_theme_font_size_override("normal_font_size", 10)
	_content_label.fit_content = false
	_content_label.scroll_active = true
	margin.add_child(_content_label)

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

func _on_state_changed(_from_state: String, _to_state: String) -> void:
	_refresh()

func _refresh() -> void:
	if _content_label == null:
		return
	_content_label.text = _build_snapshot()

func _build_snapshot() -> String:
	var lines: PackedStringArray = []
	var current_state := SceneManager.current_state_name
	var display_class := PlayerData.get_display_class()
	var time_data: Dictionary = GameClock.get_time()

	lines.append("Technical Spike Debug Panel")
	lines.append("State: %s" % _display_value(current_state, "none"))
	lines.append("Clock: %s" % time_data.get("display", "unknown"))
	lines.append("Location: %s (%s)" % [
		_display_value(PlayerData.current_location, "unset"),
		_display_value(PlayerData.current_region, "unset"),
	])
	lines.append("Path: %s" % _display_value(PlayerData.chosen_path, "unset"))
	lines.append("Class: %s" % _display_value(display_class, "unset"))
	lines.append("Age: %d years / %d days" % [PlayerData.age_years, PlayerData.age_days])
	lines.append("Flags: %s" % _format_dictionary(PlayerData.flags))
	lines.append("Ghost Flags: %s" % _format_dictionary(PlayerData.ghost_flags))
	lines.append("")
	lines.append("Stats")

	for category in CATEGORY_ORDER:
		if not StatRegistry.stats.has(category):
			continue

		lines.append("%s:" % category.capitalize())
		for skill in _ordered_skills_for(category):
			var stat_path := "%s.%s" % [category, skill]
			lines.append("  %s: %.2f" % [_display_name(skill), StatRegistry.get_stat(stat_path)])

	return "\n".join(lines)

func _ordered_skills_for(category: String) -> Array[String]:
	var ordered: Array[String] = []
	var known_skills: Array = SKILL_ORDER.get(category, [])
	var skills: Dictionary = StatRegistry.stats[category]

	for skill in known_skills:
		if skills.has(skill):
			ordered.append(skill)

	for skill in skills.keys():
		if not ordered.has(skill):
			ordered.append(skill)

	return ordered

func _display_name(value: String) -> String:
	return value.replace("_", " ").capitalize()

func _display_value(value: String, fallback: String) -> String:
	return fallback if value == "" else value

func _format_dictionary(values: Dictionary) -> String:
	if values.is_empty():
		return "none"

	var entries: PackedStringArray = []
	var keys := values.keys()
	keys.sort()
	for key in keys:
		entries.append("%s=%s" % [str(key), str(values[key])])
	return ", ".join(entries)
