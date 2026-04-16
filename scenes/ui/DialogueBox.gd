extends Control

const COMPACT_VIEWPORT_WIDTH := 640.0
const COMPACT_VIEWPORT_HEIGHT := 360.0

@onready var panel: PanelContainer = $Panel
@onready var margin: MarginContainer = $Panel/Margin
@onready var content: HBoxContainer = $Panel/Margin/Content
@onready var portrait_rect: TextureRect = $Panel/Margin/Content/Portrait
@onready var speaker_label: Label = $Panel/Margin/Content/RightColumn/SpeakerLabel
@onready var body_label: Label = $Panel/Margin/Content/RightColumn/BodyLabel
@onready var advance_prompt: Label = $Panel/Margin/Content/RightColumn/Footer/AdvancePrompt

var _placeholder_portrait: Texture2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	
	_placeholder_portrait = portrait_rect.texture
	advance_prompt.text = "▶ E to continue"
	_apply_layout_for_viewport()

	if not get_viewport().size_changed.is_connected(_on_viewport_size_changed):
		get_viewport().size_changed.connect(_on_viewport_size_changed)

	SignalBus.dialogue_started.connect(_on_dialogue_started)
	SignalBus.dialogue_ended.connect(_on_dialogue_ended)

func _on_viewport_size_changed() -> void:
	_apply_layout_for_viewport()

func _apply_layout_for_viewport() -> void:
	var viewport_size := get_viewport_rect().size
	var compact_layout := viewport_size.x <= COMPACT_VIEWPORT_WIDTH or viewport_size.y <= COMPACT_VIEWPORT_HEIGHT

	panel.anchor_left = 0.0
	panel.anchor_top = 0.74 if compact_layout else 0.78
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 8.0 if compact_layout else 20.0
	panel.offset_right = -8.0 if compact_layout else -20.0

	margin.add_theme_constant_override("margin_left", 4 if compact_layout else 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 4 if compact_layout else 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	content.add_theme_constant_override("separation", 6 if compact_layout else 8)

	portrait_rect.custom_minimum_size = Vector2(34.0, 34.0) if compact_layout else Vector2(40.0, 40.0)
	speaker_label.add_theme_font_size_override("font_size", 11 if compact_layout else 12)
	body_label.add_theme_font_size_override("font_size", 9 if compact_layout else 10)
	advance_prompt.add_theme_font_size_override("font_size", 8 if compact_layout else 9)

func _unhandled_input(event: InputEvent) -> void:
	if not DialogueManager.is_active():
		return

	if event.is_action_pressed("interact") or _is_space_pressed(event):
		get_viewport().set_input_as_handled()
		AudioManager.play_sfx(AudioManager.SFX_DIALOGUE_ADVANCE, -5.0)
		DialogueManager.advance()
		_refresh_from_current_node()

func _on_dialogue_started(_npc_id: String) -> void:
	visible = true
	_refresh_from_current_node()

func _on_dialogue_ended(_npc_id: String) -> void:
	visible = false
	speaker_label.text = ""
	body_label.text = ""
	portrait_rect.texture = _placeholder_portrait

func _refresh_from_current_node() -> void:
	if not DialogueManager.is_active():
		return

	var node: Dictionary = DialogueManager.get_current_node()
	if node.is_empty():
		return

	speaker_label.text = str(node.get("speaker", ""))
	body_label.text = str(node.get("text", ""))
	_apply_portrait(str(node.get("portrait", "")), str(node.get("portrait_id", "")))

func _apply_portrait(portrait_path: String, portrait_id: String = "") -> void:
	if portrait_id != "":
		var portrait_texture := ActorVisuals.get_portrait(portrait_id)
		if portrait_texture != null:
			portrait_rect.texture = portrait_texture
			return

	if portrait_path == "":
		portrait_rect.texture = _placeholder_portrait
		return

	if not ResourceLoader.exists(portrait_path):
		portrait_rect.texture = _placeholder_portrait
		return

	var portrait := load(portrait_path) as Texture2D
	portrait_rect.texture = portrait if portrait != null else _placeholder_portrait

func _is_space_pressed(event: InputEvent) -> bool:
	if not (event is InputEventKey):
		return false

	var key_event := event as InputEventKey
	return key_event.pressed and not key_event.echo and key_event.keycode == KEY_SPACE
