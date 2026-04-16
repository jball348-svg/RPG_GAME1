extends Node

const CUE_TOWN := "town"
const CUE_MINE := "mine"
const CUE_BATTLE := "battle"
const CUE_BOSS := "boss"
const CUE_MORAL_CHOICE := "moral_choice"
const CUE_VICTORY_EXIT := "victory_exit"

const SFX_UI_CONFIRM := "ui_confirm"
const SFX_UI_CANCEL := "ui_cancel"
const SFX_DIALOGUE_ADVANCE := "dialogue_advance"
const SFX_STEP_TOWN := "step_town"
const SFX_STEP_MINE := "step_mine"
const SFX_ATTACK_SWING := "attack_swing"
const SFX_ATTACK_HIT := "attack_hit"
const SFX_SPELL_CAST := "spell_cast"
const SFX_GATE_OPEN := "gate_open"
const SFX_LOOT_PICKUP := "loot_pickup"

const MUSIC_ROOT := "res://assets/Music"
const SFX_LIBRARY := {
	SFX_UI_CONFIRM: "res://assets/SFX/ui_confirm_01.ogg",
	SFX_UI_CANCEL: "res://assets/SFX/ui_cancel_01.ogg",
	SFX_DIALOGUE_ADVANCE: "res://assets/SFX/dialogue_advance_01.ogg",
	SFX_STEP_TOWN: "res://assets/SFX/step_town_01.ogg",
	SFX_STEP_MINE: "res://assets/SFX/step_mine_01.ogg",
	SFX_ATTACK_SWING: "res://assets/SFX/attack_swing_01.ogg",
	SFX_ATTACK_HIT: "res://assets/SFX/attack_hit_01.ogg",
	SFX_SPELL_CAST: "res://assets/SFX/spell_cast_01.ogg",
	SFX_GATE_OPEN: "res://assets/SFX/gate_open_01.ogg",
	SFX_LOOT_PICKUP: "res://assets/SFX/loot_pickup_01.ogg",
}

var _music_catalog: Dictionary = {}
var _stream_cache: Dictionary = {}
var _music_players: Array[AudioStreamPlayer] = []
var _sfx_players: Array[AudioStreamPlayer] = []
var _active_music_index := 0
var _current_cue_id := ""
var _current_variant := ""
var _current_music_path := ""
var _last_sfx_id := ""
var _sfx_history: Array[String] = []

func _ready() -> void:
	_build_music_catalog()
	_ensure_players()

func play_music(cue_id: String, variant: String = "primary", restart: bool = false, fade_seconds: float = 0.35) -> void:
	_ensure_players()
	var cue_entry: Dictionary = _music_catalog.get(cue_id, {})
	if cue_entry.is_empty():
		push_warning("AudioManager: unknown music cue '%s'." % cue_id)
		return

	var resolved_variant := variant if cue_entry.has(variant) else "primary"
	var resource_path := str(cue_entry.get(resolved_variant, ""))
	if resource_path == "":
		push_warning("AudioManager: cue '%s' has no '%s' variant." % [cue_id, resolved_variant])
		return

	if not restart and resource_path == _current_music_path:
		var active_player := _music_players[_active_music_index]
		if active_player.playing:
			return

	var stream := _load_stream(resource_path)
	if stream == null:
		push_warning("AudioManager: failed to load music stream '%s'." % resource_path)
		return

	var incoming_index := 1 - _active_music_index
	var incoming_player := _music_players[incoming_index]
	var outgoing_player := _music_players[_active_music_index]
	incoming_player.stream = stream
	incoming_player.volume_db = -40.0 if fade_seconds > 0.0 else 0.0
	incoming_player.play()

	var tween := create_tween()
	if fade_seconds > 0.0:
		tween.tween_property(incoming_player, "volume_db", 0.0, fade_seconds)
		if outgoing_player.playing:
			tween.parallel().tween_property(outgoing_player, "volume_db", -40.0, fade_seconds)
			tween.parallel().tween_callback(Callable(outgoing_player, "stop")).set_delay(fade_seconds)
	else:
		if outgoing_player.playing:
			outgoing_player.stop()

	_active_music_index = incoming_index
	_current_cue_id = cue_id
	_current_variant = resolved_variant
	_current_music_path = resource_path

func stop_music(fade_seconds: float = 0.35) -> void:
	_ensure_players()
	var active_player := _music_players[_active_music_index]
	if not active_player.playing:
		_current_cue_id = ""
		_current_variant = ""
		_current_music_path = ""
		return

	if fade_seconds <= 0.0:
		active_player.stop()
		_current_cue_id = ""
		_current_variant = ""
		_current_music_path = ""
		return

	var tween := create_tween()
	tween.tween_property(active_player, "volume_db", -40.0, fade_seconds)
	tween.tween_callback(Callable(active_player, "stop"))
	_current_cue_id = ""
	_current_variant = ""
	_current_music_path = ""

func play_sfx(sfx_id: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	_ensure_players()
	var resource_path := str(SFX_LIBRARY.get(sfx_id, ""))
	if resource_path == "":
		push_warning("AudioManager: unknown SFX id '%s'." % sfx_id)
		return

	var stream := _load_stream(resource_path)
	if stream == null:
		push_warning("AudioManager: failed to load SFX '%s'." % resource_path)
		return

	var chosen_player: AudioStreamPlayer = _sfx_players[0]
	for player in _sfx_players:
		if not player.playing:
			chosen_player = player
			break

	chosen_player.stream = stream
	chosen_player.volume_db = volume_db
	chosen_player.pitch_scale = pitch_scale
	_last_sfx_id = sfx_id
	_sfx_history.append(sfx_id)
	if _sfx_history.size() > 16:
		_sfx_history.pop_front()
	chosen_player.play()

func get_current_cue_id() -> String:
	return _current_cue_id

func get_current_variant() -> String:
	return _current_variant

func get_music_catalog() -> Dictionary:
	return _music_catalog.duplicate(true)

func get_last_sfx_id() -> String:
	return _last_sfx_id

func get_sfx_history() -> Array[String]:
	return _sfx_history.duplicate()

func clear_sfx_history() -> void:
	_last_sfx_id = ""
	_sfx_history.clear()

func _build_music_catalog() -> void:
	_music_catalog.clear()
	var files := DirAccess.get_files_at(MUSIC_ROOT)
	if files.is_empty():
		return

	var grouped: Dictionary = {
		CUE_TOWN: {},
		CUE_MINE: {},
		CUE_BATTLE: {},
		CUE_BOSS: {},
		CUE_MORAL_CHOICE: {},
		CUE_VICTORY_EXIT: {},
	}

	for file_name in files:
		var lower_name := file_name.to_lower()
		if not lower_name.ends_with(".mp3"):
			continue

		var cue_id := ""
		if lower_name.contains("town theme"):
			cue_id = CUE_TOWN
		elif lower_name.contains("mine_dungeon ambient"):
			cue_id = CUE_MINE
		elif lower_name.contains("battle theme"):
			cue_id = CUE_BATTLE
		elif lower_name.contains("boss theme"):
			cue_id = CUE_BOSS
		elif lower_name.contains("moral choice sting"):
			cue_id = CUE_MORAL_CHOICE
		elif lower_name.contains("victory") and lower_name.contains("main theme seed"):
			cue_id = CUE_VICTORY_EXIT

		if cue_id == "":
			continue

		var variant := "primary" if lower_name.contains(" 1.") or lower_name.ends_with("1.mp3") else "fallback"
		grouped[cue_id][variant] = "%s/%s" % [MUSIC_ROOT, file_name]

	for cue_id in grouped.keys():
		var cue_entry: Dictionary = grouped[cue_id]
		if cue_entry.has("primary") and cue_entry.has("fallback"):
			_music_catalog[cue_id] = cue_entry
		elif cue_entry.has("primary"):
			_music_catalog[cue_id] = {
				"primary": cue_entry["primary"],
				"fallback": cue_entry["primary"],
			}
		elif cue_entry.has("fallback"):
			_music_catalog[cue_id] = {
				"primary": cue_entry["fallback"],
				"fallback": cue_entry["fallback"],
			}

func _ensure_players() -> void:
	if _music_players.is_empty():
		for index in range(2):
			var player := AudioStreamPlayer.new()
			player.name = "MusicPlayer%d" % index
			player.bus = "Master"
			player.volume_db = -40.0
			add_child(player)
			_music_players.append(player)

	if _sfx_players.is_empty():
		for index in range(8):
			var player := AudioStreamPlayer.new()
			player.name = "SfxPlayer%d" % index
			player.bus = "Master"
			add_child(player)
			_sfx_players.append(player)

func _load_stream(resource_path: String) -> AudioStream:
	if _stream_cache.has(resource_path):
		return _stream_cache[resource_path] as AudioStream

	if not ResourceLoader.exists(resource_path):
		return null

	var stream := load(resource_path)
	if stream is AudioStream:
		_stream_cache[resource_path] = stream
		return stream as AudioStream
	return null
