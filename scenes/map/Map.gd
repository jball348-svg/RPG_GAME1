extends Node2D

const WORLD_SIZE := Vector2(960.0, 540.0)
const INNER_MARGIN := 32.0
const PLAYER_SIZE := Vector2(32.0, 32.0)
const MOVE_SPEED := 180.0
const STEP_DISTANCE := 24.0
const HINT_TEXT := "Day 4 Spike Controls\nMove: WASD / Arrows\nB: Battle   H: HUD\nC: Cutscene   1: Pure   2: Mixed"

var _player_position: Vector2 = WORLD_SIZE * 0.5
var _distance_since_step: float = 0.0

@onready var hint_label: Label = $UI/HintLabel

func _ready() -> void:
	PlayerData.current_location = "spike_map"
	PlayerData.current_region = "debug_region"
	hint_label.text = HINT_TEXT
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_hud"):
		get_viewport().set_input_as_handled()
		_toggle_hud()
		return

	if _is_hud_open():
		return

	if event.is_action_pressed("set_path_pure"):
		get_viewport().set_input_as_handled()
		PlayerData.set_chosen_path("pure")
		return

	if event.is_action_pressed("set_path_mixed"):
		get_viewport().set_input_as_handled()
		PlayerData.set_chosen_path("mixed")
		return

	if event.is_action_pressed("debug_cutscene"):
		get_viewport().set_input_as_handled()
		SceneManager.change_state("cutscene")
		return

	if event.is_action_pressed("debug_battle"):
		get_viewport().set_input_as_handled()
		SceneManager.change_state("battle")

func _physics_process(delta: float) -> void:
	if _is_hud_open():
		return

	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector.is_zero_approx():
		return

	var movement: Vector2 = input_vector.normalized() * MOVE_SPEED * delta
	var next_position: Vector2 = _player_position + movement
	var min_bound := Vector2(INNER_MARGIN, INNER_MARGIN)
	var max_bound := WORLD_SIZE - min_bound
	next_position.x = clamp(next_position.x, min_bound.x, max_bound.x)
	next_position.y = clamp(next_position.y, min_bound.y, max_bound.y)

	var actual_movement: Vector2 = next_position - _player_position
	if actual_movement.is_zero_approx():
		return

	_player_position = next_position
	_distance_since_step += actual_movement.length()

	while _distance_since_step >= STEP_DISTANCE:
		_distance_since_step -= STEP_DISTANCE
		SignalBus.action_performed.emit({"type": "walk"})

	queue_redraw()

func _toggle_hud() -> void:
	var hud = _get_spike_hud()
	if hud != null:
		hud.toggle()

func _is_hud_open() -> bool:
	var hud = _get_spike_hud()
	return hud != null and hud.is_open()

func _get_spike_hud():
	var overlay_host: CanvasLayer = SceneManager.get_overlay_host()
	if overlay_host == null:
		return null

	return overlay_host.get_node_or_null("SpikeHUD")

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color(0.10, 0.13, 0.10), true)
	draw_rect(
		Rect2(Vector2(INNER_MARGIN, INNER_MARGIN), WORLD_SIZE - Vector2(INNER_MARGIN * 2.0, INNER_MARGIN * 2.0)),
		Color(0.18, 0.25, 0.18),
		true
	)
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color(0.50, 0.46, 0.30), false, 4.0)

	var player_rect := Rect2(_player_position - (PLAYER_SIZE * 0.5), PLAYER_SIZE)
	draw_rect(player_rect, Color(0.84, 0.34, 0.20), true)
	draw_rect(player_rect, Color(0.08, 0.05, 0.03), false, 2.0)
