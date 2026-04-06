extends SceneTree

const TILE_SIZE := 32
const MAP_SIZE := Vector2i(40, 26)

const MAP_SCENE_PATH := "res://scenes/map/Map.tscn"
const TILESET_PATH := "res://scenes/map/TownTileset.tres"
const PREVIEW_PATH := "/tmp/stage1_town_preview.png"

const SAMPLE_TMX_PATH := "res://assets/art/tilesets/Pipoya RPG Tileset 32x32/SampleMap/samplemap.tmx"
const BASE_TEXTURE_PATH := "res://assets/art/tilesets/Pipoya RPG Tileset 32x32/[Base]BaseChip_pipo.png"
const GRASS_TEXTURE_PATH := "res://assets/art/tilesets/Pipoya RPG Tileset 32x32/SampleMap/[A]Grass_pipo.png"
const ADDWORK_TEXTURE_PATH := "res://assets/art/tilesets/Unorganized Parts/addwork.png"

const SOURCE_BASE := 0
const SOURCE_GRASS := 1
const SOURCE_ADDWORK := 2

const LAYER_GROUND := 0
const LAYER_ROAD := 1
const LAYER_BUILDINGS := 2
const LAYER_PROPS := 3
const LAYER_OVERLAY := 4

const SAMPLE_WIDTH := 60
const SAMPLE_HEIGHT := 60

const SAMPLE_GID_BASE_START := 577
const SAMPLE_GID_GRASS_START := 1641
const SAMPLE_GID_WATER_START := 2169

const BASE_COLUMNS := 8
const GRASS_COLUMNS := 8
const ADDWORK_COLUMNS := 12

const GROUND_GID := 577
const ROAD_GID := 581
const ROAD_ALT_GID := 582

const HALL_SRC := Rect2i(23, 15, 18, 14)
const BOOKSTORE_SRC := Rect2i(43, 37, 8, 9)
const FARM_SRC := Rect2i(0, 0, 12, 14)
const STALL_SRC := Rect2i(0, 20, 10, 12)
const NORTH_GATE_SRC := Rect2i(46, 36, 6, 4)

const TREE_CLUMPS := [
	{"src": Rect2i(0, 29, 8, 9), "dst": Vector2i(0, 16)},
	{"src": Rect2i(48, 16, 8, 8), "dst": Vector2i(32, 2)},
	{"src": Rect2i(19, 52, 11, 8), "dst": Vector2i(13, 18)},
	{"src": Rect2i(28, 9, 8, 6), "dst": Vector2i(0, 2)},
]

const ADDWORK_SIGNS := [
	{"atlas": Vector2i(3, 48), "cell": Vector2i(16, 11)},
	{"atlas": Vector2i(5, 48), "cell": Vector2i(17, 11)},
	{"atlas": Vector2i(4, 48), "cell": Vector2i(18, 3)},
	{"atlas": Vector2i(6, 48), "cell": Vector2i(20, 3)},
	{"atlas": Vector2i(7, 48), "cell": Vector2i(8, 14)},
]

const ADDWORK_GRIT := [
	{"atlas": Vector2i(9, 20), "cell": Vector2i(15, 4)},
	{"atlas": Vector2i(10, 20), "cell": Vector2i(22, 4)},
	{"atlas": Vector2i(8, 20), "cell": Vector2i(14, 3)},
	{"atlas": Vector2i(9, 20), "cell": Vector2i(24, 3)},
]

var _sample_layers: Dictionary = {}

func _init() -> void:
	_sample_layers = _load_sample_layers()

	var tile_set := _build_tileset()
	var save_tileset_error := ResourceSaver.save(tile_set, TILESET_PATH)
	if save_tileset_error != OK:
		push_error("Failed to save town tileset: %s" % save_tileset_error)
		quit(1)
		return

	var scene_root := _build_map_scene(load(TILESET_PATH) as TileSet)
	var packed_scene := PackedScene.new()
	var pack_error := packed_scene.pack(scene_root)
	if pack_error != OK:
		push_error("Failed to pack map scene: %s" % pack_error)
		quit(1)
		return

	var save_scene_error := ResourceSaver.save(packed_scene, MAP_SCENE_PATH)
	if save_scene_error != OK:
		push_error("Failed to save map scene: %s" % save_scene_error)
		quit(1)
		return

	_save_preview(scene_root)
	print("Generated Stage 1 town scene: %s" % MAP_SCENE_PATH)
	print("Generated preview: %s" % PREVIEW_PATH)
	quit()

func _build_tileset() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	tile_set.add_source(_build_atlas_source(BASE_TEXTURE_PATH), SOURCE_BASE)
	tile_set.add_source(_build_atlas_source(GRASS_TEXTURE_PATH), SOURCE_GRASS)
	tile_set.add_source(_build_atlas_source(ADDWORK_TEXTURE_PATH), SOURCE_ADDWORK)
	return tile_set

func _build_atlas_source(texture_path: String) -> TileSetAtlasSource:
	var image := _load_keyed_image(texture_path)
	if image == null or image.is_empty():
		push_error("Failed to load texture: %s" % texture_path)
		return TileSetAtlasSource.new()
	var texture := ImageTexture.create_from_image(image)

	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)

	var texture_size := texture.get_size()
	for y in range(texture_size.y / TILE_SIZE):
		for x in range(texture_size.x / TILE_SIZE):
			source.create_tile(Vector2i(x, y))

	return source

func _build_map_scene(tile_set: TileSet) -> Node2D:
	var root := Node2D.new()
	root.name = "Map"
	root.script = load("res://scenes/map/Map.gd")
	root.set_meta("map_size_tiles", MAP_SIZE)

	var ground_map := TileMap.new()
	ground_map.name = "GroundMap"
	ground_map.z_index = -10
	ground_map.tile_set = tile_set
	while ground_map.get_layers_count() < 5:
		ground_map.add_layer(ground_map.get_layers_count())

	ground_map.set_layer_name(LAYER_GROUND, "Ground")
	ground_map.set_layer_name(LAYER_ROAD, "Road")
	ground_map.set_layer_name(LAYER_BUILDINGS, "Buildings")
	ground_map.set_layer_name(LAYER_PROPS, "Props")
	ground_map.set_layer_name(LAYER_OVERLAY, "Overlay")
	ground_map.set_layer_z_index(LAYER_GROUND, 0)
	ground_map.set_layer_z_index(LAYER_ROAD, 1)
	ground_map.set_layer_z_index(LAYER_BUILDINGS, 2)
	ground_map.set_layer_z_index(LAYER_PROPS, 3)
	ground_map.set_layer_z_index(LAYER_OVERLAY, 4)
	root.add_child(ground_map)
	ground_map.owner = root

	_fill_ground(ground_map)
	_paint_roads(ground_map)
	_stamp_town_blocks(ground_map)
	_stamp_tree_clumps(ground_map)
	_stamp_addwork_props(ground_map)

	var collision_body := _build_collision_body()
	root.add_child(collision_body)
	collision_body.owner = root

	var triggers := _build_trigger_nodes()
	root.add_child(triggers)
	triggers.owner = root
	for child in triggers.get_children():
		child.owner = root
		for grandchild in child.get_children():
			grandchild.owner = root

	var player_spawn := Marker2D.new()
	player_spawn.name = "PlayerSpawn"
	player_spawn.position = _cell_center(Vector2i(19, 23))
	root.add_child(player_spawn)
	player_spawn.owner = root

	var player := _build_player()
	root.add_child(player)
	player.owner = root
	for child in player.get_children():
		child.owner = root
		for grandchild in child.get_children():
			grandchild.owner = root

	var ui := _build_ui()
	root.add_child(ui)
	ui.owner = root
	for child in ui.get_children():
		child.owner = root

	return root

func _fill_ground(tile_map: TileMap) -> void:
	for y in range(MAP_SIZE.y):
		for x in range(MAP_SIZE.x):
			var cell := Vector2i(x, y)
			var gid := GROUND_GID
			if ((x * 13) + (y * 7)) % 17 == 0:
				gid = SAMPLE_GID_BASE_START + 1
			_set_sample_gid(tile_map, LAYER_GROUND, cell, gid)

func _paint_roads(tile_map: TileMap) -> void:
	for y in range(0, MAP_SIZE.y):
		for x in range(18, 22):
			_set_sample_gid(tile_map, LAYER_ROAD, Vector2i(x, y), ROAD_GID)

	_paint_road_rect(tile_map, Rect2i(11, 10, 18, 6))
	_paint_road_rect(tile_map, Rect2i(10, 11, 8, 4))
	_paint_road_rect(tile_map, Rect2i(21, 11, 8, 4))
	_paint_road_rect(tile_map, Rect2i(5, 15, 4, 6))
	_paint_road_rect(tile_map, Rect2i(30, 15, 4, 6))
	_paint_road_rect(tile_map, Rect2i(17, 0, 6, 5))

func _paint_road_rect(tile_map: TileMap, area: Rect2i) -> void:
	for y in range(area.position.y, area.end.y):
		for x in range(area.position.x, area.end.x):
			_set_sample_gid(tile_map, LAYER_ROAD, Vector2i(x, y), ROAD_GID)

func _stamp_town_blocks(tile_map: TileMap) -> void:
	_copy_sample_rect_to_layer(tile_map, _sample_layers["building"], HALL_SRC, Vector2i(21, 4), LAYER_BUILDINGS)
	_copy_sample_rect_to_layer(tile_map, _sample_layers["building_up"], HALL_SRC, Vector2i(21, 4), LAYER_OVERLAY)

	_copy_sample_rect_to_layer(tile_map, _sample_layers["building"], BOOKSTORE_SRC, Vector2i(3, 7), LAYER_BUILDINGS)
	_copy_sample_rect_to_layer(tile_map, _sample_layers["building_up"], BOOKSTORE_SRC, Vector2i(3, 7), LAYER_OVERLAY)

	_copy_sample_rect_to_layer(tile_map, _sample_layers["farm"], FARM_SRC, Vector2i(0, 12), LAYER_PROPS)
	_copy_sample_rect_to_layer(tile_map, _sample_layers["farm_up"], FARM_SRC, Vector2i(0, 12), LAYER_OVERLAY)

	_copy_sample_rect_to_layer(tile_map, _sample_layers["building"], STALL_SRC, Vector2i(29, 13), LAYER_PROPS)
	_copy_sample_rect_to_layer(tile_map, _sample_layers["building_up"], STALL_SRC, Vector2i(29, 13), LAYER_OVERLAY)

	_copy_sample_rect_to_layer(tile_map, _sample_layers["building"], NORTH_GATE_SRC, Vector2i(17, 0), LAYER_BUILDINGS)
	_copy_sample_rect_to_layer(tile_map, _sample_layers["building_up"], NORTH_GATE_SRC, Vector2i(17, 0), LAYER_OVERLAY)
func _stamp_tree_clumps(tile_map: TileMap) -> void:
	for tree_patch in TREE_CLUMPS:
		_copy_sample_rect_to_layer(tile_map, _sample_layers["tree"], tree_patch.src, tree_patch.dst, LAYER_OVERLAY)

func _stamp_addwork_props(tile_map: TileMap) -> void:
	for sign in ADDWORK_SIGNS:
		tile_map.set_cell(LAYER_PROPS, sign.cell, SOURCE_ADDWORK, sign.atlas)

	for grit in ADDWORK_GRIT:
		tile_map.set_cell(LAYER_PROPS, grit.cell, SOURCE_ADDWORK, grit.atlas)

func _build_collision_body() -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = "WorldCollision"

	var blocking_rects := [
		Rect2i(3, 7, 7, 8),
		Rect2i(21, 4, 18, 10),
		Rect2i(0, 12, 12, 10),
		Rect2i(29, 13, 10, 7),
		Rect2i(0, 0, 4, MAP_SIZE.y),
		Rect2i(MAP_SIZE.x - 4, 0, 4, MAP_SIZE.y),
		Rect2i(0, MAP_SIZE.y - 2, MAP_SIZE.x, 2),
		Rect2i(0, 0, 17, 2),
		Rect2i(23, 0, MAP_SIZE.x - 23, 2),
	]

	for rect in blocking_rects:
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(rect.size.x * TILE_SIZE, rect.size.y * TILE_SIZE)
		shape.shape = rectangle
		shape.position = Vector2(
			(rect.position.x * TILE_SIZE) + (rectangle.size.x * 0.5),
			(rect.position.y * TILE_SIZE) + (rectangle.size.y * 0.5)
		)
		body.add_child(shape)

	return body

func _build_trigger_nodes() -> Node2D:
	var root := Node2D.new()
	root.name = "Triggers"
	root.add_child(_make_area("TownExitTrigger", Rect2i(17, 0, 6, 3)))
	root.add_child(_make_area("BookstoreEntranceTrigger", Rect2i(10, 15, 2, 2)))
	root.add_child(_make_area("IntelNpcZone", Rect2i(15, 11, 3, 3)))
	root.add_child(_make_area("MoralChoiceNpcZone", Rect2i(18, 6, 3, 3)))
	root.add_child(_make_area("BookstoreNpcZone", Rect2i(8, 12, 3, 2)))
	return root

func _make_area(name: String, rect: Rect2i) -> Area2D:
	var area := Area2D.new()
	area.name = name
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(rect.size.x * TILE_SIZE, rect.size.y * TILE_SIZE)
	shape.shape = rectangle
	shape.position = Vector2(
		(rect.position.x * TILE_SIZE) + (rectangle.size.x * 0.5),
		(rect.position.y * TILE_SIZE) + (rectangle.size.y * 0.5)
	)
	area.add_child(shape)
	return area

func _build_player() -> CharacterBody2D:
	var player := CharacterBody2D.new()
	player.name = "Player"

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(20, 20)
	collision.shape = shape
	player.add_child(collision)

	var body := Polygon2D.new()
	body.color = Color(0.79, 0.35, 0.24, 1.0)
	body.polygon = PackedVector2Array([
		Vector2(-10, -10),
		Vector2(10, -10),
		Vector2(10, 10),
		Vector2(-10, 10),
	])
	player.add_child(body)

	var accent := Polygon2D.new()
	accent.color = Color(0.10, 0.08, 0.06, 1.0)
	accent.polygon = PackedVector2Array([
		Vector2(-4, -10),
		Vector2(4, -10),
		Vector2(4, -2),
		Vector2(-4, -2),
	])
	player.add_child(accent)

	var camera := Camera2D.new()
	camera.name = "MapCamera"
	camera.enabled = true
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	player.add_child(camera)

	return player

func _build_ui() -> CanvasLayer:
	var ui := CanvasLayer.new()
	ui.name = "UI"

	var backdrop := ColorRect.new()
	backdrop.name = "HintBackdrop"
	backdrop.offset_left = 556.0
	backdrop.offset_top = 16.0
	backdrop.offset_right = 944.0
	backdrop.offset_bottom = 104.0
	backdrop.color = Color(0.0, 0.0, 0.0, 0.45)
	ui.add_child(backdrop)

	var label := Label.new()
	label.name = "HintLabel"
	label.offset_left = 572.0
	label.offset_top = 28.0
	label.offset_right = 932.0
	label.offset_bottom = 92.0
	label.text = "Frontier Hamlet"
	ui.add_child(label)

	return ui

func _save_preview(root: Node2D) -> void:
	var tile_map: TileMap = root.get_node("GroundMap")
	var source_images := {
		SOURCE_BASE: _load_keyed_image(BASE_TEXTURE_PATH),
		SOURCE_GRASS: _load_keyed_image(GRASS_TEXTURE_PATH),
		SOURCE_ADDWORK: _load_keyed_image(ADDWORK_TEXTURE_PATH),
	}

	var preview := Image.create(MAP_SIZE.x * TILE_SIZE, MAP_SIZE.y * TILE_SIZE, false, Image.FORMAT_RGBA8)
	preview.fill(Color(0, 0, 0, 0))

	for layer in range(tile_map.get_layers_count()):
		for cell in tile_map.get_used_cells(layer):
			var source_id := tile_map.get_cell_source_id(layer, cell)
			var atlas_coords := tile_map.get_cell_atlas_coords(layer, cell)
			if source_id < 0 or not source_images.has(source_id):
				continue

			var source_image: Image = source_images[source_id]
			var source_rect := Rect2i(atlas_coords * TILE_SIZE, Vector2i(TILE_SIZE, TILE_SIZE))
			preview.blend_rect(source_image, source_rect, cell * TILE_SIZE)

	preview.save_png(PREVIEW_PATH)

func _load_sample_layers() -> Dictionary:
	var text := FileAccess.get_file_as_string(SAMPLE_TMX_PATH)
	var regex := RegEx.new()
	regex.compile("(?s)<layer[^>]*name=\\\"([^\\\"]+)\\\"[^>]*>\\s*<data encoding=\\\"csv\\\">\\s*(.*?)\\s*</data>\\s*</layer>")

	var layers := {}
	for match in regex.search_all(text):
		layers[match.get_string(1)] = _parse_csv_grid(match.get_string(2), SAMPLE_WIDTH, SAMPLE_HEIGHT)

	return layers

func _load_keyed_image(texture_path: String) -> Image:
	var image := Image.load_from_file(ProjectSettings.globalize_path(texture_path))
	if image == null or image.is_empty():
		return image

	image.convert(Image.FORMAT_RGBA8)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color := image.get_pixel(x, y)
			if color.r < 0.05 and color.g < 0.05 and color.b < 0.05:
				image.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))

	return image

func _parse_csv_grid(csv: String, width: int, height: int) -> Array:
	var values := csv.strip_edges().replace("\n", "").replace("\r", "").split(",", false)
	var grid: Array = []
	for y in range(height):
		var row: Array = []
		for x in range(width):
			var index := (y * width) + x
			row.append(int(values[index]))
		grid.append(row)
	return grid

func _copy_sample_rect_to_layer(tile_map: TileMap, sample_grid: Array, source_rect: Rect2i, target_origin: Vector2i, target_layer: int) -> void:
	for y in range(source_rect.size.y):
		for x in range(source_rect.size.x):
			var sample_gid: int = sample_grid[source_rect.position.y + y][source_rect.position.x + x]
			if sample_gid == 0:
				continue

			var target_cell := target_origin + Vector2i(x, y)
			if _is_outside_map(target_cell):
				continue

			_set_sample_gid(tile_map, target_layer, target_cell, sample_gid)

func _set_sample_gid(tile_map: TileMap, layer: int, cell: Vector2i, gid: int) -> void:
	if gid == 0 or _is_outside_map(cell):
		return

	var source_id := SOURCE_BASE
	var atlas := Vector2i.ZERO

	if gid >= SAMPLE_GID_GRASS_START and gid < SAMPLE_GID_WATER_START:
		var grass_id := gid - SAMPLE_GID_GRASS_START
		source_id = SOURCE_GRASS
		atlas = Vector2i(grass_id % GRASS_COLUMNS, int(grass_id / GRASS_COLUMNS))
	elif gid >= SAMPLE_GID_BASE_START and gid < SAMPLE_GID_GRASS_START:
		var base_id := gid - SAMPLE_GID_BASE_START
		source_id = SOURCE_BASE
		atlas = Vector2i(base_id % BASE_COLUMNS, int(base_id / BASE_COLUMNS))
	else:
		return

	tile_map.set_cell(layer, cell, source_id, atlas)

func _cell_center(cell: Vector2i) -> Vector2:
	return Vector2((cell.x * TILE_SIZE) + (TILE_SIZE * 0.5), (cell.y * TILE_SIZE) + (TILE_SIZE * 0.5))

func _is_outside_map(cell: Vector2i) -> bool:
	return cell.x < 0 or cell.y < 0 or cell.x >= MAP_SIZE.x or cell.y >= MAP_SIZE.y
