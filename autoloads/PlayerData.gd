# PlayerData.gd
# Non-stat character data. Class, allegiance, flags, location, inventory sketch.
# This is the source of truth for who the player IS, not how strong they are.
# StatRegistry handles the numbers. This handles the identity.
extends Node

# --- Class system ---
# chosen_class: the player's primary class (e.g. "knight", "mage", "rogue")
# chosen_path: "pure" or "mixed"
# specialisation: subclass chosen within pure path (e.g. "dark_knight", "holy_knight")
# mixed_classes: array of classes if mixed path chosen (e.g. ["mage", "rogue"])
var chosen_class: String     = ""
var chosen_path: String      = ""   # "pure" or "mixed"
var specialisation: String   = ""
var mixed_classes: Array     = []

# --- World flags ---
# Persistent decisions the world remembers.
# Key: flag name (snake_case). Value: any type.
# e.g. { "shaman_recruited": true, "kobold_mine_cleared": true }
var flags: Dictionary = {}

# --- Ghost flags ---
# Never shown to the player. Influence world behaviour silently.
# Same structure as flags but kept separate for clarity.
var ghost_flags: Dictionary = {}

# --- Location ---
var current_location: String = "town_start"
var current_region: String   = "starting_region"

# --- Inventory (sketch — expand in production) ---
var gold: int          = 0
var inventory: Array   = []   # Array of item Dictionaries
var equipment: Dictionary = {
	"head":    "",
	"chest":   "",
	"legs":    "",
	"feet":    "",
	"weapon":  "",
	"offhand": "",
	"ring":    "",
	"amulet":  "",
}

# --- Age ---
# Tracked separately — it's both a stat and a narrative device.
var age_years: int  = 20
var age_days: int   = 0

func _ready() -> void:
	SignalBus.new_day.connect(_on_new_day)

# Age advances with the clock.
func _on_new_day(_day_number: int) -> void:
	age_days += 1
	if age_days >= 365:
		age_days = 0
		age_years += 1
		SignalBus.flag_set.emit("birthday", age_years)

# --- Flag helpers ---
func set_flag(flag_name: String, value: Variant) -> void:
	flags[flag_name] = value
	SignalBus.flag_set.emit(flag_name, value)

func get_flag(flag_name: String, default: Variant = null) -> Variant:
	return flags.get(flag_name, default)

func has_flag(flag_name: String) -> bool:
	return flags.has(flag_name)

func set_ghost_flag(flag_name: String, value: Variant) -> void:
	ghost_flags[flag_name] = value  # Silent — no signal emitted.

func get_ghost_flag(flag_name: String, default: Variant = null) -> Variant:
	return ghost_flags.get(flag_name, default)

# --- Convenience ---
func is_pure() -> bool:
	return chosen_path == "pure"

func is_mixed() -> bool:
	return chosen_path == "mixed"

func get_display_class() -> String:
	if is_pure() and specialisation != "":
		return specialisation.replace("_", " ").capitalize()
	if is_mixed() and mixed_classes.size() > 0:
		return " / ".join(mixed_classes).capitalize()
	return chosen_class.capitalize()
