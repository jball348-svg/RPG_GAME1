extends Node

const DEBUG_PANEL_SCENE: PackedScene = preload("res://scenes/debug/DebugPanel.tscn")

@onready var state_host: Node = $StateHost
@onready var overlay_host: CanvasLayer = $OverlayHost

func _ready() -> void:
	_ensure_debug_panel()
	SceneManager.configure_hosts(state_host, overlay_host)
	SceneManager.change_state("map")

func _ensure_debug_panel() -> void:
	if overlay_host.get_node_or_null("DebugPanel") != null:
		return

	var debug_panel: Control = DEBUG_PANEL_SCENE.instantiate() as Control
	debug_panel.name = "DebugPanel"
	overlay_host.add_child(debug_panel)
