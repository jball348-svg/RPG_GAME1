extends Node2D

const MOVE_SPEED := 180.0
const STEP_DISTANCE := 24.0
const PLAYER_HALF_EXTENTS := Vector2(10.0, 10.0)
const DEFAULT_BLOCKING_TILE_LAYERS: Array[int] = [2, 3]
const MINE_BLOCKING_TILE_LAYERS: Array[int] = [2]
const OVERLAY_BLOCKING_LAYER := 4
const ROAD_LAYER := 1
const OVERLAY_BLOCK_BOTTOM_ROWS := 4
const UI_PANEL_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/panel_brown.png"
const UI_BUTTON_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/buttonLong_brown.png"
const UI_BUTTON_PRESSED_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/buttonLong_brown_pressed.png"
const UI_BUTTON_DISABLED_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/buttonLong_grey.png"
const NPC_SCENE: PackedScene = preload("res://scenes/npc/NPC.tscn")
const TOWN_EXIT_PROMPT_ID := "town_exit"
const TOWN_EXIT_PROMPT_TITLE := "Leave for the Mine?"
const TOWN_EXIT_PROMPT_CONFIRM_TEXT := "Continue"
const TOWN_EXIT_PROMPT_CANCEL_TEXT := "Stay"
const TOWN_EXIT_PROMPT_TEXT := "You prepare to leave for the mine. There is no turning back. Continue?"
const TOWN_HINT_TEXT := "Frontier Hamlet\nMove: WASD / Arrows\nB: Battle   H: HUD\nC: Cutscene   1: Pure   2: Mixed\n3: Social+Gold  4: Intel  0: Reset stats"
const MINE_HINT_BASE_TEXT := "Kobold Mine\nMove: WASD / Arrows\nB: Battle   H: HUD\nC: Cutscene   1: Pure   2: Mixed\n3: Social+Gold  4: Intel  0: Reset stats"
const CROSSROADS_HINT_TEXT := "Crossroads\nMove: WASD / Arrows\nE: Interact"
const MINE_BOSS_LOCKED_TEXT := "A heavy ward blocks the top shaft. Clear earlier encounter rooms first."
const MINE_EXIT_LOCKED_TEXT := "The mine exit is sealed. Resolve the boss room first."
const MINE_EXIT_PROMPT_ID := "mine_exit"
const MINE_EXIT_PROMPT_TITLE := "Leave Kobold Mine?"
const MINE_EXIT_PROMPT_CONFIRM_TEXT := "Leave"
const MINE_EXIT_PROMPT_CANCEL_TEXT := "Stay"
const MINE_EXIT_PROMPT_TEXT := "Leave the mine? Stage 7 transition is still pending, but this will mark mine progression as cleared."

const FRONTIER_REGION := "frontier_village"
const TOWN_LOCATION := "starting_town"
const MINE_REGION := "kobold_mine"
const MINE_LOCATION := "mine_entry_chamber"
const MINE_EXIT_LOCATION := "mine_exit_gate"
const CROSSROADS_REGION := "crossroads_region"
const CROSSROADS_LOCATION := "crossroads_start"
const MINE_BATTLE_ENVIRONMENT := "mine"
const MINE_COMMIT_FLAG := "mine_entry_commit_applied"
const MINE_ENCOUNTER_PROGRESS_FLAG := "mine_encounter_progress"
const MINE_BOSS_READY_FLAG := "mine_boss_ready"
const MINE_BOSS_RESOLVED_FLAG := "mine_boss_resolved"
const MINE_EXIT_UNLOCKED_FLAG := "mine_exit_unlocked"
const MINE_CLEARED_FLAG := "mine_cleared"
const MAIN_QUEST_PATH_OPEN_FLAG := "main_quest_path_open"
const SHAMAN_RECRUITED_FLAG := "shaman_recruited"
const SHAMAN_KILLED_FLAG := "shaman_killed"
const MINE_REGULAR_ENCOUNTER_COUNT := 3
const BATTLE_KIND_STANDARD := "standard"
const BATTLE_KIND_BOSS_PLACEHOLDER := "boss_placeholder"
const BATTLE_KIND_DEBUG := "debug"
const SUPPRESSED_TRIGGER_ENCOUNTER := "encounter"
const SUPPRESSED_TRIGGER_BOSS := "boss"
const CUTSCENE_ID_MINE_ENTRY := "mine_entry"
const CUTSCENE_ID_SHAMAN_INTRO := "shaman_intro"
const CUTSCENE_ID_MINE_EXIT := "mine_exit"
const CROSSROADS_SIGNPOST_DIALOGUE_ID := "crossroads_signpost"

const MINE_MAP_SIZE := Vector2i(42, 30)
const MINE_ENTRY_SPAWN_CELL := Vector2i(21, 27)
const MINE_MID_SPAWN_CELL := Vector2i(21, 13)
const MINE_BOSS_READY_SPAWN_CELL := Vector2i(21, 5)
const MINE_POST_BOSS_SPAWN_CELL := Vector2i(33, 3)
const MINE_EXIT_SPAWN_CELL := Vector2i(37, 2)
const CROSSROADS_MAP_SIZE := Vector2i(28, 20)
const CROSSROADS_START_SPAWN_CELL := Vector2i(14, 16)
const CROSSROADS_SIGNPOST_CELL := Vector2i(18, 13)
const CROSSROADS_ROAD_MIN_X := 13
const CROSSROADS_ROAD_MAX_X := 15
const TOWN_SAMPLE_GRASS_CELL := Vector2i(0, 0)
const TOWN_SAMPLE_ROAD_CELL := Vector2i(18, 0)
const MINE_ENCOUNTER_LABELS: PackedStringArray = [
	"Collapsed Hall",
	"Western Den",
	"Eastern Den",
]
const MINE_ENCOUNTER_RECTS: Array[Rect2i] = [
	Rect2i(19, 18, 4, 4),
	Rect2i(6, 10, 4, 4),
	Rect2i(32, 10, 4, 4),
]
const MINE_BOSS_TRIGGER_RECT := Rect2i(16, 1, 10, 3)
const MINE_EXIT_TRIGGER_RECT := Rect2i(37, 1, 2, 3)
const MINE_EXIT_GATE_CELLS: Array[Vector2i] = [
	Vector2i(34, 2),
	Vector2i(34, 3),
	Vector2i(35, 2),
	Vector2i(35, 3),
]
const MINE_WEST_BRANCH_BLOCKER_CELLS: Array[Vector2i] = [
	Vector2i(15, 12),
	Vector2i(15, 13),
	Vector2i(15, 14),
]
const MINE_EAST_BRANCH_BLOCKER_CELLS: Array[Vector2i] = [
	Vector2i(26, 12),
	Vector2i(26, 13),
	Vector2i(26, 14),
]
const MINE_TOP_SHAFT_BLOCKER_CELLS: Array[Vector2i] = [
	Vector2i(19, 7),
	Vector2i(20, 7),
	Vector2i(21, 7),
	Vector2i(22, 7),
]

const MINE_TERRAIN_SOURCE_ID := 0
const MINE_WALL_SOURCE_ID := 1
const MINE_PROPS_SOURCE_ID := 2
const MINE_ROCK_FILL_TILES: Array[Vector2i] = [
	Vector2i(6, 0),
	Vector2i(7, 0),
	Vector2i(6, 1),
	Vector2i(7, 1),
]
const MINE_FLOOR_TILES: Array[Vector2i] = [
	Vector2i(1, 2),
	Vector2i(2, 2),
	Vector2i(1, 3),
	Vector2i(2, 3),
]
const MINE_WALL_FILL_TILES: Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(1, 1),
	Vector2i(2, 1),
	Vector2i(3, 1),
]
const MINE_WALL_TOP_TILES: Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(1, 0),
	Vector2i(2, 0),
	Vector2i(3, 0),
]
const MINE_WALL_BOTTOM_TILES: Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(1, 1),
	Vector2i(2, 1),
	Vector2i(3, 1),
]
const MINE_WALL_LEFT_TILES: Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(0, 1),
]
const MINE_WALL_RIGHT_TILES: Array[Vector2i] = [
	Vector2i(3, 0),
	Vector2i(3, 1),
]
const MINE_WALL_TOP_LEFT_TILE := Vector2i(0, 0)
const MINE_WALL_TOP_RIGHT_TILE := Vector2i(3, 0)
const MINE_WALL_BOTTOM_LEFT_TILE := Vector2i(0, 1)
const MINE_WALL_BOTTOM_RIGHT_TILE := Vector2i(3, 1)
const MINE_PROP_BRAZIER_TILE := Vector2i(0, 0)
const MINE_PROP_SPIKE_PAIR_TILE := Vector2i(1, 0)
const MINE_PROP_STALAGMITE_TILE := Vector2i(2, 1)
const MINE_PROP_IRON_CRATE_TILE := Vector2i(3, 0)
const MINE_PROP_FIRE_GRATE_TILE := Vector2i(4, 0)
const MINE_PROP_ROCK_CLUSTER_A_TILE := Vector2i(1, 1)
const MINE_PROP_ROCK_CLUSTER_B_TILE := Vector2i(3, 1)
const MINE_PROP_BOULDER_TILE := Vector2i(1, 2)
const MINE_PROP_BOULDER_WIDE_TILE := Vector2i(3, 2)
const MINE_PROP_CRATE_TILE := Vector2i(2, 0)
const MINE_PROP_TORCH_TILE := Vector2i(5, 0)
const MINE_PROP_TALL_STALAGMITE_TILE := Vector2i(0, 1)
const MINE_PROP_TALL_STALAGMITE_SIZE := Vector2i(1, 2)

const MINE_TERRAIN_TEXTURE_PATH := "res://assets/art/tilesets/basic caves and dungeons 32x32 standard - v1.0/tiles/tiles-all-32x32.png"
const MINE_WALL_TEXTURE_PATH := "res://assets/art/tilesets/basic caves and dungeons 32x32 standard - v1.0/tiles/wall-tiles-32x32.png"
const MINE_PROPS_TEXTURE_PATH := "res://assets/art/tilesets/basic caves and dungeons 32x32 standard - v1.0/assets/assets-all.png"

var _distance_since_step: float = 0.0
var _town_exit_trigger_armed := false
var _is_mine_start_map := false
var _is_crossroads_map := false
var _active_region := FRONTIER_REGION
var _town_tileset: TileSet
var _mine_trigger_root: Node2D
var _mine_encounter_areas: Array[Area2D] = []
var _mine_status_text := ""
var _incoming_state_payload: Dictionary = {}
var _mine_boss_area: Area2D
var _suppressed_mine_trigger_type := ""
var _suppressed_mine_trigger_index := -1
var _state_transition_locked := false
var _panel_texture: Texture2D
var _button_texture: Texture2D
var _button_pressed_texture: Texture2D
var _button_disabled_texture: Texture2D
var _dev_loader_backdrop: ColorRect
var _dev_loader_panel: PanelContainer
var _dev_loader_button_list: VBoxContainer

@onready var ground_map: TileMap = $GroundMap
@onready var world_collision: StaticBody2D = $WorldCollision
@onready var player: CharacterBody2D = $Player
@onready var map_camera: Camera2D = $Player/MapCamera
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var mine_spawn: Marker2D = $MineSpawn
@onready var town_exit_trigger: Area2D = $TownExitTrigger
@onready var map_ui: CanvasLayer = $UI
@onready var hint_backdrop: ColorRect = $UI/HintBackdrop
@onready var hint_label: Label = $UI/HintLabel

func _ready() -> void:
	_town_tileset = ground_map.tile_set
	_incoming_state_payload = _scene_manager().consume_state_payload()
	_active_region = _resolve_target_region()
	_is_mine_start_map = _should_load_mine_start_map()
	_is_crossroads_map = _active_region == CROSSROADS_REGION
	_load_ui_textures()

	if _is_mine_start_map:
		_setup_mine_start_map()
	elif _is_crossroads_map:
		_setup_crossroads_map()
	else:
		_setup_town_map()

	_build_world_collision()
	map_camera.make_current()
	_configure_map_camera()
	_build_dev_location_loader()
	_layout_map_ui()
	_connect_overlay_signals()

	if not get_viewport().size_changed.is_connected(_on_viewport_size_changed):
		get_viewport().size_changed.connect(_on_viewport_size_changed)

	_apply_incoming_state_payload()

func _should_load_mine_start_map() -> bool:
	return _active_region == MINE_REGION

func _resolve_target_region() -> String:
	return str(_incoming_state_payload.get("return_region", _player_data().current_region))

func _connect_overlay_signals() -> void:
	SignalBus.dialogue_started.connect(_on_overlay_state_changed)
	SignalBus.dialogue_ended.connect(_on_overlay_state_changed)

	var prompt_modal = _get_prompt_modal()
	if prompt_modal == null:
		return

	if not prompt_modal.confirmed.is_connected(_on_prompt_modal_confirmed):
		prompt_modal.confirmed.connect(_on_prompt_modal_confirmed)

	if not prompt_modal.canceled.is_connected(_on_prompt_modal_canceled):
		prompt_modal.canceled.connect(_on_prompt_modal_canceled)

	if not prompt_modal.opened.is_connected(_on_overlay_state_changed):
		prompt_modal.opened.connect(_on_overlay_state_changed)

	if not prompt_modal.closed.is_connected(_on_overlay_state_changed):
		prompt_modal.closed.connect(_on_overlay_state_changed)

func _setup_town_map() -> void:
	_player_data().current_location = str(_incoming_state_payload.get("return_location", TOWN_LOCATION))
	_player_data().current_region = str(_incoming_state_payload.get("return_region", FRONTIER_REGION))
	_mine_status_text = ""

	if _town_tileset != null:
		ground_map.tile_set = _town_tileset

	hint_label.text = TOWN_HINT_TEXT
	player.global_position = _resolve_spawn_position(player_spawn.global_position)
	_wire_town_exit_prompt()

func _setup_mine_start_map() -> void:
	var incoming_location := str(_incoming_state_payload.get("return_location", _player_data().current_location))
	if incoming_location == "" or not incoming_location.begins_with("mine_"):
		incoming_location = MINE_LOCATION

	_player_data().current_location = incoming_location
	_player_data().current_region = str(_incoming_state_payload.get("return_region", MINE_REGION))
	_mine_status_text = ""

	_disable_town_only_content()
	_build_mine_layout()
	_setup_mine_triggers()
	_wire_mine_exit_prompt()
	_restore_mine_progress_state()
	mine_spawn.position = ground_map.map_to_local(MINE_ENTRY_SPAWN_CELL)
	player.global_position = _resolve_spawn_position(mine_spawn.global_position)
	_update_mine_hint()

func _setup_crossroads_map() -> void:
	_player_data().current_location = str(_incoming_state_payload.get("return_location", CROSSROADS_LOCATION))
	_player_data().current_region = str(_incoming_state_payload.get("return_region", CROSSROADS_REGION))
	_mine_status_text = ""

	if _town_tileset != null:
		ground_map.tile_set = _town_tileset

	_disable_town_only_content()
	_build_crossroads_layout()
	_spawn_crossroads_signpost()
	hint_label.text = CROSSROADS_HINT_TEXT
	player.global_position = _resolve_spawn_position(_tile_to_global_position(CROSSROADS_START_SPAWN_CELL))

func _disable_town_only_content() -> void:
	_town_exit_trigger_armed = false
	_hide_prompt_modal()
	_state_transition_locked = false
	_mine_boss_area = null
	_clear_suppressed_mine_trigger()

	if is_instance_valid(town_exit_trigger):
		town_exit_trigger.monitoring = false

	for node_path in [
		"TownExitTrigger",
		"Triggers",
		"IntelNPC",
		"MoralChoiceNPC",
		"BookstoreNPC",
		"CrossroadsBackdrop",
		"CrossroadsSignpost",
	]:
		var node := get_node_or_null(node_path)
		if node != null:
			node.queue_free()

	if is_instance_valid(_mine_trigger_root):
		_mine_trigger_root.queue_free()
		_mine_trigger_root = null
		_mine_encounter_areas.clear()

func _build_crossroads_layout() -> void:
	var grass_tile := _sample_town_tile(0, TOWN_SAMPLE_GRASS_CELL)
	var road_tile := _sample_town_tile(ROAD_LAYER, TOWN_SAMPLE_ROAD_CELL)

	for layer_index in range(ground_map.get_layers_count()):
		ground_map.clear_layer(layer_index)

	for y in range(CROSSROADS_MAP_SIZE.y):
		for x in range(CROSSROADS_MAP_SIZE.x):
			var cell := Vector2i(x, y)
			_set_sampled_tile(0, cell, grass_tile)

			if x >= CROSSROADS_ROAD_MIN_X and x <= CROSSROADS_ROAD_MAX_X:
				_set_sampled_tile(ROAD_LAYER, cell, road_tile)

	for shoulder_x in [CROSSROADS_ROAD_MIN_X - 1, CROSSROADS_ROAD_MAX_X + 1]:
		_set_sampled_tile(ROAD_LAYER, Vector2i(shoulder_x, CROSSROADS_MAP_SIZE.y - 3), road_tile)

	_build_crossroads_backdrop()

func _build_crossroads_backdrop() -> void:
	var existing := get_node_or_null("CrossroadsBackdrop")
	if existing != null:
		existing.queue_free()

	var backdrop := Node2D.new()
	backdrop.name = "CrossroadsBackdrop"
	backdrop.z_index = -9
	add_child(backdrop)

	var map_width := float(CROSSROADS_MAP_SIZE.x * ground_map.tile_set.tile_size.x)
	var sky_height := float(ground_map.tile_set.tile_size.y * 7)

	var sky := Polygon2D.new()
	sky.color = Color(0.63, 0.70, 0.78, 1.0)
	sky.polygon = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(map_width, 0.0),
		Vector2(map_width, sky_height),
		Vector2(0.0, sky_height),
	])
	backdrop.add_child(sky)

	var mountains_far := Polygon2D.new()
	mountains_far.color = Color(0.39, 0.43, 0.46, 1.0)
	mountains_far.polygon = PackedVector2Array([
		Vector2(0.0, sky_height),
		Vector2(70.0, 84.0),
		Vector2(140.0, 126.0),
		Vector2(214.0, 70.0),
		Vector2(310.0, 122.0),
		Vector2(420.0, 64.0),
		Vector2(520.0, 124.0),
		Vector2(map_width, sky_height),
	])
	backdrop.add_child(mountains_far)

	var mountains_near := Polygon2D.new()
	mountains_near.color = Color(0.28, 0.31, 0.33, 1.0)
	mountains_near.polygon = PackedVector2Array([
		Vector2(0.0, sky_height + 22.0),
		Vector2(54.0, 120.0),
		Vector2(118.0, 148.0),
		Vector2(186.0, 112.0),
		Vector2(262.0, 156.0),
		Vector2(346.0, 106.0),
		Vector2(432.0, 154.0),
		Vector2(520.0, 116.0),
		Vector2(map_width, sky_height + 22.0),
	])
	backdrop.add_child(mountains_near)

func _spawn_crossroads_signpost() -> void:
	var existing := get_node_or_null("CrossroadsSignpost")
	if existing != null:
		existing.queue_free()

	var signpost := NPC_SCENE.instantiate()
	signpost.name = "CrossroadsSignpost"
	signpost.position = _tile_to_global_position(CROSSROADS_SIGNPOST_CELL)
	signpost.npc_id = CROSSROADS_SIGNPOST_DIALOGUE_ID
	signpost.npc_name = "Signpost"

	var sprite := signpost.get_node_or_null("Sprite") as Sprite2D
	if sprite != null:
		sprite.texture = _make_signpost_texture()
		sprite.position = Vector2(0.0, -10.0)

	add_child(signpost)

func _build_mine_layout() -> void:
	ground_map.tile_set = _build_mine_tileset()

	for layer_index in range(ground_map.get_layers_count()):
		ground_map.clear_layer(layer_index)

	var walkable_cells := _build_mine_walkable_cells()
	for y in range(MINE_MAP_SIZE.y):
		for x in range(MINE_MAP_SIZE.x):
			var cell := Vector2i(x, y)
			ground_map.set_cell(0, cell, MINE_TERRAIN_SOURCE_ID, _mine_rock_tile_for(cell))

			if walkable_cells.has(cell):
				ground_map.set_cell(0, cell, MINE_TERRAIN_SOURCE_ID, _mine_floor_tile_for(cell))
				continue

			var boundary_tile := _mine_wall_tile_for(cell, walkable_cells)
			if boundary_tile.x >= 0:
				ground_map.set_cell(2, cell, MINE_WALL_SOURCE_ID, boundary_tile)

	_stamp_mine_props()
	_apply_mine_sequence_blockers()
	_apply_mine_exit_gate_blocker()

func _rebuild_mine_geometry() -> void:
	if not _is_mine_start_map:
		return

	_build_mine_layout()
	_build_world_collision()

func _build_mine_walkable_cells() -> Dictionary:
	var walkable := {}
	_mark_walkable_rect(walkable, Rect2i(17, 24, 8, 5))
	_mark_walkable_rect(walkable, Rect2i(19, 15, 4, 9))
	_mark_walkable_rect(walkable, Rect2i(16, 12, 10, 3))
	_mark_walkable_rect(walkable, Rect2i(10, 12, 6, 3))
	_mark_walkable_rect(walkable, Rect2i(5, 9, 6, 6))
	_mark_walkable_rect(walkable, Rect2i(26, 12, 6, 3))
	_mark_walkable_rect(walkable, Rect2i(31, 8, 6, 8))
	_mark_walkable_rect(walkable, Rect2i(19, 7, 4, 5))
	_mark_walkable_rect(walkable, Rect2i(16, 5, 10, 2))
	_mark_walkable_rect(walkable, Rect2i(14, 1, 14, 4))
	_mark_walkable_rect(walkable, Rect2i(28, 2, 8, 2))
	_mark_walkable_rect(walkable, Rect2i(36, 1, 4, 4))
	return walkable

func _mark_walkable_rect(walkable: Dictionary, rect: Rect2i) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			walkable[Vector2i(x, y)] = true

func _hash_index(cell: Vector2i, item_count: int) -> int:
	if item_count <= 0:
		return 0

	return posmod(cell.x * 37 + cell.y * 17, item_count)

func _variant_tile_for(cell: Vector2i, variants: Array[Vector2i]) -> Vector2i:
	return variants[_hash_index(cell, variants.size())]

func _mine_rock_tile_for(cell: Vector2i) -> Vector2i:
	return _variant_tile_for(cell, MINE_ROCK_FILL_TILES)

func _mine_floor_tile_for(cell: Vector2i) -> Vector2i:
	return _variant_tile_for(cell, MINE_FLOOR_TILES)

func _mine_wall_tile_for(cell: Vector2i, walkable_cells: Dictionary) -> Vector2i:
	var up := walkable_cells.has(cell + Vector2i.UP)
	var down := walkable_cells.has(cell + Vector2i.DOWN)
	var left := walkable_cells.has(cell + Vector2i.LEFT)
	var right := walkable_cells.has(cell + Vector2i.RIGHT)
	var touches_walkable := up or down or left or right

	if not touches_walkable:
		return Vector2i(-1, -1)

	if down and right and not up and not left:
		return MINE_WALL_TOP_LEFT_TILE
	if down and left and not up and not right:
		return MINE_WALL_TOP_RIGHT_TILE
	if up and right and not down and not left:
		return MINE_WALL_BOTTOM_LEFT_TILE
	if up and left and not down and not right:
		return MINE_WALL_BOTTOM_RIGHT_TILE
	if down and not up:
		return _variant_tile_for(cell, MINE_WALL_TOP_TILES)
	if up and not down:
		return _variant_tile_for(cell, MINE_WALL_BOTTOM_TILES)
	if right and not left:
		return _variant_tile_for(cell, MINE_WALL_LEFT_TILES)
	if left and not right:
		return _variant_tile_for(cell, MINE_WALL_RIGHT_TILES)

	return _variant_tile_for(cell, MINE_WALL_FILL_TILES)

func _stamp_prop_cells(atlas_coord: Vector2i, cells: Array[Vector2i]) -> void:
	for cell in cells:
		ground_map.set_cell(3, cell, MINE_PROPS_SOURCE_ID, atlas_coord)

func _stamp_mine_props() -> void:
	_stamp_prop_cells(MINE_PROP_CRATE_TILE, [Vector2i(19, 26), Vector2i(22, 26), Vector2i(18, 15), Vector2i(23, 15)])
	_stamp_prop_cells(MINE_PROP_IRON_CRATE_TILE, [Vector2i(20, 26), Vector2i(21, 26), Vector2i(18, 5), Vector2i(23, 5)])
	_stamp_prop_cells(MINE_PROP_TORCH_TILE, [
		Vector2i(18, 24),
		Vector2i(23, 24),
		Vector2i(17, 13),
		Vector2i(24, 13),
		Vector2i(6, 10),
		Vector2i(9, 12),
		Vector2i(32, 9),
		Vector2i(35, 13),
	])
	_stamp_prop_cells(MINE_PROP_BRAZIER_TILE, [Vector2i(15, 2), Vector2i(26, 2)])
	_stamp_prop_cells(MINE_PROP_FIRE_GRATE_TILE, [Vector2i(19, 2), Vector2i(22, 2)])
	_stamp_prop_cells(MINE_PROP_SPIKE_PAIR_TILE, [Vector2i(17, 25), Vector2i(24, 25), Vector2i(7, 8), Vector2i(34, 7)])
	_stamp_prop_cells(MINE_PROP_STALAGMITE_TILE, [
		Vector2i(17, 23),
		Vector2i(24, 23),
		Vector2i(5, 8),
		Vector2i(10, 8),
		Vector2i(31, 7),
		Vector2i(36, 7),
		Vector2i(15, 4),
		Vector2i(26, 4),
	])
	_stamp_prop_cells(MINE_PROP_TALL_STALAGMITE_TILE, [
		Vector2i(4, 8),
		Vector2i(17, 22),
		Vector2i(24, 22),
		Vector2i(30, 7),
	])
	_stamp_prop_cells(MINE_PROP_ROCK_CLUSTER_A_TILE, [
		Vector2i(18, 23),
		Vector2i(23, 23),
		Vector2i(4, 10),
		Vector2i(4, 13),
		Vector2i(30, 9),
		Vector2i(30, 14),
		Vector2i(14, 2),
		Vector2i(27, 2),
	])
	_stamp_prop_cells(MINE_PROP_ROCK_CLUSTER_B_TILE, [
		Vector2i(19, 14),
		Vector2i(22, 14),
		Vector2i(11, 11),
		Vector2i(11, 14),
		Vector2i(37, 10),
		Vector2i(37, 13),
		Vector2i(16, 7),
		Vector2i(25, 7),
	])
	_stamp_prop_cells(MINE_PROP_BOULDER_TILE, [
		Vector2i(16, 24),
		Vector2i(25, 24),
		Vector2i(12, 12),
		Vector2i(29, 12),
		Vector2i(6, 15),
		Vector2i(35, 16),
	])
	_stamp_prop_cells(MINE_PROP_BOULDER_WIDE_TILE, [
		Vector2i(17, 17),
		Vector2i(24, 17),
		Vector2i(13, 1),
		Vector2i(28, 1),
	])

func _apply_mine_sequence_blockers() -> void:
	var progress := _mine_encounter_progress()

	if progress < 1:
		_stamp_mine_blocker(MINE_WEST_BRANCH_BLOCKER_CELLS, [
			{"tile": MINE_PROP_ROCK_CLUSTER_A_TILE, "cells": [Vector2i(15, 12)]},
			{"tile": MINE_PROP_BOULDER_WIDE_TILE, "cells": [Vector2i(15, 13)]},
			{"tile": MINE_PROP_CRATE_TILE, "cells": [Vector2i(15, 14)]},
		])

	if progress < 2:
		_stamp_mine_blocker(MINE_EAST_BRANCH_BLOCKER_CELLS, [
			{"tile": MINE_PROP_IRON_CRATE_TILE, "cells": [Vector2i(26, 12)]},
			{"tile": MINE_PROP_ROCK_CLUSTER_B_TILE, "cells": [Vector2i(26, 13)]},
			{"tile": MINE_PROP_BOULDER_TILE, "cells": [Vector2i(26, 14)]},
		])

	if progress < 3:
		_stamp_mine_blocker(MINE_TOP_SHAFT_BLOCKER_CELLS, [
			{"tile": MINE_PROP_BOULDER_TILE, "cells": [Vector2i(19, 7), Vector2i(22, 7)]},
			{"tile": MINE_PROP_BOULDER_WIDE_TILE, "cells": [Vector2i(20, 7)]},
			{"tile": MINE_PROP_SPIKE_PAIR_TILE, "cells": [Vector2i(21, 7)]},
		])

func _stamp_mine_blocker(cells: Array[Vector2i], prop_specs: Array[Dictionary]) -> void:
	for cell in cells:
		ground_map.set_cell(2, cell, MINE_WALL_SOURCE_ID, _variant_tile_for(cell, MINE_WALL_FILL_TILES))

	for spec in prop_specs:
		var atlas_coord: Vector2i = spec["tile"]
		var prop_cells: Array[Vector2i] = []
		for cell_value in spec.get("cells", []):
			if cell_value is Vector2i:
				prop_cells.append(cell_value)
		_stamp_prop_cells(atlas_coord, prop_cells)

func _apply_mine_exit_gate_blocker() -> void:
	if _player_data().get_flag(MINE_EXIT_UNLOCKED_FLAG, false):
		return

	for cell in MINE_EXIT_GATE_CELLS:
		ground_map.set_cell(2, cell, MINE_WALL_SOURCE_ID, _variant_tile_for(cell, MINE_WALL_FILL_TILES))

	ground_map.set_cell(3, Vector2i(34, 2), MINE_PROPS_SOURCE_ID, MINE_PROP_FIRE_GRATE_TILE)
	ground_map.set_cell(3, Vector2i(35, 2), MINE_PROPS_SOURCE_ID, MINE_PROP_IRON_CRATE_TILE)
	ground_map.set_cell(3, Vector2i(34, 3), MINE_PROPS_SOURCE_ID, MINE_PROP_ROCK_CLUSTER_A_TILE)
	ground_map.set_cell(3, Vector2i(35, 3), MINE_PROPS_SOURCE_ID, MINE_PROP_BOULDER_TILE)

func _open_mine_exit_gate(rebuild_collision: bool = true) -> void:
	if rebuild_collision:
		_rebuild_mine_geometry()

func _build_mine_tileset() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(32, 32)
	var terrain_texture := _load_png_texture(MINE_TERRAIN_TEXTURE_PATH)
	var wall_texture := _load_png_texture(MINE_WALL_TEXTURE_PATH)
	var props_texture := _load_png_texture(MINE_PROPS_TEXTURE_PATH)

	if terrain_texture == null or wall_texture == null or props_texture == null:
		return tile_set

	var terrain_source := TileSetAtlasSource.new()
	terrain_source.texture = terrain_texture
	terrain_source.texture_region_size = Vector2i(32, 32)
	for atlas_coord in MINE_ROCK_FILL_TILES + MINE_FLOOR_TILES:
		if not terrain_source.has_tile(atlas_coord):
			terrain_source.create_tile(atlas_coord)
	tile_set.add_source(terrain_source, MINE_TERRAIN_SOURCE_ID)

	var wall_source := TileSetAtlasSource.new()
	wall_source.texture = wall_texture
	wall_source.texture_region_size = Vector2i(32, 32)
	for atlas_coord in MINE_WALL_FILL_TILES + MINE_WALL_TOP_TILES + MINE_WALL_BOTTOM_TILES + MINE_WALL_LEFT_TILES + MINE_WALL_RIGHT_TILES + [
		MINE_WALL_TOP_LEFT_TILE,
		MINE_WALL_TOP_RIGHT_TILE,
		MINE_WALL_BOTTOM_LEFT_TILE,
		MINE_WALL_BOTTOM_RIGHT_TILE,
	]:
		if not wall_source.has_tile(atlas_coord):
			wall_source.create_tile(atlas_coord)
	tile_set.add_source(wall_source, MINE_WALL_SOURCE_ID)

	var props_source := TileSetAtlasSource.new()
	props_source.texture = props_texture
	props_source.texture_region_size = Vector2i(32, 32)
	for atlas_coord in [
		MINE_PROP_BRAZIER_TILE,
		MINE_PROP_SPIKE_PAIR_TILE,
		MINE_PROP_STALAGMITE_TILE,
		MINE_PROP_IRON_CRATE_TILE,
		MINE_PROP_FIRE_GRATE_TILE,
		MINE_PROP_ROCK_CLUSTER_A_TILE,
		MINE_PROP_ROCK_CLUSTER_B_TILE,
		MINE_PROP_BOULDER_TILE,
		MINE_PROP_BOULDER_WIDE_TILE,
		MINE_PROP_CRATE_TILE,
		MINE_PROP_TORCH_TILE,
	]:
		if not props_source.has_tile(atlas_coord):
			props_source.create_tile(atlas_coord)

	if not props_source.has_tile(MINE_PROP_TALL_STALAGMITE_TILE):
		props_source.create_tile(MINE_PROP_TALL_STALAGMITE_TILE, MINE_PROP_TALL_STALAGMITE_SIZE)
	tile_set.add_source(props_source, MINE_PROPS_SOURCE_ID)

	return tile_set

func _load_png_texture(resource_path: String) -> Texture2D:
	var image := Image.load_from_file(resource_path)
	if image == null or image.is_empty():
		push_error("Failed to load mine texture image: %s" % resource_path)
		return null

	return ImageTexture.create_from_image(image)

func _build_world_collision() -> void:
	for child in world_collision.get_children():
		child.queue_free()

	var used_rect := ground_map.get_used_rect()
	var overlay_block_start_y := used_rect.end.y - OVERLAY_BLOCK_BOTTOM_ROWS
	var tile_size := ground_map.tile_set.tile_size
	var tile_size_vector := Vector2(tile_size.x, tile_size.y)
	var half_tile := tile_size_vector * 0.5
	var blocked_cells := {}
	var blocking_tile_layers: Array[int] = MINE_BLOCKING_TILE_LAYERS if _is_mine_start_map else DEFAULT_BLOCKING_TILE_LAYERS

	for layer_index in blocking_tile_layers:
		for cell in ground_map.get_used_cells(layer_index):
			if ground_map.get_cell_source_id(layer_index, cell) == -1:
				continue
			blocked_cells[cell] = true

	for cell in ground_map.get_used_cells(OVERLAY_BLOCKING_LAYER):
		if cell.y < overlay_block_start_y:
			continue

		if ground_map.get_cell_source_id(ROAD_LAYER, cell) != -1:
			continue

		if ground_map.get_cell_source_id(OVERLAY_BLOCKING_LAYER, cell) == -1:
			continue

		blocked_cells[cell] = true

	for cell_value in blocked_cells.keys():
		var cell: Vector2i = cell_value
		var tile_shape := RectangleShape2D.new()
		tile_shape.size = tile_size_vector

		var collision_shape := CollisionShape2D.new()
		collision_shape.shape = tile_shape
		collision_shape.position = Vector2(cell.x, cell.y) * tile_size_vector + half_tile
		world_collision.add_child(collision_shape)

func _wire_town_exit_prompt() -> void:
	_hide_prompt_modal()
	_town_exit_trigger_armed = false
	town_exit_trigger.monitoring = false
	_arm_town_exit_trigger()

	if not town_exit_trigger.body_entered.is_connected(_on_town_exit_trigger_body_entered):
		town_exit_trigger.body_entered.connect(_on_town_exit_trigger_body_entered)

func _wire_mine_exit_prompt() -> void:
	_hide_prompt_modal()

func _apply_incoming_state_payload() -> void:
	if _incoming_state_payload.is_empty():
		return

	player.velocity = Vector2.ZERO
	_apply_incoming_trigger_suppression()

	if _is_mine_start_map:
		var status_text := str(_incoming_state_payload.get("status_text", ""))
		if status_text != "":
			_set_mine_status(status_text)

	if bool(_incoming_state_payload.get("fade_from_black", false)):
		call_deferred("_play_fade_from_black")

func _apply_incoming_trigger_suppression() -> void:
	_suppressed_mine_trigger_type = str(_incoming_state_payload.get("suppressed_trigger_type", ""))
	_suppressed_mine_trigger_index = int(_incoming_state_payload.get("suppressed_trigger_index", -1))

func _clear_suppressed_mine_trigger() -> void:
	_suppressed_mine_trigger_type = ""
	_suppressed_mine_trigger_index = -1

func _resolve_spawn_position(default_position: Vector2) -> Vector2:
	var return_position = _incoming_state_payload.get("return_position", Vector2.ZERO)
	if return_position is Vector2 and not (return_position as Vector2).is_zero_approx():
		return return_position

	var return_location := str(_incoming_state_payload.get("return_location", _player_data().current_location))
	return _spawn_position_for_location(return_location, default_position)

func _spawn_position_for_location(location: String, default_position: Vector2) -> Vector2:
	match location:
		TOWN_LOCATION:
			return player_spawn.global_position
		MINE_LOCATION:
			return mine_spawn.global_position
		"mine_mid":
			return _tile_to_global_position(MINE_MID_SPAWN_CELL)
		"mine_boss_ready":
			return _tile_to_global_position(MINE_BOSS_READY_SPAWN_CELL)
		"mine_post_boss":
			return _tile_to_global_position(MINE_POST_BOSS_SPAWN_CELL)
		MINE_EXIT_LOCATION:
			return _tile_to_global_position(MINE_EXIT_SPAWN_CELL)
		CROSSROADS_LOCATION:
			return _tile_to_global_position(CROSSROADS_START_SPAWN_CELL)
		_:
			return default_position

func _tile_to_global_position(cell: Vector2i) -> Vector2:
	return ground_map.map_to_local(cell)

func _play_fade_from_black() -> void:
	var screen_fader = _scene_manager().get_screen_fader()
	if screen_fader == null:
		return

	screen_fader.force_black()
	screen_fader.fade_from_black(0.35)

func _get_prompt_modal():
	var overlay_host: CanvasLayer = _scene_manager().get_overlay_host()
	if overlay_host == null:
		return null

	return overlay_host.get_node_or_null("PromptModal")

func _show_prompt_modal(prompt_id: String, title: String, body: String, confirm_text: String, cancel_text: String) -> void:
	var prompt_modal = _get_prompt_modal()
	if prompt_modal == null:
		return

	prompt_modal.show_prompt(prompt_id, title, body, confirm_text, cancel_text)

func _hide_prompt_modal() -> void:
	var prompt_modal = _get_prompt_modal()
	if prompt_modal == null:
		return

	prompt_modal.hide_prompt()

func _is_prompt_open() -> bool:
	var prompt_modal = _get_prompt_modal()
	return prompt_modal != null and prompt_modal.is_open()

func _on_prompt_modal_confirmed(prompt_id: String) -> void:
	match prompt_id:
		TOWN_EXIT_PROMPT_ID:
			_on_town_exit_confirmed()

func _on_prompt_modal_canceled(prompt_id: String) -> void:
	match prompt_id:
		TOWN_EXIT_PROMPT_ID:
			_on_town_exit_canceled()

func _on_overlay_state_changed(_unused: Variant = null) -> void:
	if _is_prompt_open() or _is_dev_loader_open():
		_set_debug_panel_suppressed(true)
	else:
		_set_debug_panel_suppressed(false)
	_update_map_overlay_visibility()

func _arm_town_exit_trigger() -> void:
	if not is_instance_valid(town_exit_trigger):
		return

	await get_tree().physics_frame
	await get_tree().physics_frame
	town_exit_trigger.monitoring = true
	_town_exit_trigger_armed = true

func _configure_map_camera() -> void:
	var used_rect := ground_map.get_used_rect()
	var tile_size := ground_map.tile_set.tile_size
	var top_left := used_rect.position * tile_size
	var bottom_right := used_rect.end * tile_size

	map_camera.limit_left = top_left.x
	map_camera.limit_top = top_left.y
	map_camera.limit_right = bottom_right.x
	map_camera.limit_bottom = bottom_right.y

func _setup_mine_triggers() -> void:
	_mine_trigger_root = Node2D.new()
	_mine_trigger_root.name = "MineTriggers"
	add_child(_mine_trigger_root)
	_mine_encounter_areas.clear()
	_mine_boss_area = null

	for encounter_index in range(MINE_REGULAR_ENCOUNTER_COUNT):
		var area := _create_mine_trigger_area(
			"EncounterTrigger%d" % (encounter_index + 1),
			MINE_ENCOUNTER_RECTS[encounter_index]
		)
		area.body_entered.connect(_on_mine_encounter_trigger_body_entered.bind(encounter_index))
		area.body_exited.connect(_on_mine_encounter_trigger_body_exited.bind(encounter_index))
		_mine_encounter_areas.append(area)

	_mine_boss_area = _create_mine_trigger_area("BossTrigger", MINE_BOSS_TRIGGER_RECT)
	_mine_boss_area.body_entered.connect(_on_mine_boss_trigger_body_entered)
	_mine_boss_area.body_exited.connect(_on_mine_boss_trigger_body_exited)

	var exit_area := _create_mine_trigger_area("MineExitTrigger", MINE_EXIT_TRIGGER_RECT)
	exit_area.body_entered.connect(_on_mine_exit_trigger_body_entered)

func _create_mine_trigger_area(trigger_name: String, tile_rect: Rect2i) -> Area2D:
	var tile_size := ground_map.tile_set.tile_size
	var tile_size_vector := Vector2(tile_size.x, tile_size.y)
	var area := Area2D.new()
	area.name = trigger_name
	area.monitoring = true
	area.monitorable = false

	var shape := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = Vector2(tile_rect.size.x * tile_size.x, tile_rect.size.y * tile_size.y)
	shape.shape = rect_shape
	area.add_child(shape)

	var top_left_center := ground_map.map_to_local(tile_rect.position)
	area.position = top_left_center + (rect_shape.size - tile_size_vector) * 0.5
	_mine_trigger_root.add_child(area)
	return area

func _restore_mine_progress_state() -> void:
	var progress := _mine_encounter_progress()
	for encounter_index in range(_mine_encounter_areas.size()):
		if is_instance_valid(_mine_encounter_areas[encounter_index]):
			_mine_encounter_areas[encounter_index].monitoring = encounter_index >= progress

	if is_instance_valid(_mine_boss_area):
		_mine_boss_area.monitoring = not _player_data().get_flag(MINE_BOSS_RESOLVED_FLAG, false)

	if progress >= MINE_REGULAR_ENCOUNTER_COUNT:
		_player_data().set_flag(MINE_BOSS_READY_FLAG, true)

	if _player_data().get_flag(MINE_BOSS_RESOLVED_FLAG, false):
		_player_data().set_flag(MINE_EXIT_UNLOCKED_FLAG, true)

	_rebuild_mine_geometry()

func _mine_encounter_progress() -> int:
	return clampi(int(_player_data().get_flag(MINE_ENCOUNTER_PROGRESS_FLAG, 0)), 0, MINE_REGULAR_ENCOUNTER_COUNT)

func _on_mine_encounter_trigger_body_entered(body: Node, encounter_index: int) -> void:
	if body != player:
		return

	if _state_transition_locked:
		return

	if _suppressed_mine_trigger_type == SUPPRESSED_TRIGGER_ENCOUNTER and _suppressed_mine_trigger_index == encounter_index:
		return

	var progress := _mine_encounter_progress()
	if encounter_index < progress:
		return

	if encounter_index > progress:
		_set_mine_status("A collapsed branch blocks this route. Clear earlier encounter rooms first.")
		return

	_launch_battle(_build_battle_payload(BATTLE_KIND_STANDARD, encounter_index, SUPPRESSED_TRIGGER_ENCOUNTER))

func _on_mine_encounter_trigger_body_exited(body: Node, encounter_index: int) -> void:
	if body != player:
		return

	if _suppressed_mine_trigger_type == SUPPRESSED_TRIGGER_ENCOUNTER and _suppressed_mine_trigger_index == encounter_index:
		_clear_suppressed_mine_trigger()

func _on_mine_boss_trigger_body_entered(body: Node) -> void:
	if body != player:
		return

	if _state_transition_locked:
		return

	if _suppressed_mine_trigger_type == SUPPRESSED_TRIGGER_BOSS:
		return

	if not _player_data().get_flag(MINE_BOSS_READY_FLAG, false):
		_set_mine_status(MINE_BOSS_LOCKED_TEXT)
		return

	if _player_data().get_flag(MINE_BOSS_RESOLVED_FLAG, false):
		return

	player.velocity = Vector2.ZERO
	_scene_manager().change_state("cutscene", {
		"cutscene_id": CUTSCENE_ID_SHAMAN_INTRO,
		"return_region": _player_data().current_region,
		"return_location": _player_data().current_location,
		"return_position": player.global_position,
		"suppressed_trigger_type": SUPPRESSED_TRIGGER_BOSS,
		"suppressed_trigger_index": 0,
	})

func _on_mine_boss_trigger_body_exited(body: Node) -> void:
	if body != player:
		return

	if _suppressed_mine_trigger_type == SUPPRESSED_TRIGGER_BOSS:
		_clear_suppressed_mine_trigger()

func _on_mine_exit_trigger_body_entered(body: Node) -> void:
	if body != player:
		return

	if _is_prompt_open() or _state_transition_locked:
		return

	if not _player_data().get_flag(MINE_EXIT_UNLOCKED_FLAG, false):
		_set_mine_status(MINE_EXIT_LOCKED_TEXT)
		return

	player.velocity = Vector2.ZERO
	_start_mine_exit_cutscene()

func _set_mine_status(status_text: String) -> void:
	_mine_status_text = status_text
	_update_mine_hint()

func _update_mine_hint() -> void:
	if not _is_mine_start_map:
		return

	var progress := _mine_encounter_progress()
	var objective := ""
	if progress < MINE_REGULAR_ENCOUNTER_COUNT:
		objective = "Objective: Clear encounter %d/%d (%s)." % [
			progress + 1,
			MINE_REGULAR_ENCOUNTER_COUNT,
			MINE_ENCOUNTER_LABELS[progress],
		]
	elif not _player_data().get_flag(MINE_BOSS_RESOLVED_FLAG, false):
		objective = "Objective: Enter the boss room."
	elif not _player_data().get_flag(MINE_CLEARED_FLAG, false):
		objective = "Objective: Reach the mine exit trigger."
	else:
		objective = "Objective: Mine progression clear recorded."

	hint_label.text = "%s\n%s" % [MINE_HINT_BASE_TEXT, objective]
	if _mine_status_text != "":
		hint_label.text += "\n%s" % _mine_status_text

	_layout_map_ui()

func _layout_map_ui() -> void:
	var viewport_size := get_viewport_rect().size
	var compact_layout := viewport_size.x <= 640.0 or viewport_size.y <= 360.0
	var margin := 4.0 if compact_layout else 8.0
	var panel_width: float = clampf(viewport_size.x * (0.55 if compact_layout else 0.42), 188.0, 288.0)
	var panel_height := 148.0 if _is_mine_start_map else 104.0

	hint_backdrop.anchor_left = 1.0
	hint_backdrop.anchor_right = 1.0
	hint_backdrop.offset_left = -panel_width - margin
	hint_backdrop.offset_top = margin
	hint_backdrop.offset_right = -margin
	hint_backdrop.offset_bottom = margin + panel_height

	hint_label.anchor_left = 1.0
	hint_label.anchor_right = 1.0
	hint_label.offset_left = hint_backdrop.offset_left + 8.0
	hint_label.offset_top = hint_backdrop.offset_top + 8.0
	hint_label.offset_right = hint_backdrop.offset_right - 8.0
	hint_label.offset_bottom = hint_backdrop.offset_bottom - 8.0
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	hint_label.add_theme_font_size_override("font_size", 8 if compact_layout else 9)
	_layout_dev_location_panel(viewport_size)
	_update_map_overlay_visibility()

func _layout_dev_location_panel(viewport_size: Vector2) -> void:
	if _dev_loader_backdrop == null or _dev_loader_panel == null:
		return

	var compact_layout := viewport_size.x <= 640.0 or viewport_size.y <= 360.0
	_dev_loader_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dev_loader_backdrop.color = Color(0.0, 0.0, 0.0, 0.56)

	var panel_width := clampf(viewport_size.x * 0.42, 220.0, 280.0)
	var panel_height := clampf(viewport_size.y * 0.56, 168.0, 228.0)
	_dev_loader_panel.anchor_left = 0.5
	_dev_loader_panel.anchor_top = 0.5
	_dev_loader_panel.anchor_right = 0.5
	_dev_loader_panel.anchor_bottom = 0.5
	_dev_loader_panel.offset_left = -panel_width * 0.5
	_dev_loader_panel.offset_top = -panel_height * 0.5
	_dev_loader_panel.offset_right = panel_width * 0.5
	_dev_loader_panel.offset_bottom = panel_height * 0.5
	_dev_loader_panel.custom_minimum_size = Vector2(panel_width, panel_height)

	for child in _dev_loader_button_list.get_children():
		if child is Button:
			var button := child as Button
			button.custom_minimum_size = Vector2(0.0, 22.0 if compact_layout else 24.0)
			button.add_theme_font_size_override("font_size", 8 if compact_layout else 9)

func _update_map_overlay_visibility() -> void:
	var show_hint := not _is_hud_open() and not _is_dialogue_active() and not _is_prompt_open() and not _is_dev_loader_open()
	hint_backdrop.visible = show_hint
	hint_label.visible = show_hint

func _build_dev_location_loader() -> void:
	if _dev_loader_panel != null:
		return

	_dev_loader_backdrop = ColorRect.new()
	_dev_loader_backdrop.visible = false
	_dev_loader_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	map_ui.add_child(_dev_loader_backdrop)

	_dev_loader_panel = PanelContainer.new()
	_dev_loader_panel.visible = false
	_dev_loader_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_dev_loader_panel.add_theme_stylebox_override("panel", _make_panel_style(_panel_texture))
	map_ui.add_child(_dev_loader_panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	_dev_loader_panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 6)
	margin.add_child(content)

	var title := Label.new()
	title.text = "Dev Location Loader"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 10)
	content.add_child(title)

	_dev_loader_button_list = VBoxContainer.new()
	_dev_loader_button_list.add_theme_constant_override("separation", 4)
	_dev_loader_button_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(_dev_loader_button_list)

	for entry in _dev_loader_entries():
		var button := Button.new()
		button.text = str(entry.get("label", "Spawn"))
		button.focus_mode = Control.FOCUS_ALL
		button.add_theme_stylebox_override("normal", _make_button_style(_button_texture))
		button.add_theme_stylebox_override("hover", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))
		button.add_theme_stylebox_override("pressed", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))
		button.add_theme_stylebox_override("disabled", _make_button_style(_button_disabled_texture if _button_disabled_texture != null else _button_texture))
		button.add_theme_stylebox_override("focus", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))
		button.pressed.connect(_on_dev_loader_entry_pressed.bind(entry))
		_dev_loader_button_list.add_child(button)

func _show_dev_location_panel() -> void:
	if not OS.is_debug_build():
		return
	if _is_prompt_open() or _is_hud_open() or _is_dialogue_active() or _is_dev_loader_open():
		return

	_dev_loader_backdrop.visible = true
	_dev_loader_panel.visible = true
	_set_debug_panel_suppressed(true)
	_update_map_overlay_visibility()

	for child in _dev_loader_button_list.get_children():
		if child is Button:
			(child as Button).grab_focus()
			break

func _hide_dev_location_panel() -> void:
	if _dev_loader_backdrop != null:
		_dev_loader_backdrop.visible = false
	if _dev_loader_panel != null:
		_dev_loader_panel.visible = false
	_set_debug_panel_suppressed(false)
	_update_map_overlay_visibility()

func _is_dev_loader_open() -> bool:
	return _dev_loader_panel != null and _dev_loader_panel.visible

func _on_dev_loader_entry_pressed(entry: Dictionary) -> void:
	_apply_dev_loader_spawn(entry)

func _on_viewport_size_changed() -> void:
	_layout_map_ui()

func _unhandled_input(event: InputEvent) -> void:
	if _is_dev_loader_open():
		if event.is_action_pressed("ui_cancel"):
			get_viewport().set_input_as_handled()
			_hide_dev_location_panel()
		return

	if _is_prompt_open():
		return

	if event.is_action_pressed("toggle_hud"):
		get_viewport().set_input_as_handled()
		_toggle_hud()
		return

	if _is_hud_open():
		return

	if OS.is_debug_build():
		if event.is_action_pressed("set_path_pure"):
			get_viewport().set_input_as_handled()
			_player_data().set_vertical_slice_debug_profile("pure")
			_player_data().reset_vertical_slice_battle_resources()
			return

		if event.is_action_pressed("set_path_mixed"):
			get_viewport().set_input_as_handled()
			_player_data().set_vertical_slice_debug_profile("mixed")
			_player_data().reset_vertical_slice_battle_resources()
			return

		if event.is_action_pressed("debug_stat_bump_social"):
			get_viewport().set_input_as_handled()
			StatRegistry._increment_stat("social.charm", 5.0)
			StatRegistry._recalculate_luck()
			PlayerData.gold += 25
			return

		if event.is_action_pressed("debug_stat_bump_intelligence"):
			get_viewport().set_input_as_handled()
			StatRegistry._increment_stat("intelligence.understanding", 5.0)
			return

		if event.is_action_pressed("debug_stat_bump_reset"):
			get_viewport().set_input_as_handled()
			_reset_debug_stats_and_gold()
			return

		if event.is_action_pressed("dev_open_loader") and not _is_dialogue_active() and not _is_hud_open():
			get_viewport().set_input_as_handled()
			_show_dev_location_panel()
			return

	if event.is_action_pressed("debug_cutscene"):
		get_viewport().set_input_as_handled()
		_scene_manager().change_state("cutscene", {
			"cutscene_id": CUTSCENE_ID_MINE_ENTRY,
		})
		return

	if event.is_action_pressed("debug_battle"):
		get_viewport().set_input_as_handled()
		_launch_battle(_build_battle_payload(BATTLE_KIND_DEBUG, -1, ""))

func _physics_process(delta: float) -> void:
	if _is_hud_open() or _is_dialogue_active() or _is_prompt_open() or _is_dev_loader_open():
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
	var clamped_position := Vector2(
		clamp(player.global_position.x, min_bound.x, max_bound.x),
		clamp(player.global_position.y, min_bound.y, max_bound.y)
	)

	if clamped_position != player.global_position:
		player.global_position = clamped_position

func _on_town_exit_trigger_body_entered(body: Node) -> void:
	if not _town_exit_trigger_armed:
		return

	if body != player:
		return

	var used_rect := ground_map.get_used_rect()
	var tile_size := ground_map.tile_set.tile_size
	var map_top_y := float(used_rect.position.y * tile_size.y)
	var map_mid_y := map_top_y + float(used_rect.size.y * tile_size.y) * 0.5
	if player.global_position.y > map_mid_y:
		return

	if _is_prompt_open():
		return

	player.velocity = Vector2.ZERO
	_show_prompt_modal(
		TOWN_EXIT_PROMPT_ID,
		TOWN_EXIT_PROMPT_TITLE,
		TOWN_EXIT_PROMPT_TEXT,
		TOWN_EXIT_PROMPT_CONFIRM_TEXT,
		TOWN_EXIT_PROMPT_CANCEL_TEXT
	)

func _on_town_exit_confirmed() -> void:
	_set_debug_panel_suppressed(false)
	_apply_mine_commit_stats_once()
	_scene_manager().change_state("cutscene", {
		"cutscene_id": CUTSCENE_ID_MINE_ENTRY,
	})

func _on_town_exit_canceled() -> void:
	player.velocity = Vector2.ZERO
	_set_debug_panel_suppressed(false)
	_update_map_overlay_visibility()

func _start_mine_exit_cutscene() -> void:
	_start_mine_exit_cutscene_async()

func _start_mine_exit_cutscene_async() -> void:
	if _state_transition_locked:
		return

	_state_transition_locked = true
	var screen_fader = _scene_manager().get_screen_fader()
	if screen_fader != null:
		var fade_tween: Tween = screen_fader.fade_to_black(0.35)
		await fade_tween.finished

	if not _scene_manager().change_state("cutscene", {
		"cutscene_id": CUTSCENE_ID_MINE_EXIT,
		"shaman_recruited": _player_data().get_flag(SHAMAN_RECRUITED_FLAG, false),
		"return_region": CROSSROADS_REGION,
		"return_location": CROSSROADS_LOCATION,
		"return_position": Vector2.ZERO,
	}):
		_state_transition_locked = false
		if screen_fader != null:
			screen_fader.fade_from_black(0.35)

func _toggle_hud() -> void:
	var hud = _get_spike_hud()
	if hud != null:
		hud.toggle()
	_update_map_overlay_visibility()

func _is_hud_open() -> bool:
	var hud = _get_spike_hud()
	return hud != null and hud.is_open()

func _is_dialogue_active() -> bool:
	return DialogueManager.is_active()

func _dev_loader_entries() -> Array[Dictionary]:
	return [
		{
			"label": "Town Start",
			"region": FRONTIER_REGION,
			"location": TOWN_LOCATION,
			"flags": [
				{"flag": MINE_COMMIT_FLAG, "value": false},
				{"flag": MINE_ENCOUNTER_PROGRESS_FLAG, "value": 0},
				{"flag": MINE_BOSS_READY_FLAG, "value": false},
				{"flag": MINE_BOSS_RESOLVED_FLAG, "value": false},
				{"flag": MINE_EXIT_UNLOCKED_FLAG, "value": false},
				{"flag": MINE_CLEARED_FLAG, "value": false},
				{"flag": SHAMAN_RECRUITED_FLAG, "value": false},
				{"flag": SHAMAN_KILLED_FLAG, "value": false},
				{"flag": MAIN_QUEST_PATH_OPEN_FLAG, "value": false},
			],
		},
		{
			"label": "Mine Entry",
			"region": MINE_REGION,
			"location": MINE_LOCATION,
			"flags": [
				{"flag": MINE_COMMIT_FLAG, "value": true},
				{"flag": MINE_ENCOUNTER_PROGRESS_FLAG, "value": 0},
				{"flag": MINE_BOSS_READY_FLAG, "value": false},
				{"flag": MINE_BOSS_RESOLVED_FLAG, "value": false},
				{"flag": MINE_EXIT_UNLOCKED_FLAG, "value": false},
				{"flag": MINE_CLEARED_FLAG, "value": false},
				{"flag": SHAMAN_RECRUITED_FLAG, "value": false},
				{"flag": SHAMAN_KILLED_FLAG, "value": false},
				{"flag": MAIN_QUEST_PATH_OPEN_FLAG, "value": false},
			],
		},
		{
			"label": "Mine Mid",
			"region": MINE_REGION,
			"location": "mine_mid",
			"flags": [
				{"flag": MINE_COMMIT_FLAG, "value": true},
				{"flag": MINE_ENCOUNTER_PROGRESS_FLAG, "value": 2},
				{"flag": MINE_BOSS_READY_FLAG, "value": false},
				{"flag": MINE_BOSS_RESOLVED_FLAG, "value": false},
				{"flag": MINE_EXIT_UNLOCKED_FLAG, "value": false},
				{"flag": MINE_CLEARED_FLAG, "value": false},
				{"flag": SHAMAN_RECRUITED_FLAG, "value": false},
				{"flag": SHAMAN_KILLED_FLAG, "value": false},
				{"flag": MAIN_QUEST_PATH_OPEN_FLAG, "value": false},
			],
		},
		{
			"label": "Mine Boss Ready",
			"region": MINE_REGION,
			"location": "mine_boss_ready",
			"flags": [
				{"flag": MINE_COMMIT_FLAG, "value": true},
				{"flag": MINE_ENCOUNTER_PROGRESS_FLAG, "value": 3},
				{"flag": MINE_BOSS_READY_FLAG, "value": true},
				{"flag": MINE_BOSS_RESOLVED_FLAG, "value": false},
				{"flag": MINE_EXIT_UNLOCKED_FLAG, "value": false},
				{"flag": MINE_CLEARED_FLAG, "value": false},
				{"flag": SHAMAN_RECRUITED_FLAG, "value": false},
				{"flag": SHAMAN_KILLED_FLAG, "value": false},
				{"flag": MAIN_QUEST_PATH_OPEN_FLAG, "value": false},
			],
		},
		{
			"label": "Post Boss",
			"region": MINE_REGION,
			"location": "mine_post_boss",
			"flags": [
				{"flag": MINE_COMMIT_FLAG, "value": true},
				{"flag": MINE_ENCOUNTER_PROGRESS_FLAG, "value": 3},
				{"flag": MINE_BOSS_READY_FLAG, "value": true},
				{"flag": MINE_BOSS_RESOLVED_FLAG, "value": true},
				{"flag": MINE_EXIT_UNLOCKED_FLAG, "value": true},
				{"flag": MINE_CLEARED_FLAG, "value": false},
				{"flag": MAIN_QUEST_PATH_OPEN_FLAG, "value": false},
			],
		},
	]

func _apply_dev_loader_spawn(entry: Dictionary) -> void:
	var target_region := str(entry.get("region", _player_data().current_region))
	var target_location := str(entry.get("location", _player_data().current_location))
	_apply_flag_updates(entry.get("flags", []))
	_hide_dev_location_panel()

	if target_region != _active_region:
		_player_data().current_region = target_region
		_player_data().current_location = target_location
		_scene_manager().change_state("map", {
			"return_region": target_region,
			"return_location": target_location,
			"return_position": Vector2.ZERO,
		}, true)
		return

	_player_data().current_region = target_region
	_player_data().current_location = target_location
	player.velocity = Vector2.ZERO
	player.global_position = _spawn_position_for_location(target_location, player.global_position)
	_refresh_map_state_after_debug_spawn()

func _apply_flag_updates(flag_updates: Array) -> void:
	for value in flag_updates:
		if not (value is Dictionary):
			continue
		var flag_name := str(value.get("flag", ""))
		if flag_name == "":
			continue
		_player_data().set_flag(flag_name, value.get("value", true))

func _refresh_map_state_after_debug_spawn() -> void:
	_state_transition_locked = false
	_mine_status_text = ""
	_clear_suppressed_mine_trigger()

	if _is_mine_start_map:
		_restore_mine_progress_state()
		_update_mine_hint()
	else:
		hint_label.text = CROSSROADS_HINT_TEXT if _is_crossroads_map else TOWN_HINT_TEXT

	_update_map_overlay_visibility()

func _reset_debug_stats_and_gold() -> void:
	for category_value in StatRegistry.stats.keys():
		var category := str(category_value)
		var category_stats: Dictionary = StatRegistry.stats[category]
		for skill_value in category_stats.keys():
			var skill := str(skill_value)
			var current_value: float = float(category_stats[skill])
			if is_zero_approx(current_value):
				continue
			StatRegistry._increment_stat("%s.%s" % [category, skill], -current_value)

	StatRegistry._recalculate_luck()
	PlayerData.gold = 0
	PlayerData.reset_vertical_slice_battle_resources()
	_player_data().set_flag(MINE_COMMIT_FLAG, false)

func _apply_mine_commit_stats_once() -> void:
	if _player_data().get_flag(MINE_COMMIT_FLAG, false):
		return

	StatRegistry._increment_stat("will.resolve", 1.0)
	StatRegistry._increment_stat("holy.faith", 1.0)
	_player_data().set_flag(MINE_COMMIT_FLAG, true)

func _get_spike_hud():
	var overlay_host: CanvasLayer = _scene_manager().get_overlay_host()
	if overlay_host == null:
		return null

	return overlay_host.get_node_or_null("SpikeHUD")

func _set_debug_panel_suppressed(suppressed: bool) -> void:
	var overlay_host: CanvasLayer = _scene_manager().get_overlay_host()
	if overlay_host == null:
		return

	var debug_panel = overlay_host.get_node_or_null("DebugPanel")
	if debug_panel != null and debug_panel.has_method("set_suppressed"):
		debug_panel.set_suppressed(suppressed)

func _player_data() -> Node:
	return get_node("/root/PlayerData")

func _scene_manager() -> Node:
	return get_node("/root/SceneManager")

func _signal_bus() -> Node:
	return get_node("/root/SignalBus")

func get_save_context() -> Dictionary:
	return {
		"region": _player_data().current_region,
		"location": _player_data().current_location,
		"position": player.global_position if is_instance_valid(player) else Vector2.ZERO,
		"suppressed_trigger_type": _suppressed_mine_trigger_type,
		"suppressed_trigger_index": _suppressed_mine_trigger_index,
	}

func _build_battle_payload(encounter_kind: String, encounter_index: int, suppressed_trigger_type: String) -> Dictionary:
	return {
		"encounter_kind": encounter_kind,
		"encounter_index": encounter_index,
		"return_region": _player_data().current_region,
		"return_location": _player_data().current_location,
		"return_position": player.global_position,
		"environment_id": MINE_BATTLE_ENVIRONMENT if _is_mine_start_map else "town",
		"suppressed_trigger_type": suppressed_trigger_type,
		"suppressed_trigger_index": encounter_index,
		"fade_from_black": true,
	}

func _launch_battle(battle_payload: Dictionary) -> void:
	_launch_battle_async(battle_payload)

func _launch_battle_async(battle_payload: Dictionary) -> void:
	if _state_transition_locked:
		return

	_state_transition_locked = true
	player.velocity = Vector2.ZERO

	var screen_fader = _scene_manager().get_screen_fader()
	if screen_fader != null:
		var fade_tween: Tween = screen_fader.fade_to_black(0.35)
		await fade_tween.finished

	if not _scene_manager().change_state("battle", battle_payload):
		_state_transition_locked = false
		if screen_fader != null:
			screen_fader.fade_from_black(0.35)

func _load_ui_textures() -> void:
	_panel_texture = _load_texture(UI_PANEL_TEXTURE_PATH)
	_button_texture = _load_texture(UI_BUTTON_TEXTURE_PATH)
	_button_pressed_texture = _load_texture(UI_BUTTON_PRESSED_TEXTURE_PATH)
	_button_disabled_texture = _load_texture(UI_BUTTON_DISABLED_TEXTURE_PATH)

func _load_texture(resource_path: String) -> Texture2D:
	var image := Image.load_from_file(resource_path)
	if image == null or image.is_empty():
		return null
	return ImageTexture.create_from_image(image)

func _make_panel_style(texture: Texture2D) -> StyleBox:
	if texture == null:
		var fallback := StyleBoxFlat.new()
		fallback.bg_color = Color(0.17, 0.13, 0.11, 0.94)
		fallback.border_color = Color(0.36, 0.27, 0.21, 1.0)
		fallback.set_border_width_all(2)
		fallback.set_corner_radius_all(4)
		return fallback

	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = 14
	style.texture_margin_top = 14
	style.texture_margin_right = 14
	style.texture_margin_bottom = 14
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	return style

func _make_button_style(texture: Texture2D) -> StyleBox:
	if texture == null:
		var fallback := StyleBoxFlat.new()
		fallback.bg_color = Color(0.29, 0.22, 0.18, 1.0)
		fallback.border_color = Color(0.48, 0.36, 0.28, 1.0)
		fallback.set_border_width_all(2)
		fallback.set_corner_radius_all(3)
		fallback.content_margin_left = 6
		fallback.content_margin_right = 6
		fallback.content_margin_top = 4
		fallback.content_margin_bottom = 4
		return fallback

	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = 16
	style.texture_margin_top = 8
	style.texture_margin_right = 16
	style.texture_margin_bottom = 8
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	return style

func _sample_town_tile(layer: int, sample_cell: Vector2i) -> Dictionary:
	return {
		"source_id": ground_map.get_cell_source_id(layer, sample_cell),
		"atlas_coords": ground_map.get_cell_atlas_coords(layer, sample_cell),
		"alternative_tile": ground_map.get_cell_alternative_tile(layer, sample_cell),
	}

func _set_sampled_tile(layer: int, cell: Vector2i, tile_data: Dictionary) -> void:
	var source_id := int(tile_data.get("source_id", -1))
	if source_id == -1:
		return
	ground_map.set_cell(
		layer,
		cell,
		source_id,
		tile_data.get("atlas_coords", Vector2i.ZERO),
		int(tile_data.get("alternative_tile", 0))
	)

func _make_signpost_texture() -> Texture2D:
	var image := Image.create(24, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))

	for y in range(8, 26):
		for x in range(10, 14):
			image.set_pixel(x, y, Color(0.36, 0.23, 0.13, 1.0))

	for y in range(4, 13):
		for x in range(3, 21):
			image.set_pixel(x, y, Color(0.56, 0.43, 0.25, 1.0))

	for x in range(5, 19):
		image.set_pixel(x, 6, Color(0.74, 0.64, 0.44, 1.0))

	return ImageTexture.create_from_image(image)
