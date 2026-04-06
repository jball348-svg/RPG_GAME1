extends Node2D

const TILE_SIZE := 32
const MAP_SIZE_TILES := Vector2i(30, 20)
const WORLD_SIZE := Vector2(MAP_SIZE_TILES.x * TILE_SIZE, MAP_SIZE_TILES.y * TILE_SIZE)
const INNER_MARGIN := 16.0
const PLAYER_SIZE := Vector2(24.0, 24.0)
const MOVE_SPEED := 180.0
const STEP_DISTANCE := 24.0
const HINT_TEXT := "Starting Town Prototype\nMove: WASD / Arrows\nB: Battle   H: HUD\nC: Cutscene   1: Pure   2: Mixed"

const OUTDOOR_TILESET_TEXTURE_PATH := "res://assets/art/tilesets/EPIC RPG World Pack - [FREE Demo]Grass Land 2.0-REWORK/Tilesets and props/Tilesets and props Demo.png"
const OUTDOOR_SOURCE_ID := 0
const OUTDOOR_COLUMNS := 26

const LAYER_BASE_GRASS := 0
const LAYER_EXTRA_SHADE := 1
const LAYER_ROADS := 2
const LAYER_CLIFFS := 3
const LAYER_PROPS := 4

const GRASS_BASE_GIDS := [41, 42, 43, 67, 68, 69]
const GRASS_SHADE_GIDS := [47, 48, 49, 72, 73, 74, 98, 99, 124, 125, 126, 127, 150, 151, 152, 153]
const ROAD_GIDS := [341, 342, 343, 367, 368, 369]
const LOT_GIDS := [392, 393, 394, 395]

const TREE_TEMPLATE := [
	[269, 270, 271, 272],
	[295, 296, 297, 298],
	[321, 322, 323, 324],
	[347, 348, 349, 350],
	[373, 374, 375, 376],
	[399, 400, 401, 402],
]

const BUSH_TEMPLATE := [
	[449, 450, 451],
	[475, 476, 477],
]

const WELL_TEMPLATE := [
	[397, 398],
	[423, 424],
]

const MINE_ENTRANCE_TEMPLATE := [
	[0, 0, 0, 53, 211, 159, 30, 0],
	[0, 0, 53, 54, 81, 35, 36, 37],
	[0, 0, 79, 81, 81, 61, 62, 63],
	[0, 0, 209, 107, 107, 87, 88, 89],
	[0, 28, 54, 81, 55, 108, 109, 0],
	[0, 209, 82, 81, 80, 184, 0, 0],
	[0, 132, 106, 108, 186, 134, 0, 0],
	[0, 0, 132, 109, 0, 0, 0, 0],
]

const LOTS: Array[Rect2i] = [
	Rect2i(3, 3, 8, 4),
	Rect2i(18, 3, 8, 4),
	Rect2i(3, 13, 8, 4),
	Rect2i(18, 13, 8, 4),
	Rect2i(12, 7, 6, 5),
]

const TREE_POSITIONS: Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(6, 0),
	Vector2i(12, 0),
	Vector2i(18, 0),
	Vector2i(24, 0),
	Vector2i(0, 7),
	Vector2i(26, 7),
	Vector2i(0, 14),
	Vector2i(6, 14),
	Vector2i(12, 14),
]

const BUSH_POSITIONS: Array[Vector2i] = [
	Vector2i(10, 2),
	Vector2i(16, 2),
	Vector2i(1, 10),
	Vector2i(26, 10),
	Vector2i(12, 17),
	Vector2i(20, 17),
]

const MINE_ENTRANCE_ORIGIN := Vector2i(21, 11)

var _player_position: Vector2 = Vector2(480.0, 448.0)
var _distance_since_step: float = 0.0
var _outdoor_tileset_texture: Texture2D = null

@onready var ground_map: TileMap = $GroundMap
@onready var map_camera: Camera2D = $MapCamera
@onready var hint_label: Label = $UI/HintLabel

func _ready() -> void:
	PlayerData.current_location = "starting_town"
	PlayerData.current_region = "frontier_village"
	hint_label.text = HINT_TEXT
	if not _configure_ground_map():
		return
	_build_starting_town_layout()
	_configure_map_camera()
	map_camera.global_position = _player_position
	queue_redraw()

func _load_outdoor_tileset_texture() -> Texture2D:
	if _outdoor_tileset_texture != null:
		return _outdoor_tileset_texture

	var absolute_path := ProjectSettings.globalize_path(OUTDOOR_TILESET_TEXTURE_PATH)
	var image := Image.load_from_file(absolute_path)
	if image == null or image.is_empty():
		return null

	_outdoor_tileset_texture = ImageTexture.create_from_image(image)
	return _outdoor_tileset_texture

func _configure_ground_map() -> bool:
	var outdoor_texture := _load_outdoor_tileset_texture()
	if outdoor_texture == null:
		push_error("Unable to load outdoor tileset texture: %s" % OUTDOOR_TILESET_TEXTURE_PATH)
		return false

	var tile_set := TileSet.new()
	var outdoor_source := TileSetAtlasSource.new()
	outdoor_source.texture = outdoor_texture
	outdoor_source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)

	var texture_size: Vector2i = outdoor_texture.get_size()
	var atlas_width := int(texture_size.x / TILE_SIZE)
	var atlas_height := int(texture_size.y / TILE_SIZE)
	for y in range(atlas_height):
		for x in range(atlas_width):
			outdoor_source.create_tile(Vector2i(x, y))

	tile_set.add_source(outdoor_source, OUTDOOR_SOURCE_ID)
	ground_map.tile_set = tile_set

	while ground_map.get_layers_count() < 5:
		ground_map.add_layer(ground_map.get_layers_count())

	ground_map.set_layer_name(LAYER_BASE_GRASS, "BaseGrass")
	ground_map.set_layer_name(LAYER_EXTRA_SHADE, "ExtraShade")
	ground_map.set_layer_name(LAYER_ROADS, "Roads")
	ground_map.set_layer_name(LAYER_CLIFFS, "Cliffs")
	ground_map.set_layer_name(LAYER_PROPS, "Props")
	return true

func _configure_map_camera() -> void:
	map_camera.limit_left = 0
	map_camera.limit_top = 0
	map_camera.limit_right = int(WORLD_SIZE.x)
	map_camera.limit_bottom = int(WORLD_SIZE.y)

func _build_starting_town_layout() -> void:
	for layer_index in range(ground_map.get_layers_count()):
		ground_map.clear_layer(layer_index)

	_fill_base_grass()
	_paint_shade_patch(Rect2i(2, 2, 6, 4))
	_paint_shade_patch(Rect2i(21, 3, 7, 5))
	_paint_shade_patch(Rect2i(2, 15, 6, 4))

	_paint_road_rect(Rect2i(0, 9, MAP_SIZE_TILES.x, 2))
	_paint_road_rect(Rect2i(14, 1, 2, MAP_SIZE_TILES.y - 1))
	_paint_road_rect(Rect2i(21, 14, MAP_SIZE_TILES.x - 21, 2))
	_paint_road_rect(Rect2i(7, 6, 8, 2))
	_paint_road_rect(Rect2i(15, 6, 8, 2))

	for lot in LOTS:
		_paint_lot_rect(lot)

	for tree_position in TREE_POSITIONS:
		_stamp_template(LAYER_PROPS, tree_position, TREE_TEMPLATE)

	for bush_position in BUSH_POSITIONS:
		_stamp_template(LAYER_PROPS, bush_position, BUSH_TEMPLATE)

	_stamp_template(LAYER_PROPS, Vector2i(14, 10), WELL_TEMPLATE)
	_stamp_template(LAYER_CLIFFS, MINE_ENTRANCE_ORIGIN, MINE_ENTRANCE_TEMPLATE)

func _fill_base_grass() -> void:
	for y in range(MAP_SIZE_TILES.y):
		for x in range(MAP_SIZE_TILES.x):
			var cell := Vector2i(x, y)
			var base_gid: int = GRASS_BASE_GIDS[(x * 17 + y * 31) % GRASS_BASE_GIDS.size()]
			_set_outdoor_gid(LAYER_BASE_GRASS, cell, base_gid)

			if ((x * 5) + (y * 7)) % 11 == 0:
				var shade_gid: int = GRASS_SHADE_GIDS[(x * 13 + y * 19) % GRASS_SHADE_GIDS.size()]
				_set_outdoor_gid(LAYER_EXTRA_SHADE, cell, shade_gid)

func _paint_shade_patch(area: Rect2i) -> void:
	for y in range(area.position.y, area.end.y):
		for x in range(area.position.x, area.end.x):
			var cell := Vector2i(x, y)
			var shade_gid: int = GRASS_SHADE_GIDS[(x + (y * 3)) % GRASS_SHADE_GIDS.size()]
			_set_outdoor_gid(LAYER_EXTRA_SHADE, cell, shade_gid)

func _paint_road_rect(area: Rect2i) -> void:
	for y in range(area.position.y, area.end.y):
		for x in range(area.position.x, area.end.x):
			var cell := Vector2i(x, y)
			var road_gid: int = ROAD_GIDS[(x + (y * 2)) % ROAD_GIDS.size()]
			_set_outdoor_gid(LAYER_ROADS, cell, road_gid)

func _paint_lot_rect(area: Rect2i) -> void:
	for y in range(area.position.y, area.end.y):
		for x in range(area.position.x, area.end.x):
			var cell := Vector2i(x, y)
			var lot_gid: int = LOT_GIDS[(x * 3 + y) % LOT_GIDS.size()]
			_set_outdoor_gid(LAYER_ROADS, cell, lot_gid)

func _stamp_template(layer_index: int, origin: Vector2i, template: Array) -> void:
	for row_index in range(template.size()):
		var row: Array = template[row_index]
		for column_index in range(row.size()):
			var gid: int = row[column_index]
			if gid <= 0:
				continue

			var cell := origin + Vector2i(column_index, row_index)
			_set_outdoor_gid(layer_index, cell, gid)

func _set_outdoor_gid(layer_index: int, cell: Vector2i, gid: int) -> void:
	if gid <= 0 or not _is_inside_map(cell):
		return

	ground_map.set_cell(layer_index, cell, OUTDOOR_SOURCE_ID, _atlas_from_gid(gid))

func _atlas_from_gid(gid: int) -> Vector2i:
	var tile_id := gid - 1
	return Vector2i(tile_id % OUTDOOR_COLUMNS, int(tile_id / OUTDOOR_COLUMNS))

func _is_inside_map(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < MAP_SIZE_TILES.x and cell.y < MAP_SIZE_TILES.y

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
	map_camera.global_position = _player_position
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
	var mine_marker := Vector2((MINE_ENTRANCE_ORIGIN.x + 4) * TILE_SIZE, (MINE_ENTRANCE_ORIGIN.y + 4) * TILE_SIZE)
	draw_circle(mine_marker, 8.0, Color(0.12, 0.08, 0.06, 0.8))
	draw_arc(mine_marker, 9.5, 0.0, TAU, 24, Color(0.72, 0.61, 0.38, 0.9), 2.0, true)

	var player_rect := Rect2(_player_position - (PLAYER_SIZE * 0.5), PLAYER_SIZE)
	draw_rect(player_rect, Color(0.84, 0.34, 0.20), true)
	draw_rect(player_rect, Color(0.08, 0.05, 0.03), false, 2.0)
