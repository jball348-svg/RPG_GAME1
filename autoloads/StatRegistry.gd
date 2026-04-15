# StatRegistry.gd
# Holds all character stat values.
# Listens to SignalBus.action_performed and applies modifiers.
# Emits SignalBus.stat_changed whenever a value updates.
# Stats are addressed by path string: "physical.strength" etc.
extends Node

# --- Stat tree ---
# Structure mirrors the design doc exactly.
# Values are floats: 0.0 to 100.0 unless noted.
const DEFAULT_STATS := {
	"physical": {
		"strength":  0.0,
		"endurance": 0.0,
		"movement":  0.0,
	},
	"magik": {
		"spellcasting": 0.0,
		"attunement":   0.0,
		"mana":         50.0,  # starts at half, not zero
	},
	"intelligence": {
		"understanding": 0.0,
		"tactics":       0.0,
		"persuasion":    0.0,
	},
	"social": {
		"charm":      0.0,
		"reputation": 0.0,
		"empathy":    0.0,
		"luck":       0.0,  # derived — updated by _recalculate_luck()
	},
	"will": {
		"resolve":    0.0,
		"focus":      0.0,
		"resistance": 0.0,
	},
	"holy": {
		"faith":     0.0,
		"intuition": 0.0,
		"peace":     0.0,
		"justice":   0.0,
	},
}
var stats: Dictionary = DEFAULT_STATS.duplicate(true)

# --- Temporary modifiers ---
# Active buffs/debuffs with remaining duration (in in-game seconds).
# Structure: { "stat_path": { "modifier": float, "duration": float } }
var temp_modifiers: Dictionary = {}

# --- Action modifier map ---
# Defines which stats change for each action type.
# Values are base increment amounts. Context multipliers applied on top.
# Add new action types here freely as production adds them.
var action_modifiers: Dictionary = {
	"walk":    { "physical.movement": 0.02 },
	"run":     { "physical.movement": 0.05, "physical.endurance": 0.02 },
	"attack":  { "physical.strength": 0.05 },
	"cast":    { "magik.spellcasting": 0.05, "magik.attunement": 0.02 },
	"talk":    { "social.charm": 0.03, "intelligence.persuasion": 0.02 },
	"read":    { "intelligence.understanding": 0.05, "magik.attunement": 0.01 },
	"rest":    { "physical.endurance": 0.03, "holy.peace": 0.02 },
	"meditate":{ "will.focus": 0.05, "holy.faith": 0.03 },
	"pray":    { "holy.faith": 0.08, "holy.peace": 0.03 },
	"wait":    { "will.resolve": 0.01 },
	"swim":    { "physical.endurance": 0.04, "physical.movement": 0.02 },
	"flee_attempt": { "will.resolve": 0.05 },
	"take_damage": { "physical.endurance": 0.03 },
	"shield_bash": { "physical.strength": 0.07, "will.focus": 0.02 },
	"arcane_strike": { "physical.strength": 0.05, "magik.spellcasting": 0.04 },
	"battle_victory": { "physical.endurance": 0.08 },
}

const DERIVED_SKILLS := {
	"social": ["luck"],
}

func _ready() -> void:
	SignalBus.action_performed.connect(_on_action_performed)
	SignalBus.clock_ticked.connect(_on_clock_ticked)

func get_save_data() -> Dictionary:
	return stats.duplicate(true)

func apply_save_data(save_data: Variant) -> void:
	var restored := DEFAULT_STATS.duplicate(true)
	if save_data is Dictionary:
		var saved_stats: Dictionary = save_data
		for category in restored.keys():
			if not saved_stats.has(category) or not (saved_stats[category] is Dictionary):
				continue

			var source_category: Dictionary = saved_stats[category]
			for skill in restored[category].keys():
				if source_category.has(skill):
					restored[category][skill] = float(source_category[skill])

	stats = restored
	temp_modifiers.clear()
	_recalculate_luck()
	_emit_stat_refresh()

# Called whenever any action signal fires.
func _on_action_performed(payload: Dictionary) -> void:
	var action_type: String = payload.get("type", "")
	if action_type == "":
		return
	if not action_modifiers.has(action_type):
		return

	var modifiers: Dictionary = action_modifiers[action_type]
	for stat_path in modifiers:
		var increment: float = modifiers[stat_path]
		# Future: apply context multipliers from payload here
		# e.g. companions present, location type, time of day
		_increment_stat(stat_path, increment)

	_recalculate_luck()

# Increment a stat by path string. Clamps to 0–100.
func _increment_stat(stat_path: String, amount: float) -> void:
	var parts: Array = stat_path.split(".")
	if parts.size() != 2:
		return
	var category: String = parts[0]
	var skill: String = parts[1]
	if not stats.has(category):
		return
	if not stats[category].has(skill):
		return

	var old_value: float = stats[category][skill]
	var new_value: float = clamp(old_value + amount, 0.0, 100.0)
	stats[category][skill] = new_value
	SignalBus.stat_changed.emit(stat_path, new_value)

# Luck is derived from social stats — not directly trained.
# High charm + reputation + empathy = higher luck.
func _recalculate_luck() -> void:
	var social: Dictionary = stats["social"]
	var derived: float = (social["charm"] + social["reputation"] + social["empathy"]) / 3.0
	var old_luck: float = social["luck"]
	if abs(derived - old_luck) > 0.01:
		stats["social"]["luck"] = derived
		SignalBus.stat_changed.emit("social.luck", derived)

# Clock tick — handle any time-based stat decay here.
func _on_clock_ticked(_in_game_time: Dictionary) -> void:
	# Tick down temp modifier durations.
	var expired: Array = []
	for stat_path in temp_modifiers:
		temp_modifiers[stat_path]["duration"] -= 1.0
		if temp_modifiers[stat_path]["duration"] <= 0.0:
			expired.append(stat_path)
	for stat_path in expired:
		temp_modifiers.erase(stat_path)
		SignalBus.stat_changed.emit(stat_path, get_stat(stat_path))

# Apply a temporary modifier. Duration in in-game seconds.
func apply_temp_modifier(stat_path: String, modifier: float, duration: float) -> void:
	temp_modifiers[stat_path] = { "modifier": modifier, "duration": duration }
	SignalBus.stat_changed.emit(stat_path, get_stat(stat_path))

# Get the effective value of a stat (base + any active temp modifier).
func get_stat(stat_path: String) -> float:
	var parts: Array = stat_path.split(".")
	if parts.size() != 2:
		return 0.0
	var base: float = stats.get(parts[0], {}).get(parts[1], 0.0)
	if temp_modifiers.has(stat_path):
		return clamp(base + temp_modifiers[stat_path]["modifier"], 0.0, 100.0)
	return base

func apply_family_allocation(family_key: String) -> bool:
	if not stats.has(family_key):
		return false

	var category_stats: Dictionary = stats[family_key]
	var changed := false
	for skill_value in category_stats.keys():
		var skill := str(skill_value)
		if _is_derived_skill(family_key, skill):
			continue
		_increment_stat("%s.%s" % [family_key, skill], 1.0)
		changed = true

	if family_key == "social":
		_recalculate_luck()

	return changed

func get_family_average(family_key: String) -> float:
	if not stats.has(family_key):
		return 0.0

	var total := 0.0
	var count := 0
	var category_stats: Dictionary = stats[family_key]
	for skill_value in category_stats.keys():
		var skill := str(skill_value)
		if _is_derived_skill(family_key, skill):
			continue
		total += get_stat("%s.%s" % [family_key, skill])
		count += 1

	if count <= 0:
		return 0.0
	return total / float(count)

func _is_derived_skill(category: String, skill: String) -> bool:
	if not DERIVED_SKILLS.has(category):
		return false
	return DERIVED_SKILLS[category].has(skill)

func _emit_stat_refresh() -> void:
	for category in stats.keys():
		for skill in stats[category].keys():
			var stat_path := "%s.%s" % [category, skill]
			SignalBus.stat_changed.emit(stat_path, get_stat(stat_path))
