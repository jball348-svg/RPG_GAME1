extends Node

const HUD_SCENE: PackedScene = preload("res://scenes/hud/HUD.tscn")
const DEBUG_PANEL_SCENE: PackedScene = preload("res://scenes/debug/DebugPanel.tscn")
const DIALOGUE_BOX_SCENE: PackedScene = preload("res://scenes/ui/DialogueBox.tscn")
const PROMPT_MODAL_SCENE: PackedScene = preload("res://scenes/ui/PromptModal.tscn")

@onready var state_host: Node = $StateHost
@onready var overlay_host: CanvasLayer = $OverlayHost

func _ready() -> void:
	SceneManager.configure_hosts(state_host, overlay_host)
	_ensure_spike_hud()
	_ensure_debug_panel()
	_ensure_dialogue_box()
	_ensure_prompt_modal()
	SceneManager.change_state("map")

func _ensure_spike_hud() -> void:
	if overlay_host.get_node_or_null("SpikeHUD") != null:
		return

	var hud: Control = HUD_SCENE.instantiate() as Control
	hud.name = "SpikeHUD"
	hud.z_index = 20
	overlay_host.add_child(hud)

func _ensure_debug_panel() -> void:
	if overlay_host.get_node_or_null("DebugPanel") != null:
		return

	var debug_panel: Control = DEBUG_PANEL_SCENE.instantiate() as Control
	debug_panel.name = "DebugPanel"
	debug_panel.z_index = 5
	overlay_host.add_child(debug_panel)

func _ensure_dialogue_box() -> void:
	if overlay_host.get_node_or_null("DialogueBox") != null:
		return

	var dialogue_box: Control = DIALOGUE_BOX_SCENE.instantiate() as Control
	dialogue_box.name = "DialogueBox"
	dialogue_box.z_index = 30
	overlay_host.add_child(dialogue_box)

func _ensure_prompt_modal() -> void:
	if overlay_host.get_node_or_null("PromptModal") != null:
		return

	var prompt_modal: Control = PROMPT_MODAL_SCENE.instantiate() as Control
	prompt_modal.name = "PromptModal"
	prompt_modal.z_index = 40
	overlay_host.add_child(prompt_modal)
