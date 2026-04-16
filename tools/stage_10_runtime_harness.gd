extends Node

const MAIN_SCENE: PackedScene = preload("res://scenes/main/Main.tscn")

const OUTPUT_DIR := "res://tools/evidence/stage_10"
const FRONTIER_REGION := "frontier_village"
const TOWN_LOCATION := "starting_town"
const CROSSROADS_REGION := "crossroads_region"
const CROSSROADS_LOCATION := "crossroads_start"
const MINE_REGION := "kobold_mine"
const MINE_LOCATION := "mine_entry_chamber"

const MINE_COMMIT_FLAG := "mine_entry_commit_applied"
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

	_results["metadata"] = {
		"debug_build": OS.is_debug_build(),
		"music_catalog": AudioManager.get_music_catalog(),
		"sfx_library": AudioManager.SFX_LIBRARY.keys(),
	}

	await _run_town_checks()
	await _run_mine_readability_checks()
	await _run_battle_presentation_checks()
	await _run_shaman_flow_checks()
	await _run_crossroads_follow_checks()
	await _run_release_gate_note()
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

func _reset_clean_profile(debug_profile: String = "pure") -> void:
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
	PlayerData.set_vertical_slice_debug_profile(debug_profile)
	PlayerData.ensure_spike_defaults()
	PlayerData.restore_hp_full()
	AudioManager.stop_music(0.0)
	AudioManager.clear_sfx_history()

func _run_town_checks() -> void:
	_reset_clean_profile("pure")
	SceneManager.change_state("map", {
		"return_region": FRONTIER_REGION,
		"return_location": TOWN_LOCATION,
		"return_position": Vector2(320.0, 448.0),
	}, true)
	await _settle(8)
	await _capture("01_town_start.png")

	var blocked_probe := await _probe_movement(Vector2(320.0, 448.0), "move_right", 18, "02_town_collision_blocked.png")
	var passable_probe := await _probe_movement(Vector2(84.0, 448.0), "move_right", 18, "03_town_collision_passable.png")

	var hud := _get_hud()
	var hud_audio: Dictionary = {}
	if hud != null:
		AudioManager.clear_sfx_history()
		hud.set_open(true)
		await _settle(3)
		hud_audio["open"] = AudioManager.get_last_sfx_id()
		hud.call("_on_tab_button_pressed", "equipment")
		await _settle(2)
		hud_audio["tab"] = AudioManager.get_last_sfx_id()
		hud.set_open(false)
		await _settle(2)
		hud_audio["close"] = AudioManager.get_last_sfx_id()

	var prompt_audio: Dictionary = {}
	var prompt_modal = _get_prompt_modal()
	if prompt_modal != null:
		AudioManager.clear_sfx_history()
		prompt_modal.show_prompt("audio_smoke_cancel", "Audio Smoke", "Cancel path", "OK", "Back")
		await _settle(2)
		await _send_input_action("ui_cancel")
		await _settle(2)
		prompt_audio["cancel"] = AudioManager.get_last_sfx_id()

		AudioManager.clear_sfx_history()
		prompt_modal.show_prompt("audio_smoke_confirm", "Audio Smoke", "Confirm path", "OK", "Back")
		await _settle(2)
		await _send_input_action("ui_accept")
		await _settle(2)
		prompt_audio["confirm"] = AudioManager.get_last_sfx_id()

	AudioManager.clear_sfx_history()
	DialogueManager.start_dialogue("intel_npc")
	await _settle(3)
	await _send_input_action("interact")
	await _settle(2)
	var dialogue_advance_sfx := AudioManager.get_last_sfx_id()
	await _advance_dialogue_until_idle()

	_results["town_checks"] = {
		"music_cue": AudioManager.get_current_cue_id(),
		"blocked_probe_distance": blocked_probe,
		"passable_probe_distance": passable_probe,
		"hud_audio": hud_audio,
		"prompt_audio": prompt_audio,
		"dialogue_advance_sfx": dialogue_advance_sfx,
	}

func _run_mine_readability_checks() -> void:
	_reset_clean_profile("pure")
	PlayerData.set_flag(MINE_COMMIT_FLAG, true)
	SceneManager.change_state("map", {
		"return_region": MINE_REGION,
		"return_location": MINE_LOCATION,
		"return_position": Vector2.ZERO,
	}, true)
	await _settle(8)
	await _capture("04_mine_entry.png")

	var map_scene := _get_map_scene()
	if map_scene == null:
		return
	var player_node := map_scene.get_node("Player")
	var hint_label := map_scene.get_node("UI/HintLabel") as Label

	map_scene.call("_on_mine_encounter_trigger_body_entered", player_node, 1)
	await _settle(2)
	var west_branch_text := hint_label.text
	await _capture("05_mine_west_branch_locked.png")

	PlayerData.set_flag(MINE_ENCOUNTER_PROGRESS_FLAG, 1)
	map_scene.call("_refresh_map_state_after_debug_spawn")
	await _settle(3)
	map_scene.call("_on_mine_encounter_trigger_body_entered", player_node, 2)
	await _settle(2)
	var east_branch_text := hint_label.text

	PlayerData.set_flag(MINE_ENCOUNTER_PROGRESS_FLAG, 2)
	map_scene.call("_refresh_map_state_after_debug_spawn")
	await _settle(3)
	map_scene.call("_on_mine_boss_trigger_body_entered", player_node)
	await _settle(2)
	var boss_gate_text := hint_label.text

	map_scene.call("_on_mine_exit_trigger_body_entered", player_node)
	await _settle(2)
	var exit_gate_text := hint_label.text

	_results["mine_readability"] = {
		"music_cue": AudioManager.get_current_cue_id(),
		"west_branch_locked_text": west_branch_text,
		"east_branch_locked_text": east_branch_text,
		"boss_gate_locked_text": boss_gate_text,
		"exit_gate_locked_text": exit_gate_text,
	}

func _run_battle_presentation_checks() -> void:
	_results["battle_presentation"] = {
		"fighter": await _capture_battle_presentation("pure", "06_battle_fighter.png"),
		"battlemage": await _capture_battle_presentation("mixed", "07_battle_battlemage.png"),
	}

func _capture_battle_presentation(profile: String, screenshot_name: String) -> Dictionary:
	_reset_clean_profile(profile)
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
	await _capture(screenshot_name)

	var battle_scene := _get_battle_scene()
	var result := {
		"class_id": PlayerData.resolve_vertical_slice_class_id(),
		"music_cue": AudioManager.get_current_cue_id(),
		"enemy_actor_id": battle_scene.call("_enemy_actor_id") if battle_scene != null else "",
	}

	await _send_input_action("dev_skip_battle")
	await _wait_for_state("map", 120)
	await _settle(4)
	return result

func _run_shaman_flow_checks() -> void:
	_reset_clean_profile("pure")
	PlayerData.set_flag(MINE_COMMIT_FLAG, true)
	PlayerData.set_flag(MINE_ENCOUNTER_PROGRESS_FLAG, 3)
	PlayerData.set_flag(MINE_BOSS_READY_FLAG, true)
	SceneManager.change_state("cutscene", {
		"cutscene_id": "shaman_intro",
		"return_region": MINE_REGION,
		"return_location": "mine_post_boss",
		"return_position": Vector2.ZERO,
		"suppressed_trigger_type": "boss",
		"suppressed_trigger_index": 0,
	}, true)
	await _wait_seconds(1.4)
	var cutscene_scene := _get_cutscene_scene()
	if cutscene_scene != null:
		cutscene_scene.call("_show_shaman_choice")
	await _settle(4)
	await _capture("08_shaman_intro_choice.png")
	var choice_panel_visible := false
	if cutscene_scene != null:
		var choice_panel = cutscene_scene.get("_choice_panel")
		if choice_panel is CanvasItem:
			choice_panel_visible = (choice_panel as CanvasItem).visible

	var intro_result := {
		"music_cue": AudioManager.get_current_cue_id(),
		"choice_visible": choice_panel_visible,
	}

	if cutscene_scene != null:
		cutscene_scene.call("_on_talk_button_pressed")
	await _wait_for_recruit_resolution()
	await _wait_for_state("map", 160)
	await _settle(8)
	await _capture("09_shaman_recruit_return.png")

	var recruit_result := {
		"returned_state": SceneManager.current_state_name,
		"recruited": bool(PlayerData.get_flag(SHAMAN_RECRUITED_FLAG, false)),
		"boss_resolved": bool(PlayerData.get_flag(MINE_BOSS_RESOLVED_FLAG, false)),
		"exit_unlocked": bool(PlayerData.get_flag(MINE_EXIT_UNLOCKED_FLAG, false)),
		"music_cue": AudioManager.get_current_cue_id(),
	}

	_reset_clean_profile("pure")
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
	await _capture("10_shaman_kill_return.png")

	var kill_result := {
		"returned_state": SceneManager.current_state_name,
		"shaman_killed": bool(PlayerData.get_flag(SHAMAN_KILLED_FLAG, false)),
		"boss_resolved": bool(PlayerData.get_flag(MINE_BOSS_RESOLVED_FLAG, false)),
		"exit_unlocked": bool(PlayerData.get_flag(MINE_EXIT_UNLOCKED_FLAG, false)),
	}

	_reset_clean_profile("pure")
	PlayerData.set_flag(MINE_COMMIT_FLAG, true)
	PlayerData.set_flag(MINE_ENCOUNTER_PROGRESS_FLAG, 3)
	PlayerData.set_flag(MINE_BOSS_READY_FLAG, true)
	PlayerData.set_flag(MINE_BOSS_RESOLVED_FLAG, true)
	PlayerData.set_flag(MINE_EXIT_UNLOCKED_FLAG, true)
	PlayerData.set_flag(SHAMAN_RECRUITED_FLAG, true)
	PlayerData.current_region = MINE_REGION
	PlayerData.current_location = "mine_post_boss"
	SceneManager.change_state("cutscene", {
		"cutscene_id": "mine_exit",
		"shaman_recruited": true,
		"return_region": CROSSROADS_REGION,
		"return_location": CROSSROADS_LOCATION,
		"return_position": Vector2.ZERO,
	}, true)
	await _wait_seconds(1.0)
	await _capture("11_mine_exit_victory.png")

	var exit_result := {
		"music_cue": AudioManager.get_current_cue_id(),
		"state_during_capture": SceneManager.current_state_name,
	}

	_results["shaman_flows"] = {
		"intro": intro_result,
		"recruit": recruit_result,
		"kill": kill_result,
		"exit": exit_result,
	}

func _run_crossroads_follow_checks() -> void:
	_reset_clean_profile("pure")
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
	await _capture("12_crossroads_follower.png")

	var map_scene := _get_map_scene()
	_results["crossroads_follow"] = {
		"music_cue": AudioManager.get_current_cue_id(),
		"follower_present": map_scene != null and map_scene.get_node_or_null("ShamanFollower") != null,
		"region": PlayerData.current_region,
		"location": PlayerData.current_location,
	}

func _run_release_gate_note() -> void:
	_results["release_gate_note"] = {
		"debug_build": OS.is_debug_build(),
		"runtime_release_check_executed": not OS.is_debug_build(),
		"note": "Release-only overlay removal still needs a non-debug executable or editor export smoke.",
	}

func _wait_for_recruit_resolution() -> void:
	for _check in range(160):
		if SceneManager.current_state_name == "map":
			return
		if DialogueManager.is_active():
			await _send_input_action("interact")
		await get_tree().create_timer(0.1).timeout

func _advance_dialogue_until_idle(max_steps: int = 8) -> void:
	for _step in range(max_steps):
		if not DialogueManager.is_active():
			return
		await _send_input_action("interact")
		await _settle(2)

func _probe_movement(start_position: Vector2, action_name: String, frame_count: int, screenshot_name: String) -> float:
	var map_scene := _get_map_scene()
	if map_scene == null:
		return 0.0
	var player_node := map_scene.get_node("Player") as CharacterBody2D
	player_node.global_position = start_position
	player_node.velocity = Vector2.ZERO
	await _settle(3)
	var before := player_node.global_position
	Input.action_press(action_name)
	for _frame in range(frame_count):
		await get_tree().physics_frame
	Input.action_release(action_name)
	await _settle(2)
	await _capture(screenshot_name)
	return player_node.global_position.distance_to(before)

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

func _get_battle_scene() -> Node:
	return SceneManager.current_state_scene if SceneManager.current_state_name == "battle" else null

func _get_cutscene_scene() -> Node:
	return SceneManager.current_state_scene if SceneManager.current_state_name == "cutscene" else null

func _get_hud() -> Control:
	var overlay_host := SceneManager.get_overlay_host()
	if overlay_host == null:
		return null
	return overlay_host.get_node_or_null("SpikeHUD") as Control

func _get_prompt_modal() -> Control:
	var overlay_host := SceneManager.get_overlay_host()
	if overlay_host == null:
		return null
	return overlay_host.get_node_or_null("PromptModal") as Control
