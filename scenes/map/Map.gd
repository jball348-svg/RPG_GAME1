extends Node2D

const MOVE_SPEED := 180.0
const STEP_DISTANCE := 24.0
const PLAYER_HALF_EXTENTS := Vector2(10.0, 10.0)
const BLOCKING_TILE_LAYERS: Array[int] = [2, 3]
const OVERLAY_BLOCKING_LAYER := 4
const ROAD_LAYER := 1
const OVERLAY_BLOCK_BOTTOM_ROWS := 4
const TOWN_EXIT_PROMPT_TEXT := "You prepare to leave for the mine. There is no turning back. Continue?"
const TOWN_HINT_TEXT := "Frontier Hamlet\nMove: WASD / Arrows\nB: Battle   H: HUD\nC: Cutscene   1: Pure   2: Mixed\n3: Social+Gold  4: Intel  0: Reset stats"
const MINE_HINT_BASE_TEXT := "Kobold Mine\nMove: WASD / Arrows\nB: Battle   H: HUD\nC: Cutscene   1: Pure   2: Mixed\n3: Social+Gold  4: Intel  0: Reset stats"
const MINE_BOSS_LOCKED_TEXT := "A heavy ward blocks the top shaft. Clear earlier encounter rooms first."
const MINE_EXIT_LOCKED_TEXT := "The mine exit is sealed. Resolve the boss room first."
const MINE_EXIT_PROMPT_TEXT := "Leave the mine? Stage 7 transition is still pending, but this will mark mine progression as cleared."

const FRONTIER_REGION := "frontier_village"
const TOWN_LOCATION := "starting_town"
const MINE_REGION := "kobold_mine"
const MINE_LOCATION := "mine_entry_chamber"
const MINE_EXIT_LOCATION := "mine_exit_gate"
const MINE_COMMIT_FLAG := "mine_entry_commit_applied"
const MINE_ENCOUNTER_PROGRESS_FLAG := "mine_encounter_progress"
const MINE_BOSS_READY_FLAG := "mine_boss_ready"
const MINE_BOSS_RESOLVED_FLAG := "mine_boss_resolved"
const MINE_EXIT_UNLOCKED_FLAG := "mine_exit_unlocked"
const MINE_CLEARED_FLAG := "mine_cleared"

const MINE_MAP_SIZE := Vector2i(42, 30)
const MINE_ENTRY_SPAWN_CELL := Vector2i(21, 27)
const MINE_ENCOUNTER_LABELS: PackedStringArray = [
	"Collapsed Hall",
	"Western Den",
	"Eastern Den",
	"Antechamber",
]
const MINE_ENCOUNTER_RECTS: Array[Rect2i] = [
	Rect2i(19, 18, 4, 4),
	Rect2i(6, 10, 4, 4),
	Rect2i(32, 10, 4, 4),
	Rect2i(17, 5, 8, 2),
]
const MINE_BOSS_TRIGGER_RECT := Rect2i(16, 1, 10, 3)
const MINE_EXIT_TRIGGER_RECT := Rect2i(37, 1, 2, 3)
const MINE_EXIT_GATE_CELLS: Array[Vector2i] = [
	Vector2i(34, 2),
	Vector2i(34, 3),
	Vector2i(35, 2),
	Vector2i(35, 3),
]

const MINE_TERRAIN_SOURCE_ID := 0
const MINE_PROPS_SOURCE_ID := 1
const MINE_FLOOR_TILE := Vector2i(6, 0)
const MINE_FLOOR_VARIANT_TILE := Vector2i(6, 1)
const MINE_WALL_TILE := Vector2i(0, 0)
const MINE_PROP_BRAZIER_TILE := Vector2i(0, 0)
const MINE_PROP_STALAGMITE_TILE := Vector2i(0, 1)
const MINE_PROP_ROCK_CLUSTER_A_TILE := Vector2i(1, 1)
const MINE_PROP_ROCK_CLUSTER_B_TILE := Vector2i(3, 1)
const MINE_PROP_BOULDER_TILE := Vector2i(1, 2)
const MINE_PROP_BOULDER_WIDE_TILE := Vector2i(3, 2)
const MINE_PROP_CRATE_TILE := Vector2i(2, 0)
const MINE_PROP_TORCH_TILE := Vector2i(5, 0)

const MINE_TERRAIN_TEXTURE_PATH := "res://assets/art/tilesets/basic caves and dungeons 32x32 standard - v1.0/tiles/tiles-all-32x32.png"
const MINE_PROPS_TEXTURE_PATH := "res://assets/art/tilesets/basic caves and dungeons 32x32 standard - v1.0/assets/assets-all.png"

var _distance_since_step: float = 0.0
var _town_exit_trigger_armed := false
var _is_mine_start_map := false
var _town_tileset: TileSet
var _mine_trigger_root: Node2D
var _mine_encounter_areas: Array[Area2D] = []
var _mine_status_text := ""

@onready var ground_map: TileMap = $GroundMap
@onready var world_collision: StaticBody2D = $WorldCollision
@onready var player: CharacterBody2D = $Player
@onready var map_camera: Camera2D = $Player/MapCamera
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var mine_spawn: Marker2D = $MineSpawn
@onready var town_exit_trigger: Area2D = $TownExitTrigger
@onready var hint_backdrop: ColorRect = $UI/HintBackdrop
@onready var hint_label: Label = $UI/HintLabel
@onready var town_exit_dialog: ConfirmationDialog = $UI/TownExitDialog
@onready var mine_exit_dialog: ConfirmationDialog = $UI/MineExitDialog

func _ready() -> void:
	_town_tileset = ground_map.tile_set
	_is_mine_start_map = _should_load_mine_start_map()

	if _is_mine_start_map:
		_setup_mine_start_map()
	else:
		_setup_town_map()

	_build_world_collision()
	map_camera.make_current()
	_configure_map_camera()
	_layout_map_ui()

	if not get_viewport().size_changed.is_connected(_on_viewport_size_changed):
		get_viewport().size_changed.connect(_on_viewport_size_changed)

func _should_load_mine_start_map() -> bool:
	return _player_data().current_region == MINE_REGION

func _setup_town_map() -> void:
	_player_data().current_location = TOWN_LOCATION
	_player_data().current_region = FRONTIER_REGION
	_mine_status_text = ""

	if _town_tileset != null:
		ground_map.tile_set = _town_tileset

	hint_label.text = TOWN_HINT_TEXT
	player.global_position = player_spawn.global_position
	_wire_town_exit_prompt()

func _setup_mine_start_map() -> void:
	if not _player_data().current_location.begins_with("mine_"):
		_player_data().current_location = MINE_LOCATION
	_player_data().current_region = MINE_REGION
	_mine_status_text = ""

	_disable_town_only_content()
	_build_mine_layout()
	_setup_mine_triggers()
	_wire_mine_exit_prompt()
	_restore_mine_progress_state()
	mine_spawn.position = ground_map.map_to_local(MINE_ENTRY_SPAWN_CELL)
	player.global_position = mine_spawn.global_position
	_update_mine_hint()

func _disable_town_only_content() -> void:
	_town_exit_trigger_armed = false
	town_exit_dialog.hide()
	mine_exit_dialog.hide()

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
			var floor_tile := MINE_FLOOR_VARIANT_TILE if (x + y) % 3 == 0 else MINE_FLOOR_TILE
			ground_map.set_cell(0, cell, MINE_TERRAIN_SOURCE_ID, floor_tile)

			if walkable_cells.has(cell):
				continue

			ground_map.set_cell(2, cell, MINE_TERRAIN_SOURCE_ID, MINE_WALL_TILE)

	_stamp_mine_props()
	_apply_mine_exit_gate_blocker()

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

func _stamp_prop_cells(atlas_coord: Vector2i, cells: Array[Vector2i]) -> void:
	for cell in cells:
		ground_map.set_cell(3, cell, MINE_PROPS_SOURCE_ID, atlas_coord)

func _stamp_mine_props() -> void:
	_stamp_prop_cells(MINE_PROP_CRATE_TILE, [Vector2i(19, 26), Vector2i(22, 26), Vector2i(38, 2)])
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

func _apply_mine_exit_gate_blocker() -> void:
	if _player_data().get_flag(MINE_EXIT_UNLOCKED_FLAG, false):
		_open_mine_exit_gate(false)
		return

	for cell in MINE_EXIT_GATE_CELLS:
		ground_map.set_cell(2, cell, MINE_TERRAIN_SOURCE_ID, MINE_WALL_TILE)

	ground_map.set_cell(3, Vector2i(34, 2), MINE_PROPS_SOURCE_ID, MINE_PROP_CRATE_TILE)
	ground_map.set_cell(3, Vector2i(35, 3), MINE_PROPS_SOURCE_ID, MINE_PROP_CRATE_TILE)
	ground_map.set_cell(3, Vector2i(35, 2), MINE_PROPS_SOURCE_ID, MINE_PROP_ROCK_CLUSTER_A_TILE)
	ground_map.set_cell(3, Vector2i(34, 3), MINE_PROPS_SOURCE_ID, MINE_PROP_BOULDER_TILE)

func _open_mine_exit_gate(rebuild_collision: bool = true) -> void:
	for cell in MINE_EXIT_GATE_CELLS:
		ground_map.erase_cell(2, cell)
		ground_map.erase_cell(3, cell)

	if rebuild_collision:
		_build_world_collision()

func _build_mine_tileset() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(32, 32)
	var terrain_texture := _load_png_texture(MINE_TERRAIN_TEXTURE_PATH)
	var props_texture := _load_png_texture(MINE_PROPS_TEXTURE_PATH)

	if terrain_texture == null or props_texture == null:
		return tile_set

	var terrain_source := TileSetAtlasSource.new()
	terrain_source.texture = terrain_texture
	terrain_source.texture_region_size = Vector2i(32, 32)
	for atlas_coord in [MINE_FLOOR_TILE, MINE_FLOOR_VARIANT_TILE, MINE_WALL_TILE]:
		terrain_source.create_tile(atlas_coord)
	tile_set.add_source(terrain_source, MINE_TERRAIN_SOURCE_ID)

	var props_source := TileSetAtlasSource.new()
	props_source.texture = props_texture
	props_source.texture_region_size = Vector2i(32, 32)
	for atlas_coord in [
		MINE_PROP_BRAZIER_TILE,
		MINE_PROP_STALAGMITE_TILE,
		MINE_PROP_ROCK_CLUSTER_A_TILE,
		MINE_PROP_ROCK_CLUSTER_B_TILE,
		MINE_PROP_BOULDER_TILE,
		MINE_PROP_BOULDER_WIDE_TILE,
		MINE_PROP_CRATE_TILE,
		MINE_PROP_TORCH_TILE,
	]:
		props_source.create_tile(atlas_coord)
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

	for layer_index in BLOCKING_TILE_LAYERS:
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
	town_exit_dialog.dialog_text = TOWN_EXIT_PROMPT_TEXT
	town_exit_dialog.hide()
	_town_exit_trigger_armed = false
	town_exit_trigger.monitoring = false
	_arm_town_exit_trigger()

	if not town_exit_trigger.body_entered.is_connected(_on_town_exit_trigger_body_entered):
		town_exit_trigger.body_entered.connect(_on_town_exit_trigger_body_entered)

	if not town_exit_dialog.confirmed.is_connected(_on_town_exit_confirmed):
		town_exit_dialog.confirmed.connect(_on_town_exit_confirmed)

	if not town_exit_dialog.canceled.is_connected(_on_town_exit_canceled):
		town_exit_dialog.canceled.connect(_on_town_exit_canceled)

func _wire_mine_exit_prompt() -> void:
	mine_exit_dialog.dialog_text = MINE_EXIT_PROMPT_TEXT
	mine_exit_dialog.hide()

	if not mine_exit_dialog.confirmed.is_connected(_on_mine_exit_confirmed):
		mine_exit_dialog.confirmed.connect(_on_mine_exit_confirmed)

	if not mine_exit_dialog.canceled.is_connected(_on_mine_exit_canceled):
		mine_exit_dialog.canceled.connect(_on_mine_exit_canceled)

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

	for encounter_index in range(MINE_ENCOUNTER_RECTS.size()):
		var area := _create_mine_trigger_area(
			"EncounterTrigger%d" % (encounter_index + 1),
			MINE_ENCOUNTER_RECTS[encounter_index]
		)
		area.body_entered.connect(_on_mine_encounter_trigger_body_entered.bind(encounter_index))
		_mine_encounter_areas.append(area)

	var boss_area := _create_mine_trigger_area("BossTrigger", MINE_BOSS_TRIGGER_RECT)
	boss_area.body_entered.connect(_on_mine_boss_trigger_body_entered)

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

	if progress >= MINE_ENCOUNTER_RECTS.size():
		_player_data().set_flag(MINE_BOSS_READY_FLAG, true)

	if _player_data().get_flag(MINE_BOSS_RESOLVED_FLAG, false):
		_player_data().set_flag(MINE_EXIT_UNLOCKED_FLAG, true)
		_open_mine_exit_gate(false)

func _mine_encounter_progress() -> int:
	return clampi(int(_player_data().get_flag(MINE_ENCOUNTER_PROGRESS_FLAG, 0)), 0, MINE_ENCOUNTER_RECTS.size())

func _on_mine_encounter_trigger_body_entered(body: Node, encounter_index: int) -> void:
	if body != player:
		return

	var progress := _mine_encounter_progress()
	if encounter_index < progress:
		return

	if encounter_index > progress:
		_set_mine_status("A collapsed branch blocks this route. Clear earlier encounter rooms first.")
		return

	var new_progress := progress + 1
	_player_data().set_flag(MINE_ENCOUNTER_PROGRESS_FLAG, new_progress)
	_set_mine_status("Encounter %d/%d mapped: %s" % [
		new_progress,
		MINE_ENCOUNTER_RECTS.size(),
		MINE_ENCOUNTER_LABELS[encounter_index],
	])

	if encounter_index < _mine_encounter_areas.size() and is_instance_valid(_mine_encounter_areas[encounter_index]):
		_mine_encounter_areas[encounter_index].monitoring = false

	if new_progress >= MINE_ENCOUNTER_RECTS.size() and not _player_data().get_flag(MINE_BOSS_READY_FLAG, false):
		_player_data().set_flag(MINE_BOSS_READY_FLAG, true)
		_set_mine_status("Boss chamber unlocked. Advance up the top shaft.")

	_update_mine_hint()

func _on_mine_boss_trigger_body_entered(body: Node) -> void:
	if body != player:
		return

	if not _player_data().get_flag(MINE_BOSS_READY_FLAG, false):
		_set_mine_status(MINE_BOSS_LOCKED_TEXT)
		return

	if _player_data().get_flag(MINE_BOSS_RESOLVED_FLAG, false):
		return

	_player_data().set_flag(MINE_BOSS_RESOLVED_FLAG, true)
	_player_data().set_flag(MINE_EXIT_UNLOCKED_FLAG, true)
	_open_mine_exit_gate()
	_set_mine_status("Boss room placeholder resolved. Exit tunnel is now open.")
	_update_mine_hint()

func _on_mine_exit_trigger_body_entered(body: Node) -> void:
	if body != player:
		return

	if mine_exit_dialog.visible:
		return

	if not _player_data().get_flag(MINE_EXIT_UNLOCKED_FLAG, false):
		_set_mine_status(MINE_EXIT_LOCKED_TEXT)
		return

	player.velocity = Vector2.ZERO
	_popup_confirmation_dialog(mine_exit_dialog, MINE_EXIT_PROMPT_TEXT)

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
	if progress < MINE_ENCOUNTER_RECTS.size():
		objective = "Objective: Clear encounter %d/%d (%s)." % [
			progress + 1,
			MINE_ENCOUNTER_RECTS.size(),
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
	var show_hint := not _is_hud_open() and not town_exit_dialog.visible and not mine_exit_dialog.visible
	hint_backdrop.visible = show_hint
	hint_label.visible = show_hint

func _on_viewport_size_changed() -> void:
	_layout_map_ui()

	if town_exit_dialog.visible:
		_popup_confirmation_dialog(town_exit_dialog, town_exit_dialog.dialog_text)

	if mine_exit_dialog.visible:
		_popup_confirmation_dialog(mine_exit_dialog, mine_exit_dialog.dialog_text)

func _dialog_size_for_viewport() -> Vector2i:
	var viewport_size := get_viewport_rect().size
	var width := int(clamp(viewport_size.x * 0.76, 280.0, 420.0))
	var height := int(clamp(viewport_size.y * 0.45, 120.0, 186.0))
	return Vector2i(width, height)

func _popup_confirmation_dialog(dialog: ConfirmationDialog, dialog_text: String) -> void:
	dialog.dialog_text = dialog_text
	dialog.popup_centered_clamped(_dialog_size_for_viewport(), 0.85)
	_set_debug_panel_suppressed(true)
	_update_map_overlay_visibility()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_hud"):
		get_viewport().set_input_as_handled()
		_toggle_hud()
		return

	if _is_hud_open():
		return

	if OS.is_debug_build():
		if event.is_action_pressed("set_path_pure"):
			get_viewport().set_input_as_handled()
			_player_data().set_chosen_path("pure")
			return

		if event.is_action_pressed("set_path_mixed"):
			get_viewport().set_input_as_handled()
			_player_data().set_chosen_path("mixed")
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
		_scene_manager().change_state("battle")

func _physics_process(delta: float) -> void:
	if _is_hud_open() or _is_dialogue_active() or town_exit_dialog.visible or mine_exit_dialog.visible:
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

	if town_exit_dialog.visible:
		return

	player.velocity = Vector2.ZERO
	_popup_confirmation_dialog(town_exit_dialog, TOWN_EXIT_PROMPT_TEXT)

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
