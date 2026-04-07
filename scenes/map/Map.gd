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
const MINE_HINT_TEXT := "Kobold Mine Entrance\nMove: WASD / Arrows\nB: Battle   H: HUD\nC: Cutscene   1: Pure   2: Mixed\n3: Social+Gold  4: Intel  0: Reset stats"

const FRONTIER_REGION := "frontier_village"
const TOWN_LOCATION := "starting_town"
const MINE_REGION := "kobold_mine"
const MINE_LOCATION := "mine_entry_chamber"
const MINE_COMMIT_FLAG := "mine_entry_commit_applied"

const MINE_MAP_SIZE := Vector2i(24, 16)
const MINE_ENTRY_SPAWN_CELL := Vector2i(12, 13)

const MINE_TERRAIN_SOURCE_ID := 0
const MINE_PROPS_SOURCE_ID := 1
const MINE_FLOOR_TILE := Vector2i(6, 0)
const MINE_FLOOR_VARIANT_TILE := Vector2i(6, 1)
const MINE_WALL_TILE := Vector2i(0, 0)
const MINE_PROP_BRAZIER_TILE := Vector2i(0, 0)
const MINE_PROP_CRATE_TILE := Vector2i(2, 0)
const MINE_PROP_TORCH_TILE := Vector2i(5, 0)

const MINE_TERRAIN_TEXTURE_PATH := "res://assets/art/tilesets/basic caves and dungeons 32x32 standard - v1.0/tiles/tiles-all-32x32.png"
const MINE_PROPS_TEXTURE_PATH := "res://assets/art/tilesets/basic caves and dungeons 32x32 standard - v1.0/assets/assets-all.png"

var _distance_since_step: float = 0.0
var _town_exit_trigger_armed := false
var _is_mine_start_map := false
var _town_tileset: TileSet

@onready var ground_map: TileMap = $GroundMap
@onready var world_collision: StaticBody2D = $WorldCollision
@onready var player: CharacterBody2D = $Player
@onready var map_camera: Camera2D = $Player/MapCamera
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var mine_spawn: Marker2D = $MineSpawn
@onready var town_exit_trigger: Area2D = $TownExitTrigger
@onready var hint_label: Label = $UI/HintLabel
@onready var town_exit_dialog: ConfirmationDialog = $UI/TownExitDialog

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

func _should_load_mine_start_map() -> bool:
	return _player_data().current_region == MINE_REGION

func _setup_town_map() -> void:
	_player_data().current_location = TOWN_LOCATION
	_player_data().current_region = FRONTIER_REGION

	if _town_tileset != null:
		ground_map.tile_set = _town_tileset

	hint_label.text = TOWN_HINT_TEXT
	player.global_position = player_spawn.global_position
	_wire_town_exit_prompt()

func _setup_mine_start_map() -> void:
	_player_data().current_location = MINE_LOCATION
	_player_data().current_region = MINE_REGION
	hint_label.text = MINE_HINT_TEXT

	_disable_town_only_content()
	_build_mine_layout()
	mine_spawn.position = ground_map.map_to_local(MINE_ENTRY_SPAWN_CELL)
	player.global_position = mine_spawn.global_position

func _disable_town_only_content() -> void:
	_town_exit_trigger_armed = false
	town_exit_dialog.hide()

	if is_instance_valid(town_exit_trigger):
		town_exit_trigger.monitoring = false

	for node_path in ["TownExitTrigger", "Triggers", "IntelNPC", "MoralChoiceNPC", "BookstoreNPC"]:
		var node := get_node_or_null(node_path)
		if node != null:
			node.queue_free()

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

func _build_mine_walkable_cells() -> Dictionary:
	var walkable := {}
	_mark_walkable_rect(walkable, Rect2i(8, 9, 8, 6))
	_mark_walkable_rect(walkable, Rect2i(11, 4, 2, 5))
	_mark_walkable_rect(walkable, Rect2i(8, 1, 8, 3))
	return walkable

func _mark_walkable_rect(walkable: Dictionary, rect: Rect2i) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			walkable[Vector2i(x, y)] = true

func _stamp_mine_props() -> void:
	ground_map.set_cell(3, Vector2i(10, 10), MINE_PROPS_SOURCE_ID, MINE_PROP_CRATE_TILE)
	ground_map.set_cell(3, Vector2i(13, 10), MINE_PROPS_SOURCE_ID, MINE_PROP_CRATE_TILE)
	ground_map.set_cell(3, Vector2i(10, 3), MINE_PROPS_SOURCE_ID, MINE_PROP_BRAZIER_TILE)
	ground_map.set_cell(3, Vector2i(13, 3), MINE_PROPS_SOURCE_ID, MINE_PROP_TORCH_TILE)

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
	for atlas_coord in [MINE_PROP_BRAZIER_TILE, MINE_PROP_CRATE_TILE, MINE_PROP_TORCH_TILE]:
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
	if _is_hud_open() or _is_dialogue_active() or town_exit_dialog.visible:
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
	town_exit_dialog.popup_centered_clamped(Vector2i(360, 140), 0.85)

func _on_town_exit_confirmed() -> void:
	_apply_mine_commit_stats_once()
	_scene_manager().change_state("cutscene")

func _on_town_exit_canceled() -> void:
	player.velocity = Vector2.ZERO

func _toggle_hud() -> void:
	var hud = _get_spike_hud()
	if hud != null:
		hud.toggle()

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

func _player_data() -> Node:
	return get_node("/root/PlayerData")

func _scene_manager() -> Node:
	return get_node("/root/SceneManager")

func _signal_bus() -> Node:
	return get_node("/root/SignalBus")
