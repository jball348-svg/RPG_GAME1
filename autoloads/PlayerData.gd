# PlayerData.gd
# Non-stat character data. Class, allegiance, flags, location, inventory sketch.
# This is the source of truth for who the player IS, not how strong they are.
# StatRegistry handles the numbers. This handles the identity.
extends Node

const VALID_PATHS: Array[String] = ["pure", "mixed"]
const CLASS_FIGHTER := "fighter"
const CLASS_BATTLEMAGE := "battlemage"
const HEALTH_POTION_ID := "health_potion"
const SHAMAN_TALISMAN_ID := "shaman_talisman"
const DEFAULT_POTION_COUNT := 2
const DEFAULT_WEAPON_MODIFIER := 5
const DEFAULT_EQUIPMENT := {
	"head":    "",
	"chest":   "",
	"legs":    "",
	"feet":    "",
	"weapon":  "",
	"offhand": "",
	"ring":    "",
	"amulet":  "",
}

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
var equipment: Dictionary = DEFAULT_EQUIPMENT.duplicate(true)

# --- Age ---
# Tracked separately — it's both a stat and a narrative device.
var age_years: int  = 20
var age_days: int   = 0
var current_hp: int = 0

func _ready() -> void:
	SignalBus.new_day.connect(_on_new_day)
	ensure_spike_defaults()

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

func get_save_data() -> Dictionary:
	return {
		"chosen_class": chosen_class,
		"chosen_path": chosen_path,
		"specialisation": specialisation,
		"mixed_classes": mixed_classes.duplicate(true),
		"gold": gold,
		"current_hp": current_hp,
		"age_years": age_years,
		"age_days": age_days,
		"flags": flags.duplicate(true),
		"ghost_flags": ghost_flags.duplicate(true),
		"inventory": inventory.duplicate(true),
		"equipment": equipment.duplicate(true),
		"progression": {
			"level": null,
			"xp": null,
			"xp_to_next_level": null,
			"unspent_stat_points": null,
		},
	}

func apply_save_data(save_data: Variant) -> void:
	if not (save_data is Dictionary):
		return

	var player_data: Dictionary = save_data
	var saved_path := str(player_data.get("chosen_path", chosen_path))
	if VALID_PATHS.has(saved_path):
		chosen_path = saved_path
	elif not VALID_PATHS.has(chosen_path):
		chosen_path = "pure"

	chosen_class = str(player_data.get("chosen_class", ""))
	specialisation = str(player_data.get("specialisation", ""))
	mixed_classes = _duplicate_array(player_data.get("mixed_classes", []))
	if chosen_class == "":
		_apply_vertical_slice_class_defaults_for_current_path()

	flags = _duplicate_dictionary(player_data.get("flags", {}))
	ghost_flags = _duplicate_dictionary(player_data.get("ghost_flags", {}))
	gold = maxi(0, int(player_data.get("gold", 0)))
	inventory = _duplicate_array(player_data.get("inventory", []))
	equipment = _restore_equipment(player_data.get("equipment", {}))
	age_years = maxi(0, int(player_data.get("age_years", 20)))
	age_days = clampi(int(player_data.get("age_days", 0)), 0, 364)
	set_current_hp(int(player_data.get("current_hp", get_max_hp())))

func _duplicate_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	return {}

func _duplicate_array(value: Variant) -> Array:
	if value is Array:
		return (value as Array).duplicate(true)
	return []

func _restore_equipment(value: Variant) -> Dictionary:
	var restored := DEFAULT_EQUIPMENT.duplicate(true)
	if not (value is Dictionary):
		return restored

	var equipment_data: Dictionary = value
	for slot in restored.keys():
		restored[slot] = str(equipment_data.get(slot, restored[slot]))
	return restored

# --- Convenience ---
func ensure_spike_defaults() -> void:
	if chosen_path == "":
		set_vertical_slice_debug_profile("pure")

	if resolve_vertical_slice_class_id() == "":
		_apply_vertical_slice_class_defaults_for_current_path()

	ensure_vertical_slice_inventory()
	if current_hp <= 0:
		restore_hp_full()

func set_chosen_path(path: String) -> void:
	if not VALID_PATHS.has(path):
		push_warning("Invalid chosen_path requested: %s" % path)
		return

	if chosen_path == path:
		return

	chosen_path = path
	SignalBus.flag_set.emit("chosen_path", chosen_path)

func set_vertical_slice_debug_profile(path: String) -> void:
	if not VALID_PATHS.has(path):
		push_warning("Invalid debug profile requested: %s" % path)
		return

	set_chosen_path(path)
	specialisation = ""
	mixed_classes.clear()

	if path == "mixed":
		chosen_class = CLASS_BATTLEMAGE
	else:
		chosen_class = CLASS_FIGHTER

func resolve_vertical_slice_class_id() -> String:
	if chosen_class != "":
		return chosen_class.to_lower()

	if is_mixed():
		return CLASS_BATTLEMAGE
	if is_pure():
		return CLASS_FIGHTER
	return ""

func has_battle_magik() -> bool:
	return resolve_vertical_slice_class_id() == CLASS_BATTLEMAGE

func get_battle_weapon_modifier() -> int:
	return DEFAULT_WEAPON_MODIFIER

func get_max_hp() -> int:
	return maxi(50, int(round(StatRegistry.get_stat("physical.endurance") * 10.0)))

func set_current_hp(value: int) -> void:
	current_hp = clampi(value, 0, get_max_hp())

func restore_hp_full() -> void:
	current_hp = get_max_hp()

func heal_hp(amount: int) -> int:
	var before := current_hp
	set_current_hp(current_hp + max(amount, 0))
	return current_hp - before

func take_battle_damage(amount: int) -> int:
	var before := current_hp
	set_current_hp(current_hp - max(amount, 0))
	return before - current_hp

func ensure_vertical_slice_inventory() -> void:
	if get_item_count(HEALTH_POTION_ID) <= 0:
		set_item_count(HEALTH_POTION_ID, DEFAULT_POTION_COUNT)

func reset_vertical_slice_battle_resources() -> void:
	set_item_count(HEALTH_POTION_ID, DEFAULT_POTION_COUNT)
	restore_hp_full()

func get_item_count(item_id: String) -> int:
	var index := _find_inventory_index(item_id)
	if index == -1:
		return 0
	return int(inventory[index].get("count", 0))

func set_item_count(item_id: String, count: int) -> void:
	var safe_count: int = maxi(0, count)
	var index: int = _find_inventory_index(item_id)
	if safe_count == 0:
		if index != -1:
			inventory.remove_at(index)
		return

	if index == -1:
		inventory.append({
			"id": item_id,
			"count": safe_count,
		})
		return

	inventory[index]["count"] = safe_count

func add_item(item_id: String, count: int = 1) -> void:
	set_item_count(item_id, get_item_count(item_id) + max(count, 0))

func consume_item(item_id: String, count: int = 1) -> bool:
	var current_count: int = get_item_count(item_id)
	var amount: int = maxi(count, 0)
	if amount <= 0 or current_count < amount:
		return false

	set_item_count(item_id, current_count - amount)
	return true

func _find_inventory_index(item_id: String) -> int:
	for index in range(inventory.size()):
		if str(inventory[index].get("id", "")) == item_id:
			return index
	return -1

func _apply_vertical_slice_class_defaults_for_current_path() -> void:
	if is_mixed():
		chosen_class = CLASS_BATTLEMAGE
	else:
		chosen_class = CLASS_FIGHTER

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
