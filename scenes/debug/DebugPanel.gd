extends PanelContainer

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
	offset_left = 16.0
	offset_top = 16.0
	offset_right = 356.0
	offset_bottom = 536.0
	custom_minimum_size = Vector2(340.0, 520.0)

	_build_panel()
	_connect_signals()
	_refresh()

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
