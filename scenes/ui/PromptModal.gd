extends Control

signal confirmed(prompt_id: String)
signal canceled(prompt_id: String)
signal opened
signal closed

const REFERENCE_VIEWPORT_SIZE := Vector2(480.0, 270.0)
const COMPACT_VIEWPORT_WIDTH := 640.0
const COMPACT_VIEWPORT_HEIGHT := 360.0

@onready var backdrop: ColorRect = $Backdrop
@onready var panel: PanelContainer = $Panel
@onready var margin: MarginContainer = $Panel/Margin
@onready var title_label: Label = $Panel/Margin/Content/TitleLabel
@onready var body_label: Label = $Panel/Margin/Content/BodyLabel
@onready var confirm_button: Button = $Panel/Margin/Content/ButtonRow/ConfirmButton
@onready var cancel_button: Button = $Panel/Margin/Content/ButtonRow/CancelButton

var _prompt_id := ""
var _is_open := false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

	if not get_viewport().size_changed.is_connected(_on_viewport_size_changed):
		get_viewport().size_changed.connect(_on_viewport_size_changed)

	SignalBus.state_changed.connect(_on_state_changed)
	_apply_layout_for_viewport()

func show_prompt(prompt_id: String, title: String, body: String, confirm_text: String, cancel_text: String) -> void:
	_prompt_id = prompt_id
	_is_open = true
	title_label.text = title
	body_label.text = body
	confirm_button.text = confirm_text
	cancel_button.text = cancel_text
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_layout_for_viewport()
	confirm_button.grab_focus()
	opened.emit()

func hide_prompt() -> void:
	if not _is_open:
		return

	_is_open = false
	_prompt_id = ""
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	closed.emit()

func is_open() -> bool:
	return _is_open

func _on_viewport_size_changed() -> void:
	_apply_layout_for_viewport()

func _apply_layout_for_viewport() -> void:
	var viewport_size := get_viewport_rect().size
	var compact_layout := viewport_size.x <= COMPACT_VIEWPORT_WIDTH or viewport_size.y <= COMPACT_VIEWPORT_HEIGHT
	var horizontal_margin := 20.0 if compact_layout else 44.0
	var vertical_margin := 20.0 if compact_layout else 28.0
	var panel_width := clampf(viewport_size.x * 0.72, 232.0, 332.0)
	var panel_height := clampf(viewport_size.y * 0.48, 112.0, 152.0)

	backdrop.color = Color(0.0, 0.0, 0.0, 0.64)
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -panel_width * 0.5
	panel.offset_top = -panel_height * 0.5
	panel.offset_right = panel_width * 0.5
	panel.offset_bottom = panel_height * 0.5

	margin.add_theme_constant_override("margin_left", int(horizontal_margin))
	margin.add_theme_constant_override("margin_top", int(vertical_margin))
	margin.add_theme_constant_override("margin_right", int(horizontal_margin))
	margin.add_theme_constant_override("margin_bottom", int(vertical_margin))
	title_label.add_theme_font_size_override("font_size", 10 if compact_layout else 11)
	body_label.add_theme_font_size_override("font_size", 8 if compact_layout else 9)
	confirm_button.add_theme_font_size_override("font_size", 8 if compact_layout else 9)
	cancel_button.add_theme_font_size_override("font_size", 8 if compact_layout else 9)
	confirm_button.custom_minimum_size = Vector2(_scaled_x(84.0), _scaled_y(24.0))
	cancel_button.custom_minimum_size = Vector2(_scaled_x(84.0), _scaled_y(24.0))

func _scaled_x(reference_width: float) -> float:
	return reference_width * get_viewport_rect().size.x / REFERENCE_VIEWPORT_SIZE.x

func _scaled_y(reference_height: float) -> float:
	return reference_height * get_viewport_rect().size.y / REFERENCE_VIEWPORT_SIZE.y

func _on_confirm_pressed() -> void:
	if not _is_open:
		return

	var prompt_id := _prompt_id
	hide_prompt()
	confirmed.emit(prompt_id)

func _on_cancel_pressed() -> void:
	if not _is_open:
		return

	var prompt_id := _prompt_id
	hide_prompt()
	canceled.emit(prompt_id)

func _on_state_changed(_from_state: String, to_state: String) -> void:
	if to_state != "map" and _is_open:
		hide_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if not _is_open:
		return

	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_on_confirm_pressed()
		return

	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_cancel_pressed()
