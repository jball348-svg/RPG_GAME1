extends Node

const MAIN_SCENE: PackedScene = preload("res://scenes/main/Main.tscn")

const OUTPUT_DIR := "res://tools/evidence/stage_8_5"
const FRONTIER_REGION := "frontier_village"
const TOWN_LOCATION := "starting_town"
const CROSSROADS_REGION := "crossroads_region"
const CROSSROADS_LOCATION := "crossroads_start"
const MINE_REGION := "kobold_mine"
const MINE_LOCATION := "mine_entry_chamber"

const MINE_ENCOUNTER_PROGRESS_FLAG := "mine_encounter_progress"
const MINE_BOSS_READY_FLAG := "mine_boss_ready"
const MINE_BOSS_RESOLVED_FLAG := "mine_boss_resolved"
const MINE_EXIT_UNLOCKED_FLAG := "mine_exit_unlocked"
const MINE_CLEARED_FLAG := "mine_cleared"
const MAIN_QUEST_PATH_OPEN_FLAG := "main_quest_path_open"
const SHAMAN_RECRUITED_FLAG := "shaman_recruited"
const SHAMAN_KILLED_FLAG := "shaman_killed"

var _main: Node
var _results: Dictionary = {}

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	_prepare_output_dir()
	_main = MAIN_SCENE.instantiate()
	add_child(_main)
	await _settle(8)

	_results["boot_from_current_save"] = {
		"has_save": SaveManager.has_save(),
		"state": SceneManager.current_state_name,
		"region": PlayerData.current_region,
		"location": PlayerData.current_location,
	}
	await _capture("01_boot_from_current_save.png")

	await _run_clean_town_checks()
	await _run_cutscene_capture()
	await _run_battle_levelup_checks()
	await _run_crossroads_follow_checks()
	await _run_shaman_kill_branch_check()
	await _write_results()
	get_tree().quit()

func _prepare_output_dir() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))

func _write_results() -> void:
	var output_path := ProjectSettings.globalize_path(OUTPUT_DIR.path_join("runtime_results.json"))
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_warning("Failed to write runtime results to %s" % output_path)
		return
	file.store_string(JSON.stringify(_results, "\t"))

func _reset_clean_profile() -> void:
	StatRegistry.apply_save_data({})
	GameClock.apply_save_data({})
	PlayerData.apply_save_data({})
	PlayerData.flags.clear()
	PlayerData.ghost_flags.clear()
	PlayerData.inventory.clear()
	PlayerData.equipment = PlayerData.DEFAULT_EQUIPMENT.duplicate(true)
	PlayerData.level = PlayerData.DEFAULT_LEVEL
	PlayerData.xp = PlayerData.DEFAULT_XP
	PlayerData.xp_to_next_level = PlayerData.DEFAULT_XP_TO_NEXT_LEVEL
	PlayerData.unspent_stat_points = PlayerData.DEFAULT_UNSPENT_STAT_POINTS
	PlayerData.gold = 0
	PlayerData.age_years = 20
	PlayerData.age_days = 0
	PlayerData.current_region = FRONTIER_REGION
	PlayerData.current_location = TOWN_LOCATION
	PlayerData.set_vertical_slice_debug_profile("pure")
	PlayerData.ensure_spike_defaults()
	PlayerData.restore_hp_full()

func _run_clean_town_checks() -> void:
	_reset_clean_profile()
	SceneManager.change_state("map", {
		"return_region": FRONTIER_REGION,
		"return_location": TOWN_LOCATION,
		"return_position": Vector2(320.0, 448.0),
	}, true)
	await _settle(8)
	_set_debug_panel_suppressed(true)
	await _capture("02_town_bookkeeper.png")

	var blocked_probe := await _probe_movement(Vector2(84.0, 448.0), "move_right", 18, "03_collision_blocked.png")
	var passable_probe := await _probe_movement(Vector2(320.0, 448.0), "move_right", 18, "04_collision_passable.png")
	_results["collision"] = {
		"blocked_probe_distance": blocked_probe,
		"passable_probe_distance": passable_probe,
	}

	PlayerData.unspent_stat_points = 3
	PlayerData.gold = 42
	var hud := _get_hud()
	if hud != null:
		hud.open_to_tab("stats")
		await _settle(3)
		await _capture("05_hud_stats.png")
		hud.open_to_tab("equipment")
		await _settle(3)
		await _capture("06_hud_equipment.png")
		hud.set_open(false)

	_set_debug_panel_suppressed(false)
	var map_scene := _get_map_scene()
	var hint_visible_before := false
	if map_scene != null:
		hint_visible_before = bool((map_scene.get_node("UI/HintLabel") as CanvasItem).visible)
	await _send_input_action("toggle_debug")
	await _settle(3)
	await _capture("07_debug_hidden.png")
	var debug_panel := _get_debug_panel()
	var hint_hidden := false
	if map_scene != null:
		hint_hidden = not bool((map_scene.get_node("UI/HintLabel") as CanvasItem).visible)
	await _send_input_action("toggle_debug")
	await _settle(3)
	_results["debug_toggle"] = {
		"debug_visible_after_restore": debug_panel != null and debug_panel.visible,
		"hint_visible_before_toggle": hint_visible_before,
		"hint_hidden_with_debug_hidden": hint_hidden,
	}
	_set_debug_panel_suppressed(true)

func _run_cutscene_capture() -> void:
	SceneManager.change_state("cutscene", {
		"cutscene_id": "mine_entry",
	}, true)
	await _wait_seconds(1.85)
	await _capture("08_cutscene_mine_entry.png")

func _run_battle_levelup_checks() -> void:
	_reset_clean_profile()
	PlayerData.xp = PlayerData.xp_to_next_level - 10
	SceneManager.change_state("battle", {
		"encounter_kind": "standard",
		"encounter_index": 0,
		"return_region": FRONTIER_REGION,
		"return_location": TOWN_LOCATION,
		"return_position": Vector2(336.0, 416.0),
		"suppressed_trigger_type": "",
		"suppressed_trigger_index": -1,
		"environment_id": "mine",
	}, true)
	await _wait_seconds(1.2)
	await _capture("09_battle_presentation.png")
	await _send_input_action("dev_skip_battle")
	await _wait_for_state("map", 120)
	await _settle(8)
	await _capture("10_levelup_return_hud.png")
	var hud := _get_hud()
	_results["battle_levelup_return"] = {
		"returned_to_map": SceneManager.current_state_name == "map",
		"hud_open": hud != null and hud.is_open(),
		"hud_tab": hud.get("_current_tab") if hud != null else "",
		"level": PlayerData.level,
		"unspent_points": PlayerData.unspent_stat_points,
	}
	if hud != null:
		hud.set_open(false)

func _run_crossroads_follow_checks() -> void:
	_reset_clean_profile()
	PlayerData.set_flag(SHAMAN_RECRUITED_FLAG, true)
	PlayerData.set_flag(MINE_EXIT_UNLOCKED_FLAG, true)
	PlayerData.set_flag(MINE_CLEARED_FLAG, true)
	PlayerData.set_flag(MAIN_QUEST_PATH_OPEN_FLAG, true)
	PlayerData.set_flag(SHAMAN_KILLED_FLAG, false)
	PlayerData.current_region = CROSSROADS_REGION
	PlayerData.current_location = CROSSROADS_LOCATION
	SceneManager.change_state("map", {
		"return_region": CROSSROADS_REGION,
		"return_location": CROSSROADS_LOCATION,
		"return_position": Vector2.ZERO,
	}, true)
	await _settle(8)
	await _capture("11_shaman_follow_crossroads.png")
	var map_scene := _get_map_scene()
	_results["crossroads_follow"] = {
		"follower_present": map_scene != null and map_scene.get_node_or_null("ShamanFollower") != null,
		"region": PlayerData.current_region,
		"location": PlayerData.current_location,
	}

func _run_shaman_kill_branch_check() -> void:
	_reset_clean_profile()
	PlayerData.current_region = MINE_REGION
	PlayerData.current_location = MINE_LOCATION
	SceneManager.change_state("battle", {
		"encounter_kind": "boss_shaman",
		"encounter_index": -1,
		"return_region": MINE_REGION,
		"return_location": "mine_post_boss",
		"return_position": Vector2.ZERO,
		"suppressed_trigger_type": "",
		"suppressed_trigger_index": -1,
		"environment_id": "mine",
	}, true)
	await _wait_seconds(1.2)
	await _send_input_action("dev_skip_battle")
	await _wait_for_state("map", 120)
	await _settle(8)
	_results["shaman_kill_branch"] = {
		"returned_to_map": SceneManager.current_state_name == "map",
		"shaman_killed": bool(PlayerData.get_flag(SHAMAN_KILLED_FLAG, false)),
		"boss_resolved": bool(PlayerData.get_flag(MINE_BOSS_RESOLVED_FLAG, false)),
		"exit_unlocked": bool(PlayerData.get_flag(MINE_EXIT_UNLOCKED_FLAG, false)),
	}

func _probe_movement(start_position: Vector2, action_name: String, frame_count: int, screenshot_name: String) -> float:
	var map_scene := _get_map_scene()
	if map_scene == null:
		return 0.0
	var player := map_scene.get_node("Player") as CharacterBody2D
	player.global_position = start_position
	player.velocity = Vector2.ZERO
	await _settle(3)
	var before := player.global_position
	Input.action_press(action_name)
	for _frame in range(frame_count):
		await get_tree().physics_frame
	Input.action_release(action_name)
	await _settle(2)
	await _capture(screenshot_name)
	return player.global_position.distance_to(before)

func _wait_for_state(state_name: String, max_checks: int) -> void:
	for _check in range(max_checks):
		if SceneManager.current_state_name == state_name:
			return
		await get_tree().create_timer(0.1).timeout

func _wait_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	await _settle(2)

func _settle(frame_count: int = 4) -> void:
	for _frame in range(frame_count):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw

func _capture(file_name: String) -> void:
	await _settle(2)
	var image := get_viewport().get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(OUTPUT_DIR.path_join(file_name)))

func _send_input_action(action_name: String) -> void:
	var pressed := InputEventAction.new()
	pressed.action = action_name
	pressed.pressed = true
	Input.parse_input_event(pressed)
	await get_tree().process_frame
	var released := InputEventAction.new()
	released.action = action_name
	released.pressed = false
	Input.parse_input_event(released)
	await get_tree().process_frame

func _get_map_scene() -> Node:
	return SceneManager.current_state_scene if SceneManager.current_state_name == "map" else null

func _get_hud() -> Control:
	var overlay_host := SceneManager.get_overlay_host()
	if overlay_host == null:
		return null
	return overlay_host.get_node_or_null("SpikeHUD") as Control

func _get_debug_panel() -> Control:
	var overlay_host := SceneManager.get_overlay_host()
	if overlay_host == null:
		return null
	return overlay_host.get_node_or_null("DebugPanel") as Control

func _set_debug_panel_suppressed(suppressed: bool) -> void:
	var debug_panel := _get_debug_panel()
	if debug_panel != null and debug_panel.has_method("set_suppressed"):
		debug_panel.set_suppressed(suppressed)
