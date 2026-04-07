extends Node2D

const MOVE_SPEED := 180.0
const STEP_DISTANCE := 24.0
const PLAYER_HALF_EXTENTS := Vector2(10.0, 10.0)
const DEFAULT_BLOCKING_TILE_LAYERS: Array[int] = [2, 3]
const MINE_BLOCKING_TILE_LAYERS: Array[int] = [2]
const OVERLAY_BLOCKING_LAYER := 4
const ROAD_LAYER := 1
const OVERLAY_BLOCK_BOTTOM_ROWS := 4
const TOWN_EXIT_PROMPT_ID := "town_exit"
const TOWN_EXIT_PROMPT_TITLE := "Leave for the Mine?"
const TOWN_EXIT_PROMPT_CONFIRM_TEXT := "Continue"
const TOWN_EXIT_PROMPT_CANCEL_TEXT := "Stay"
const TOWN_EXIT_PROMPT_TEXT := "You prepare to leave for the mine. There is no turning back. Continue?"
const TOWN_HINT_TEXT := "Frontier Hamlet\nMove: WASD / Arrows\nB: Battle   H: HUD\nC: Cutscene   1: Pure   2: Mixed\n3: Social+Gold  4: Intel  0: Reset stats"
const MINE_HINT_BASE_TEXT := "Kobold Mine\nMove: WASD / Arrows\nB: Battle   H: HUD\nC: Cutscene   1: Pure   2: Mixed\n3: Social+Gold  4: Intel  0: Reset stats"
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
const MINE_BATTLE_ENVIRONMENT := "mine"
const MINE_COMMIT_FLAG := "mine_entry_commit_applied"
const MINE_ENCOUNTER_PROGRESS_FLAG := "mine_encounter_progress"
const MINE_BOSS_READY_FLAG := "mine_boss_ready"
const MINE_BOSS_RESOLVED_FLAG := "mine_boss_resolved"
const MINE_EXIT_UNLOCKED_FLAG := "mine_exit_unlocked"
const MINE_CLEARED_FLAG := "mine_cleared"
const MINE_REGULAR_ENCOUNTER_COUNT := 3
const BATTLE_KIND_STANDARD := "standard"
const BATTLE_KIND_BOSS_PLACEHOLDER := "boss_placeholder"
const BATTLE_KIND_DEBUG := "debug"
const SUPPRESSED_TRIGGER_ENCOUNTER := "encounter"
const SUPPRESSED_TRIGGER_BOSS := "boss"

const MINE_MAP_SIZE := Vector2i(42, 30)
const MINE_ENTRY_SPAWN_CELL := Vector2i(21, 27)
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
var _town_tileset: TileSet
var _mine_trigger_root: Node2D
var _mine_encounter_areas: Array[Area2D] = []
var _mine_status_text := ""
var _incoming_state_payload: Dictionary = {}
var _mine_boss_area: Area2D
var _suppressed_mine_trigger_type := ""
var _suppressed_mine_trigger_index := -1
var _battle_transition_locked := false

@onready var ground_map: TileMap = $GroundMap
@onready var world_collision: StaticBody2D = $WorldCollision
@onready var player: CharacterBody2D = $Player
@onready var map_camera: Camera2D = $Player/MapCamera
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var mine_spawn: Marker2D = $MineSpawn
@onready var town_exit_trigger: Area2D = $TownExitTrigger
@onready var hint_backdrop: ColorRect = $UI/HintBackdrop
@onready var hint_label: Label = $UI/HintLabel

func _ready() -> void:
	_town_tileset = ground_map.tile_set
	_incoming_state_payload = _scene_manager().consume_state_payload()
	_is_mine_start_map = _should_load_mine_start_map()

	if _is_mine_start_map:
		_setup_mine_start_map()
	else:
		_setup_town_map()

	_build_world_collision()
	map_camera.make_current()
	_configure_map_camera()
	_layout_map_ui()
	_connect_overlay_signals()

	if not get_viewport().size_changed.is_connected(_on_viewport_size_changed):
		get_viewport().size_changed.connect(_on_viewport_size_changed)

	_apply_incoming_state_payload()

func _should_load_mine_start_map() -> bool:
	return _player_data().current_region == MINE_REGION

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
	player.global_position = _resolve_return_position(player_spawn.global_position)
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
	player.global_position = _resolve_return_position(mine_spawn.global_position)
	_update_mine_hint()

func _disable_town_only_content() -> void:
	_town_exit_trigger_armed = false
	_hide_prompt_modal()
	_battle_transition_locked = false
	_mine_boss_area = null
	_clear_suppressed_mine_trigger()

	if is_instance_valid(town_exit_trigger):
		town_exit_trigger.monitoring = false

	for node_path in ["TownExitTrigger", "Triggers", "IntelNPC", "MoralChoiceNPC", "BookstoreNPC"]:
		var node := get_node_or_null(node_path)
		if node != null:
			node.queue_free()

	if is_instance_valid(_mine_trigger_root):
		_mine_trigger_root.queue_free()
		_mine_trigger_root = null
		_mine_encounter_areas.clear()

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
		var prop_cells: Array[Vector2i] = spec["cells"]
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

func _resolve_return_position(default_position: Vector2) -> Vector2:
	var return_position = _incoming_state_payload.get("return_position", default_position)
	if return_position is Vector2:
		return return_position
	return default_position

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
		MINE_EXIT_PROMPT_ID:
			_on_mine_exit_confirmed()

func _on_prompt_modal_canceled(prompt_id: String) -> void:
	match prompt_id:
		TOWN_EXIT_PROMPT_ID:
			_on_town_exit_canceled()
		MINE_EXIT_PROMPT_ID:
			_on_mine_exit_canceled()

func _on_overlay_state_changed(_unused: Variant = null) -> void:
	if _is_prompt_open():
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
		if encounter_index >= progress:
			break
		if is_instance_valid(_mine_encounter_areas[encounter_index]):
			_mine_encounter_areas[encounter_index].monitoring = false

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

	if _battle_transition_locked:
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

	if _battle_transition_locked:
		return

	if _suppressed_mine_trigger_type == SUPPRESSED_TRIGGER_BOSS:
		return

	if not _player_data().get_flag(MINE_BOSS_READY_FLAG, false):
		_set_mine_status(MINE_BOSS_LOCKED_TEXT)
		return

	if _player_data().get_flag(MINE_BOSS_RESOLVED_FLAG, false):
		return

	_launch_battle(_build_battle_payload(BATTLE_KIND_BOSS_PLACEHOLDER, -1, SUPPRESSED_TRIGGER_BOSS))

func _on_mine_boss_trigger_body_exited(body: Node) -> void:
	if body != player:
		return

	if _suppressed_mine_trigger_type == SUPPRESSED_TRIGGER_BOSS:
		_clear_suppressed_mine_trigger()

func _on_mine_exit_trigger_body_entered(body: Node) -> void:
	if body != player:
		return

	if _is_prompt_open():
		return

	if not _player_data().get_flag(MINE_EXIT_UNLOCKED_FLAG, false):
		_set_mine_status(MINE_EXIT_LOCKED_TEXT)
		return

	player.velocity = Vector2.ZERO
	_show_prompt_modal(
		MINE_EXIT_PROMPT_ID,
		MINE_EXIT_PROMPT_TITLE,
		MINE_EXIT_PROMPT_TEXT,
		MINE_EXIT_PROMPT_CONFIRM_TEXT,
		MINE_EXIT_PROMPT_CANCEL_TEXT
	)

func _on_mine_exit_confirmed() -> void:
	_player_data().set_flag(MINE_CLEARED_FLAG, true)
	_player_data().current_location = MINE_EXIT_LOCATION
	_set_mine_status("Mine progression recorded as cleared. Stage 7 transition remains pending.")
	_set_debug_panel_suppressed(false)
	_update_mine_hint()

func _on_mine_exit_canceled() -> void:
	player.velocity = Vector2.ZERO
	_set_debug_panel_suppressed(false)
	_update_map_overlay_visibility()

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
	_update_map_overlay_visibility()

func _update_map_overlay_visibility() -> void:
	var show_hint := not _is_hud_open() and not _is_dialogue_active() and not _is_prompt_open()
	hint_backdrop.visible = show_hint
	hint_label.visible = show_hint

func _on_viewport_size_changed() -> void:
	_layout_map_ui()

func _unhandled_input(event: InputEvent) -> void:
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

	if event.is_action_pressed("debug_cutscene"):
		get_viewport().set_input_as_handled()
		_scene_manager().change_state("cutscene")
		return

	if event.is_action_pressed("debug_battle"):
		get_viewport().set_input_as_handled()
		_launch_battle(_build_battle_payload(BATTLE_KIND_DEBUG, -1, ""))

func _physics_process(delta: float) -> void:
	if _is_hud_open() or _is_dialogue_active() or _is_prompt_open():
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
	_scene_manager().change_state("cutscene")

func _on_town_exit_canceled() -> void:
	player.velocity = Vector2.ZERO
	_set_debug_panel_suppressed(false)
	_update_map_overlay_visibility()

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
	if _battle_transition_locked:
		return

	_battle_transition_locked = true
	player.velocity = Vector2.ZERO

	var screen_fader = _scene_manager().get_screen_fader()
	if screen_fader != null:
		var fade_tween: Tween = screen_fader.fade_to_black(0.35)
		await fade_tween.finished

	if not _scene_manager().change_state("battle", battle_payload):
		_battle_transition_locked = false
		if screen_fader != null:
			screen_fader.fade_from_black(0.35)
