extends Node

var dialogue_trees: Dictionary = {
	"intel_npc": [
		{
			"speaker": "Village Guard",
			"text": "The Kobold leader is a half-breed Shaman. Take fire and coin.",
			"portrait": "",
			"conditions": [
				{"type": "stat_gte", "stat": "social.charm", "value": 10.0},
				{"type": "gold_gte", "value": 20},
			],
			"fallback": 1,
			"next": -1,
		},
		{
			"speaker": "Village Guard",
			"text": "The mine's blocked. Something's taken up in there.",
			"portrait": "",
			"conditions": [],
			"next": -1,
		},
	],
	"moral_choice_npc": [
		{
			"speaker": "Traveling Merchant",
			"text": "I passed a creature on the road - part Kobold, part something else. Leading them, it was. Whether you kill it or parley... that'll say something about you.",
			"portrait": "",
			"conditions": [
				{"type": "flag_set", "flag": "shaman_warning_given", "negate": true},
			],
			"set_flags": [
				{"flag": "shaman_warning_given", "value": true},
			],
			"next": -1,
		},
	],
	"bookstore_npc": [
		{
			"speaker": "Bookstore Keeper",
			"text": "Ah, a student of Destruction. This tome is yours.",
			"portrait": "",
			"conditions": [
				{"type": "stat_gte", "stat": "intelligence.understanding", "value": 10.0},
			],
			"set_flags": [
				{"flag": "destruction_spell_unlocked", "value": true},
			],
			"fallback": 1,
			"next": -1,
		},
		{
			"speaker": "Bookstore Keeper",
			"text": "You lack the understanding to use this. Come back when you've studied more.",
			"portrait": "",
			"conditions": [],
			"next": -1,
		},
	],
}

var _active_npc_id: String = ""
var _active_tree: Array = []
var _current_node_index: int = -1
var _active: bool = false

func start_dialogue(npc_id: String) -> void:
	if npc_id == "":
		return
	if not dialogue_trees.has(npc_id):
		push_warning("DialogueManager: no dialogue tree found for npc_id '%s'." % npc_id)
		return

	if _active:
		_end_dialogue()

	_active_npc_id = npc_id
	_active_tree = dialogue_trees[npc_id]
	_current_node_index = _find_next_visible_node(0)

	if _current_node_index == -1:
		_clear_state()
		return

	_active = true
	SignalBus.dialogue_started.emit(_active_npc_id)

func advance() -> void:
	if not _active:
		return

	var current_node := get_current_node()
	if current_node.is_empty():
		_end_dialogue()
		return

	_apply_node_effects(current_node)

	var next_index: int = int(current_node.get("next", -1))
	if next_index < 0:
		_end_dialogue()
		return

	_current_node_index = _find_next_visible_node(next_index)
	if _current_node_index == -1:
		_end_dialogue()

func get_current_node() -> Dictionary:
	if not _active:
		return {}
	if _current_node_index < 0 or _current_node_index >= _active_tree.size():
		return {}

	var node: Dictionary = _active_tree[_current_node_index]
	return node.duplicate(true)

func is_active() -> bool:
	return _active

func _find_next_visible_node(start_index: int) -> int:
	if start_index < 0:
		return -1

	var index := start_index
	var visited: Dictionary = {}

	while index >= 0 and index < _active_tree.size():
		if visited.has(index):
			push_warning("DialogueManager: circular dialogue fallback detected for '%s'." % _active_npc_id)
			return -1
		visited[index] = true

		var node: Dictionary = _active_tree[index]
		if _node_conditions_pass(node):
			return index

		index = int(node.get("fallback", -1))

	return -1

func _node_conditions_pass(node: Dictionary) -> bool:
	var conditions: Array = node.get("conditions", [])
	if conditions.is_empty():
		return true

	for condition_value in conditions:
		if not (condition_value is Dictionary):
			return false
		if not _condition_passes(condition_value):
			return false

	return true

func _condition_passes(condition: Dictionary) -> bool:
	var condition_type: String = str(condition.get("type", ""))
	match condition_type:
		"stat_gte":
			var stat_path: String = str(condition.get("stat", ""))
			if stat_path == "":
				return false
			return StatRegistry.get_stat(stat_path) >= float(condition.get("value", 0.0))
		"gold_gte":
			return PlayerData.gold >= int(condition.get("value", 0))
		"flag_set":
			var flag_name: String = str(condition.get("flag", ""))
			if flag_name == "":
				return false
			var is_set: bool = bool(PlayerData.get_flag(flag_name, false))
			if bool(condition.get("negate", false)):
				return not is_set
			return is_set
		"pure_path":
			return PlayerData.is_pure()
		"mixed_path":
			return PlayerData.is_mixed()
		_:
			push_warning("DialogueManager: unknown condition type '%s'." % condition_type)
			return false

func _apply_node_effects(node: Dictionary) -> void:
	var flags_to_set: Array = node.get("set_flags", [])
	for value in flags_to_set:
		if not (value is Dictionary):
			continue
		var flag_name: String = str(value.get("flag", ""))
		if flag_name == "":
			continue
		PlayerData.set_flag(flag_name, value.get("value", true))

func _end_dialogue() -> void:
	if not _active:
		_clear_state()
		return

	var finished_npc_id: String = _active_npc_id
	_clear_state()
	SignalBus.dialogue_ended.emit(finished_npc_id)

func _clear_state() -> void:
	_active = false
	_active_npc_id = ""
	_active_tree = []
	_current_node_index = -1
