extends Node2D

@export var npc_id: String = ""
@export var npc_name: String = ""
@export var actor_id: String = ""

@onready var interaction_zone: Area2D = $InteractionZone

var _player_in_range: bool = false

func _ready() -> void:
	if not interaction_zone.body_entered.is_connected(_on_body_entered):
		interaction_zone.body_entered.connect(_on_body_entered)
	if not interaction_zone.body_exited.is_connected(_on_body_exited):
		interaction_zone.body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range:
		return
	if DialogueManager.is_active():
		return
	if npc_id == "":
		return

	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		DialogueManager.start_dialogue(npc_id)

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		_player_in_range = true

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		_player_in_range = false
