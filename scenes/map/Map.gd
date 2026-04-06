extends Node2D

const MOVE_SPEED := 180.0
const STEP_DISTANCE := 24.0
const PLAYER_HALF_EXTENTS := Vector2(10.0, 10.0)
const HINT_TEXT := "Frontier Hamlet\nMove: WASD / Arrows\nB: Battle   H: HUD\nC: Cutscene   1: Pure   2: Mixed"

var _distance_since_step: float = 0.0

@onready var ground_map: TileMap = $GroundMap
@onready var player: CharacterBody2D = $Player
@onready var map_camera: Camera2D = $Player/MapCamera
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var hint_label: Label = $UI/HintLabel

func _ready() -> void:
	_player_data().current_location = "starting_town"
	_player_data().current_region = "frontier_village"
	hint_label.text = HINT_TEXT
	player.global_position = player_spawn.global_position
	map_camera.make_current()
	_configure_map_camera()

func _configure_map_camera() -> void:
	var used_rect := ground_map.get_used_rect()
	var tile_size := ground_map.tile_set.tile_size
	var top_left := used_rect.position * tile_size
	var bottom_right := used_rect.end * tile_size

	map_camera.limit_left = top_left.x
	map_camera.limit_top = top_left.y
	map_camera.limit_right = bottom_right.x
	map_camera.limit_bottom = bottom_right.y

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_hud"):
		get_viewport().set_input_as_handled()
		_toggle_hud()
		return

	if _is_hud_open():
		return

	if event.is_action_pressed("set_path_pure"):
		get_viewport().set_input_as_handled()
		_player_data().set_chosen_path("pure")
		return

	if event.is_action_pressed("set_path_mixed"):
		get_viewport().set_input_as_handled()
		_player_data().set_chosen_path("mixed")
		return

	if event.is_action_pressed("debug_cutscene"):
		get_viewport().set_input_as_handled()
		_scene_manager().change_state("cutscene")
		return

	if event.is_action_pressed("debug_battle"):
		get_viewport().set_input_as_handled()
		_scene_manager().change_state("battle")

func _physics_process(delta: float) -> void:
	if _is_hud_open():
		player.velocity = Vector2.ZERO
		return

	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player.velocity = input_vector.normalized() * MOVE_SPEED if not input_vector.is_zero_approx() else Vector2.ZERO

	var previous_position := player.global_position
	player.move_and_slide()
	_clamp_player_to_map()

	var travelled := player.global_position - previous_position
	if travelled.is_zero_approx():
		return

	_distance_since_step += travelled.length()
	while _distance_since_step >= STEP_DISTANCE:
		_distance_since_step -= STEP_DISTANCE
		_signal_bus().action_performed.emit({"type": "walk"})

func _clamp_player_to_map() -> void:
	var used_rect := ground_map.get_used_rect()
	var tile_size := ground_map.tile_set.tile_size
	var min_bound := Vector2(
		used_rect.position.x * tile_size.x + PLAYER_HALF_EXTENTS.x,
		used_rect.position.y * tile_size.y + PLAYER_HALF_EXTENTS.y
	)
	var max_bound := Vector2(
		used_rect.end.x * tile_size.x - PLAYER_HALF_EXTENTS.x,
		used_rect.end.y * tile_size.y - PLAYER_HALF_EXTENTS.y
	)

	player.global_position = Vector2(
		clamp(player.global_position.x, min_bound.x, max_bound.x),
		clamp(player.global_position.y, min_bound.y, max_bound.y)
	)

func _toggle_hud() -> void:
	var hud = _get_spike_hud()
	if hud != null:
		hud.toggle()

func _is_hud_open() -> bool:
	var hud = _get_spike_hud()
	return hud != null and hud.is_open()

func _get_spike_hud():
	var overlay_host: CanvasLayer = _scene_manager().get_overlay_host()
	if overlay_host == null:
		return null

	return overlay_host.get_node_or_null("SpikeHUD")

func _player_data() -> Node:
	return get_node("/root/PlayerData")

func _scene_manager() -> Node:
	return get_node("/root/SceneManager")

func _signal_bus() -> Node:
	return get_node("/root/SignalBus")
