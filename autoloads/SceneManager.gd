# SceneManager.gd
# Owns exclusive game-state scene changes for the spike.
# Map, Battle, and Cutscene live here; HUD/debug overlays stay persistent elsewhere.
extends Node

const STATE_SCENES: Dictionary = {
	"map": "res://scenes/map/Map.tscn",
	"battle": "res://scenes/battle/Battle.tscn",
	"cutscene": "res://scenes/cutscene/Cutscene.tscn",
}

var current_state_name: String = ""
var current_state_scene: Node = null
var current_state_payload: Dictionary = {}

var _state_host: Node = null
var _overlay_host: CanvasLayer = null

func configure_hosts(state_host: Node, overlay_host: CanvasLayer) -> void:
	_state_host = state_host
	_overlay_host = overlay_host

func get_overlay_host() -> CanvasLayer:
	return _overlay_host

func get_screen_fader():
	if _overlay_host == null:
		return null
	return _overlay_host.get_node_or_null("ScreenFader")

func get_state_payload() -> Dictionary:
	return current_state_payload.duplicate(true)

func consume_state_payload() -> Dictionary:
	var payload := current_state_payload.duplicate(true)
	current_state_payload.clear()
	return payload

func clear_state_payload() -> void:
	current_state_payload.clear()

func change_state(new_state: String, payload: Dictionary = {}, force_reload: bool = false) -> bool:
	if _state_host == null:
		push_error("SceneManager has no state host configured.")
		return false

	if not force_reload and new_state == current_state_name and is_instance_valid(current_state_scene):
		current_state_payload = payload.duplicate(true)
		return true

	if not STATE_SCENES.has(new_state):
		push_error("Unknown state requested: %s" % new_state)
		return false

	var scene_path: String = STATE_SCENES[new_state]
	if not ResourceLoader.exists(scene_path):
		push_warning("State scene is not implemented yet: %s" % scene_path)
		return false

	var packed_scene: PackedScene = load(scene_path) as PackedScene
	if packed_scene == null:
		push_error("Failed to load state scene: %s" % scene_path)
		return false

	current_state_payload = payload.duplicate(true)

	if is_instance_valid(current_state_scene):
		_state_host.remove_child(current_state_scene)
		current_state_scene.queue_free()
		current_state_scene = null

	var next_scene: Node = packed_scene.instantiate()
	_state_host.add_child(next_scene)

	var previous_state: String = current_state_name
	current_state_name = new_state
	current_state_scene = next_scene
	SignalBus.state_changed.emit(previous_state, new_state)
	return true
