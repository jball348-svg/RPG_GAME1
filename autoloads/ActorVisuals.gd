extends Node

const ACTOR_PLAYER_FIGHTER := "player_fighter"
const ACTOR_PLAYER_BATTLEMAGE := "player_battlemage"
const ACTOR_SHAMAN := "shaman"
const ACTOR_VILLAGE_GUARD := "village_guard"
const ACTOR_TRAVELING_MERCHANT := "traveling_merchant"
const ACTOR_BOOKSTORE_KEEPER := "bookstore_keeper"
const ACTOR_KOBOLD := "kobold"

const FIGHTER_MAP_SHEET_PATH := "res://assets/art/external/stage_8_5/fighter_walk_sheet.png"
const BATTLEMAGE_MAP_SHEET_PATH := "res://assets/art/external/stage_8_5/battlemage_walk_sheet.png"
const LPC_SPRITE_SHEET_PATH := "res://assets/art/player/universal-lpc-sprite_male_01_full.png"
const SHAMAN_SPRITE_PATH := "res://assets/art/battle/goblinsword.png"
const KOBOLD_SPRITE_PATH := "res://assets/art/battle/LPC imp/attack - vanilla.png"
const FIGHTER_PORTRAIT_PATH := "res://assets/art/generated/stage_8_5/fighter_presentation_card.png"
const BATTLEMAGE_PORTRAIT_PATH := "res://assets/art/generated/stage_8_5/battlemage_presentation_card.png"
const KOBOLD_PORTRAIT_PATH := "res://assets/art/generated/stage_8_5/kobold_presentation_card.png"

const PLAYER_FRAME_SIZE := Vector2i(64, 64)
const PLAYER_DIRECTION_ROWS := {
	"up": 0,
	"left": 1,
	"down": 2,
	"right": 3,
}
const PLAYER_IDLE_COLUMN := 4
const LPC_BOOKSTORE_REGION := Rect2i(256, 128, 64, 64)
const SHAMAN_REGION := Rect2i(0, 0, 64, 64)
const KOBOLD_REGION := Rect2i(64, 128, 64, 64)
const DEFAULT_MAP_OFFSET := Vector2(0.0, -12.0)
const DEFAULT_MAP_SCALE := Vector2.ONE * 0.5

var _registry: Dictionary = {}
var _texture_cache: Dictionary = {}
var _map_frames_cache: Dictionary = {}
var _map_texture_cache: Dictionary = {}
var _portrait_cache: Dictionary = {}
var _battle_cache: Dictionary = {}
var _cutscene_cache: Dictionary = {}
var _follower_frames_cache: Dictionary = {}

func get_registry() -> Dictionary:
	_ensure_registry()
	return _registry.duplicate(true)

func resolve_player_actor_id() -> String:
	return ACTOR_PLAYER_BATTLEMAGE if PlayerData.resolve_vertical_slice_class_id() == PlayerData.CLASS_BATTLEMAGE else ACTOR_PLAYER_FIGHTER

func get_map_offset(actor_id: String) -> Vector2:
	var map_entry: Dictionary = _actor_section(actor_id, "map")
	return map_entry.get("offset", DEFAULT_MAP_OFFSET)

func get_map_scale(actor_id: String) -> Vector2:
	var map_entry: Dictionary = _actor_section(actor_id, "map")
	return map_entry.get("scale", DEFAULT_MAP_SCALE)

func get_map_modulate(actor_id: String) -> Color:
	var map_entry: Dictionary = _actor_section(actor_id, "map")
	return map_entry.get("modulate", Color(1.0, 1.0, 1.0, 1.0))

func get_map_frames(actor_id: String) -> SpriteFrames:
	_ensure_registry()
	if _map_frames_cache.has(actor_id):
		return _map_frames_cache[actor_id] as SpriteFrames

	var map_entry: Dictionary = _actor_section(actor_id, "map")
	if map_entry.is_empty():
		return null

	var map_type := str(map_entry.get("type", ""))
	var frames: SpriteFrames = null
	match map_type:
		"sheet_frames":
			frames = _build_directional_frames(
				_load_texture(str(map_entry.get("path", ""))),
				map_entry.get("frame_size", PLAYER_FRAME_SIZE),
				map_entry.get("direction_rows", PLAYER_DIRECTION_ROWS),
				int(map_entry.get("idle_column", PLAYER_IDLE_COLUMN)),
				int(map_entry.get("walk_columns", 9))
			)
		"single_frame_directions":
			var base_texture := _resolve_texture_from_entry(map_entry)
			if base_texture != null:
				frames = _build_single_frame_directions(base_texture)

	if frames != null:
		_map_frames_cache[actor_id] = frames
	return frames

func get_map_texture(actor_id: String, direction: String = "down") -> Texture2D:
	_ensure_registry()
	var cache_key := "%s|%s" % [actor_id, direction]
	if _map_texture_cache.has(cache_key):
		return _map_texture_cache[cache_key] as Texture2D

	var map_entry: Dictionary = _actor_section(actor_id, "map")
	if map_entry.is_empty():
		return null

	var texture := _resolve_texture_for_direction(map_entry, direction)
	if texture != null:
		_map_texture_cache[cache_key] = texture
	return texture

func get_portrait(actor_id: String) -> Texture2D:
	_ensure_registry()
	if _portrait_cache.has(actor_id):
		return _portrait_cache[actor_id] as Texture2D

	var portrait_entry: Dictionary = _actor_section(actor_id, "portrait")
	var texture := _resolve_texture_from_entry(portrait_entry)
	if texture == null:
		texture = get_battle_texture(actor_id)
	if texture == null:
		texture = get_map_texture(actor_id)
	if texture != null:
		_portrait_cache[actor_id] = texture
	return texture

func get_battle_texture(actor_id: String) -> Texture2D:
	_ensure_registry()
	if _battle_cache.has(actor_id):
		return _battle_cache[actor_id] as Texture2D

	var battle_entry: Dictionary = _actor_section(actor_id, "battle")
	var texture := _resolve_texture_from_entry(battle_entry)
	if texture != null:
		_battle_cache[actor_id] = texture
	return texture

func get_battle_flip_h(actor_id: String) -> bool:
	var battle_entry: Dictionary = _actor_section(actor_id, "battle")
	return bool(battle_entry.get("flip_h", true))

func get_battle_target_height(actor_id: String, fallback_height: float) -> float:
	var battle_entry: Dictionary = _actor_section(actor_id, "battle")
	return float(battle_entry.get("target_height", fallback_height))

func get_cutscene_texture(actor_id: String, direction: String = "down") -> Texture2D:
	_ensure_registry()
	var cache_key := "%s|%s" % [actor_id, direction]
	if _cutscene_cache.has(cache_key):
		return _cutscene_cache[cache_key] as Texture2D

	var cutscene_entry: Dictionary = _actor_section(actor_id, "cutscene")
	var texture := _resolve_texture_for_direction(cutscene_entry, direction)
	if texture == null:
		texture = get_battle_texture(actor_id)
	if texture != null:
		_cutscene_cache[cache_key] = texture
	return texture

func get_cutscene_modulate(actor_id: String) -> Color:
	var cutscene_entry: Dictionary = _actor_section(actor_id, "cutscene")
	return cutscene_entry.get("modulate", Color(1.0, 1.0, 1.0, 1.0))

func get_follower_frames(actor_id: String) -> SpriteFrames:
	_ensure_registry()
	if _follower_frames_cache.has(actor_id):
		return _follower_frames_cache[actor_id] as SpriteFrames

	var follower_entry: Dictionary = _actor_section(actor_id, "follower")
	if follower_entry.is_empty():
		return null

	var frames: SpriteFrames = null
	if str(follower_entry.get("type", "")) == "single_frame_directions":
		var base_texture := _resolve_texture_from_entry(follower_entry)
		if base_texture == null:
			base_texture = get_cutscene_texture(actor_id)
		if base_texture != null:
			frames = _build_single_frame_directions(base_texture)

	if frames != null:
		_follower_frames_cache[actor_id] = frames
	return frames

func get_follower_scale(actor_id: String) -> Vector2:
	var follower_entry: Dictionary = _actor_section(actor_id, "follower")
	return follower_entry.get("scale", DEFAULT_MAP_SCALE)

func get_follower_modulate(actor_id: String) -> Color:
	var follower_entry: Dictionary = _actor_section(actor_id, "follower")
	return follower_entry.get("modulate", Color(1.0, 1.0, 1.0, 1.0))

func _ensure_registry() -> void:
	if not _registry.is_empty():
		return

	_registry = {
		ACTOR_PLAYER_FIGHTER: {
			"accent": Color(0.78, 0.68, 0.40, 1.0),
			"map": {
				"type": "sheet_frames",
				"path": FIGHTER_MAP_SHEET_PATH,
				"frame_size": PLAYER_FRAME_SIZE,
				"idle_column": PLAYER_IDLE_COLUMN,
				"walk_columns": 9,
				"direction_rows": PLAYER_DIRECTION_ROWS,
				"offset": DEFAULT_MAP_OFFSET,
				"scale": DEFAULT_MAP_SCALE,
				"modulate": Color(1.0, 1.0, 1.0, 1.0),
			},
			"battle": {
				"type": "sheet_frame",
				"path": FIGHTER_MAP_SHEET_PATH,
				"frame_size": PLAYER_FRAME_SIZE,
				"row": PLAYER_DIRECTION_ROWS["right"],
				"column": PLAYER_IDLE_COLUMN,
				"flip_h": false,
				"target_height": 88.0,
			},
			"portrait": {
				"type": "texture",
				"path": FIGHTER_PORTRAIT_PATH,
			},
			"cutscene": {
				"type": "sheet_direction_frame",
				"path": FIGHTER_MAP_SHEET_PATH,
				"frame_size": PLAYER_FRAME_SIZE,
				"idle_column": PLAYER_IDLE_COLUMN,
				"direction_rows": PLAYER_DIRECTION_ROWS,
			},
			"follower": {},
		},
		ACTOR_PLAYER_BATTLEMAGE: {
			"accent": Color(0.41, 0.55, 0.74, 1.0),
			"map": {
				"type": "sheet_frames",
				"path": BATTLEMAGE_MAP_SHEET_PATH,
				"frame_size": PLAYER_FRAME_SIZE,
				"idle_column": PLAYER_IDLE_COLUMN,
				"walk_columns": 9,
				"direction_rows": PLAYER_DIRECTION_ROWS,
				"offset": DEFAULT_MAP_OFFSET,
				"scale": DEFAULT_MAP_SCALE,
				"modulate": Color(1.0, 1.0, 1.0, 1.0),
			},
			"battle": {
				"type": "sheet_frame",
				"path": BATTLEMAGE_MAP_SHEET_PATH,
				"frame_size": PLAYER_FRAME_SIZE,
				"row": PLAYER_DIRECTION_ROWS["right"],
				"column": PLAYER_IDLE_COLUMN,
				"flip_h": false,
				"target_height": 88.0,
			},
			"portrait": {
				"type": "texture",
				"path": BATTLEMAGE_PORTRAIT_PATH,
			},
			"cutscene": {
				"type": "sheet_direction_frame",
				"path": BATTLEMAGE_MAP_SHEET_PATH,
				"frame_size": PLAYER_FRAME_SIZE,
				"idle_column": PLAYER_IDLE_COLUMN,
				"direction_rows": PLAYER_DIRECTION_ROWS,
			},
			"follower": {},
		},
		ACTOR_SHAMAN: {
			"accent": Color(0.63, 0.83, 0.38, 1.0),
			"map": {
				"type": "crop",
				"path": SHAMAN_SPRITE_PATH,
				"region": SHAMAN_REGION,
				"offset": Vector2(0.0, -10.0),
				"scale": Vector2.ONE * 0.44,
				"modulate": Color(1.0, 1.0, 1.0, 1.0),
				"transparent_black": true,
				"trim": true,
			},
			"battle": {
				"type": "crop",
				"path": SHAMAN_SPRITE_PATH,
				"region": SHAMAN_REGION,
				"transparent_black": true,
				"trim": true,
				"flip_h": true,
				"target_height": 88.0,
			},
			"portrait": {
				"type": "crop",
				"path": SHAMAN_SPRITE_PATH,
				"region": SHAMAN_REGION,
				"transparent_black": true,
				"trim": true,
			},
			"cutscene": {
				"type": "crop",
				"path": SHAMAN_SPRITE_PATH,
				"region": SHAMAN_REGION,
				"transparent_black": true,
				"trim": true,
				"modulate": Color(1.0, 1.0, 1.0, 1.0),
			},
			"follower": {
				"type": "single_frame_directions",
				"path": SHAMAN_SPRITE_PATH,
				"region": SHAMAN_REGION,
				"transparent_black": true,
				"trim": true,
				"scale": Vector2.ONE * 0.44,
				"modulate": Color(1.0, 1.0, 1.0, 1.0),
			},
		},
		ACTOR_VILLAGE_GUARD: {
			"accent": Color(0.81, 0.87, 1.0, 1.0),
			"map": {
				"type": "sheet_frame",
				"path": FIGHTER_MAP_SHEET_PATH,
				"frame_size": PLAYER_FRAME_SIZE,
				"row": PLAYER_DIRECTION_ROWS["down"],
				"column": PLAYER_IDLE_COLUMN,
				"offset": DEFAULT_MAP_OFFSET,
				"scale": DEFAULT_MAP_SCALE,
				"modulate": Color(0.90, 0.95, 1.0, 1.0),
			},
			"battle": {},
			"portrait": {
				"type": "sheet_frame",
				"path": FIGHTER_MAP_SHEET_PATH,
				"frame_size": PLAYER_FRAME_SIZE,
				"row": PLAYER_DIRECTION_ROWS["down"],
				"column": PLAYER_IDLE_COLUMN,
			},
			"cutscene": {
				"type": "sheet_direction_frame",
				"path": FIGHTER_MAP_SHEET_PATH,
				"frame_size": PLAYER_FRAME_SIZE,
				"idle_column": PLAYER_IDLE_COLUMN,
				"direction_rows": PLAYER_DIRECTION_ROWS,
			},
			"follower": {},
		},
		ACTOR_TRAVELING_MERCHANT: {
			"accent": Color(1.0, 0.87, 0.66, 1.0),
			"map": {
				"type": "sheet_frame",
				"path": BATTLEMAGE_MAP_SHEET_PATH,
				"frame_size": PLAYER_FRAME_SIZE,
				"row": PLAYER_DIRECTION_ROWS["down"],
				"column": PLAYER_IDLE_COLUMN,
				"offset": DEFAULT_MAP_OFFSET,
				"scale": DEFAULT_MAP_SCALE,
				"modulate": Color(1.0, 0.91, 0.78, 1.0),
			},
			"battle": {},
			"portrait": {
				"type": "sheet_frame",
				"path": BATTLEMAGE_MAP_SHEET_PATH,
				"frame_size": PLAYER_FRAME_SIZE,
				"row": PLAYER_DIRECTION_ROWS["down"],
				"column": PLAYER_IDLE_COLUMN,
			},
			"cutscene": {},
			"follower": {},
		},
		ACTOR_BOOKSTORE_KEEPER: {
			"accent": Color(0.86, 0.96, 0.82, 1.0),
			"map": {
				"type": "atlas",
				"path": LPC_SPRITE_SHEET_PATH,
				"region": LPC_BOOKSTORE_REGION,
				"offset": DEFAULT_MAP_OFFSET,
				"scale": DEFAULT_MAP_SCALE,
				"modulate": Color(0.94, 1.0, 0.92, 1.0),
			},
			"battle": {},
			"portrait": {
				"type": "atlas",
				"path": LPC_SPRITE_SHEET_PATH,
				"region": LPC_BOOKSTORE_REGION,
			},
			"cutscene": {},
			"follower": {},
		},
		ACTOR_KOBOLD: {
			"accent": Color(0.69, 0.24, 0.21, 1.0),
			"map": {},
			"battle": {
				"type": "crop",
				"path": KOBOLD_SPRITE_PATH,
				"region": KOBOLD_REGION,
				"flip_h": true,
				"target_height": 78.0,
			},
			"portrait": {
				"type": "texture",
				"path": KOBOLD_PORTRAIT_PATH,
			},
			"cutscene": {},
			"follower": {},
		},
	}

func _actor_section(actor_id: String, section_name: String) -> Dictionary:
	_ensure_registry()
	var actor_entry: Dictionary = _registry.get(actor_id, {})
	if actor_entry.is_empty():
		return {}
	var section: Variant = actor_entry.get(section_name, {})
	return section if section is Dictionary else {}

func _resolve_texture_for_direction(entry: Dictionary, direction: String) -> Texture2D:
	var entry_type := str(entry.get("type", ""))
	match entry_type:
		"sheet_direction_frame":
			var direction_rows: Dictionary = entry.get("direction_rows", PLAYER_DIRECTION_ROWS)
			var row := int(direction_rows.get(direction, direction_rows.get("down", 0)))
			return _load_sheet_frame_texture(
				str(entry.get("path", "")),
				entry.get("frame_size", PLAYER_FRAME_SIZE),
				row,
				int(entry.get("idle_column", PLAYER_IDLE_COLUMN))
			)
		_:
			return _resolve_texture_from_entry(entry)

func _resolve_texture_from_entry(entry: Dictionary) -> Texture2D:
	var entry_type := str(entry.get("type", ""))
	match entry_type:
		"texture":
			return _load_texture(str(entry.get("path", "")))
		"atlas":
			var texture := _load_texture(str(entry.get("path", "")))
			if texture == null:
				return null
			return _make_atlas_texture(texture, entry.get("region", LPC_BOOKSTORE_REGION))
		"sheet_frame":
			return _load_sheet_frame_texture(
				str(entry.get("path", "")),
				entry.get("frame_size", PLAYER_FRAME_SIZE),
				int(entry.get("row", 0)),
				int(entry.get("column", PLAYER_IDLE_COLUMN))
			)
		"crop":
			return _load_cropped_texture(
				str(entry.get("path", "")),
				entry.get("region", SHAMAN_REGION),
				_make_fallback_texture(64, 64, Color(0.45, 0.35, 0.28)),
				bool(entry.get("transparent_black", false)),
				bool(entry.get("trim", false))
			)
		_:
			return null

func _build_directional_frames(texture: Texture2D, frame_size: Vector2i, direction_rows: Dictionary, idle_column: int, walk_columns: int) -> SpriteFrames:
	if texture == null:
		return null

	var sprite_frames := SpriteFrames.new()
	for direction in direction_rows.keys():
		var row := int(direction_rows[direction])
		var idle_animation := "idle_%s" % direction
		sprite_frames.add_animation(idle_animation)
		sprite_frames.set_animation_loop(idle_animation, true)
		sprite_frames.set_animation_speed(idle_animation, 1.0)
		sprite_frames.add_frame(idle_animation, _make_sheet_frame(texture, frame_size, row, idle_column))

		var walk_animation := "walk_%s" % direction
		sprite_frames.add_animation(walk_animation)
		sprite_frames.set_animation_loop(walk_animation, true)
		sprite_frames.set_animation_speed(walk_animation, 10.0)
		for column in range(walk_columns):
			sprite_frames.add_frame(walk_animation, _make_sheet_frame(texture, frame_size, row, column))

	return sprite_frames

func _build_single_frame_directions(texture: Texture2D) -> SpriteFrames:
	var sprite_frames := SpriteFrames.new()
	for direction in ["up", "left", "down", "right"]:
		for prefix in ["idle", "walk"]:
			var animation_name := "%s_%s" % [prefix, direction]
			sprite_frames.add_animation(animation_name)
			sprite_frames.set_animation_loop(animation_name, true)
			sprite_frames.set_animation_speed(animation_name, 1.0 if prefix == "idle" else 8.0)
			sprite_frames.add_frame(animation_name, texture)
	return sprite_frames

func _make_atlas_texture(texture: Texture2D, region: Rect2i) -> Texture2D:
	if texture == null:
		return null

	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(region.position, region.size)
	return atlas

func _make_sheet_frame(texture: Texture2D, frame_size: Vector2i, row: int, column: int) -> Texture2D:
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(Vector2(column * frame_size.x, row * frame_size.y), Vector2(frame_size.x, frame_size.y))
	return atlas

func _load_sheet_frame_texture(resource_path: String, frame_size: Vector2i, row: int, column: int) -> Texture2D:
	var source_texture := _load_texture(resource_path)
	if source_texture != null:
		return _make_sheet_frame(source_texture, frame_size, row, column)

	var image := Image.load_from_file(ProjectSettings.globalize_path(resource_path))
	if image == null or image.is_empty():
		return null

	var cropped := image.get_region(Rect2i(column * frame_size.x, row * frame_size.y, frame_size.x, frame_size.y))
	if cropped == null or cropped.is_empty():
		return null
	return ImageTexture.create_from_image(cropped)

func _load_texture(resource_path: String) -> Texture2D:
	if resource_path == "":
		return null
	if _texture_cache.has(resource_path):
		return _texture_cache[resource_path] as Texture2D

	if ResourceLoader.exists(resource_path, "Texture2D") or ResourceLoader.exists(resource_path):
		var texture := load(resource_path)
		if texture is Texture2D:
			_texture_cache[resource_path] = texture
			return texture as Texture2D

	var image := Image.load_from_file(ProjectSettings.globalize_path(resource_path))
	if image == null or image.is_empty():
		return null

	var image_texture := ImageTexture.create_from_image(image)
	_texture_cache[resource_path] = image_texture
	return image_texture

func _load_cropped_texture(resource_path: String, region: Rect2i, fallback: Texture2D, transparent_black: bool = false, trim_to_visible_bounds: bool = false) -> Texture2D:
	var image := Image.load_from_file(ProjectSettings.globalize_path(resource_path))
	if image == null or image.is_empty():
		return fallback

	var cropped := image.get_region(region)
	if cropped == null or cropped.is_empty():
		return fallback

	if transparent_black:
		_clear_black_background(cropped)

	if trim_to_visible_bounds:
		cropped = _trim_visible_image(cropped)
		if cropped == null or cropped.is_empty():
			return fallback

	return ImageTexture.create_from_image(cropped)

func _clear_black_background(image: Image) -> void:
	image.convert(Image.FORMAT_RGBA8)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			if pixel.a > 0.0 and pixel.r <= 0.01 and pixel.g <= 0.01 and pixel.b <= 0.01:
				image.set_pixel(x, y, Color(pixel.r, pixel.g, pixel.b, 0.0))

func _trim_visible_image(image: Image) -> Image:
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.05:
				min_x = min(min_x, x)
				min_y = min(min_y, y)
				max_x = max(max_x, x)
				max_y = max(max_y, y)

	if max_x < min_x or max_y < min_y:
		return image

	return image.get_region(Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1))

func _make_fallback_texture(width: int, height: int, color: Color) -> Texture2D:
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)
