extends Control

@onready var panel: PanelContainer = $Panel
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

	SignalBus.dialogue_started.connect(_on_dialogue_started)
	SignalBus.dialogue_ended.connect(_on_dialogue_ended)

func _unhandled_input(event: InputEvent) -> void:
	if not DialogueManager.is_active():
		return

	if event.is_action_pressed("interact") or _is_space_pressed(event):
		get_viewport().set_input_as_handled()
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
	_apply_portrait(str(node.get("portrait", "")))

func _apply_portrait(portrait_path: String) -> void:
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
