extends Node

const SAVE_PATH := "user://save_game.json"
const SAVE_VERSION := 1

var _is_loading := false

func _ready() -> void:
	if not SignalBus.state_changed.is_connected(_on_state_changed):
		SignalBus.state_changed.connect(_on_state_changed)
	if not SignalBus.dialogue_ended.is_connected(_on_dialogue_ended):
		SignalBus.dialogue_ended.connect(_on_dialogue_ended)

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> bool:
	if not has_save():
		return true
	var result := DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	return result == OK

func save_game() -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("SaveManager: failed to open save file for writing.")
		return false

	file.store_string(JSON.stringify(_build_save_data(), "\t"))
	return true

func load_game() -> bool:
	if not has_save():
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("SaveManager: failed to open save file for reading.")
		return false

	var raw_text := file.get_as_text()
	var json := JSON.new()
	if json.parse(raw_text) != OK:
		push_warning("SaveManager: save file is malformed.")
		return false

	if not (json.data is Dictionary):
		push_warning("SaveManager: save file root is not a dictionary.")
		return false

	var save_root: Dictionary = json.data
	var world_payload := _build_world_payload(save_root.get("world", {}))

	_is_loading = true
	StatRegistry.apply_save_data(save_root.get("stats", {}))
	GameClock.apply_save_data(save_root.get("clock", {}))
	PlayerData.apply_save_data(save_root.get("player", {}))
	PlayerData.ensure_spike_defaults()
	PlayerData.current_region = str(world_payload.get("return_region", PlayerData.current_region))
	PlayerData.current_location = str(world_payload.get("return_location", PlayerData.current_location))

	var loaded := SceneManager.change_state("map", world_payload, true)
	_is_loading = false

	if not loaded:
		push_warning("SaveManager: failed to enter map state while loading.")
		return false

	return true

func _on_state_changed(_from_state: String, to_state: String) -> void:
	if _is_loading or to_state != "map":
		return

	call_deferred("_autosave_map_entry")

func _on_dialogue_ended(_npc_id: String) -> void:
	if _is_loading or SceneManager.current_state_name != "map":
		return

	save_game()

func _autosave_map_entry() -> void:
	if _is_loading or SceneManager.current_state_name != "map":
		return

	save_game()

func _build_save_data() -> Dictionary:
	var world_context := _resolve_world_context()
	return {
		"version": SAVE_VERSION,
		"stats": StatRegistry.get_save_data(),
		"player": PlayerData.get_save_data(),
		"clock": GameClock.get_save_data(),
		"world": {
			"region": str(world_context.get("region", PlayerData.current_region)),
			"location": str(world_context.get("location", PlayerData.current_location)),
			"position": _vector2_to_save_data(_parse_vector2(world_context.get("position", Vector2.ZERO))),
			"suppressed_trigger_type": str(world_context.get("suppressed_trigger_type", "")),
			"suppressed_trigger_index": int(world_context.get("suppressed_trigger_index", -1)),
		},
	}

func _resolve_world_context() -> Dictionary:
	var active_scene = SceneManager.current_state_scene
	if is_instance_valid(active_scene) and active_scene.has_method("get_save_context"):
		var scene_context = active_scene.call("get_save_context")
		if scene_context is Dictionary:
			return _normalize_world_context(scene_context)

	return _normalize_world_context({})

func _normalize_world_context(raw_context: Dictionary) -> Dictionary:
	return {
		"region": str(raw_context.get("region", PlayerData.current_region)),
		"location": str(raw_context.get("location", PlayerData.current_location)),
		"position": _parse_vector2(raw_context.get("position", Vector2.ZERO)),
		"suppressed_trigger_type": str(raw_context.get("suppressed_trigger_type", "")),
		"suppressed_trigger_index": int(raw_context.get("suppressed_trigger_index", -1)),
	}

func _build_world_payload(world_data: Variant) -> Dictionary:
	var normalized := _normalize_world_context(world_data if world_data is Dictionary else {})
	return {
		"source": "save_load",
		"return_region": normalized["region"],
		"return_location": normalized["location"],
		"return_position": normalized["position"],
		"suppressed_trigger_type": normalized["suppressed_trigger_type"],
		"suppressed_trigger_index": normalized["suppressed_trigger_index"],
	}

func _vector2_to_save_data(value: Vector2) -> Dictionary:
	return {
		"x": value.x,
		"y": value.y,
	}

func _parse_vector2(value: Variant) -> Vector2:
	if value is Vector2:
		return value
	if value is Dictionary:
		return Vector2(
			float(value.get("x", 0.0)),
			float(value.get("y", 0.0))
		)
	return Vector2.ZERO
