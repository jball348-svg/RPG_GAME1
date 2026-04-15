extends Control

const UI_PANEL_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/panel_brown.png"
const UI_BUTTON_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/buttonLong_brown.png"
const UI_BUTTON_PRESSED_TEXTURE_PATH := "res://assets/art/UI/kenney_ui-pack-rpg-expansion/PNG/buttonLong_brown_pressed.png"

@onready var _level_value_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LevelValueLabel
@onready var _continue_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContinueButton
@onready var _panel: PanelContainer = $CenterContainer/PanelContainer

var _panel_texture: Texture2D
var _button_texture: Texture2D
var _button_pressed_texture: Texture2D

func _ready() -> void:
	visible = false
	SignalBus.level_up.connect(_on_level_up)
	_continue_button.pressed.connect(_on_continue_pressed)
	
	_panel_texture = _load_texture(UI_PANEL_TEXTURE_PATH)
	_button_texture = _load_texture(UI_BUTTON_TEXTURE_PATH)
	_button_pressed_texture = _load_texture(UI_BUTTON_PRESSED_TEXTURE_PATH)
	
	_panel.add_theme_stylebox_override("panel", _make_panel_style(_panel_texture))
	_apply_button_style(_continue_button)

func _on_level_up(level: int) -> void:
	_level_value_label.text = "Reached Level %d!" % level
	visible = true
	_continue_button.grab_focus()

func _on_continue_pressed() -> void:
	visible = false

func _load_texture(resource_path: String) -> Texture2D:
	if ResourceLoader.exists(resource_path, "Texture2D") or ResourceLoader.exists(resource_path):
		var texture := load(resource_path)
		if texture is Texture2D:
			return texture as Texture2D
	var image := Image.load_from_file(ProjectSettings.globalize_path(resource_path))
	if image == null or image.is_empty():
		return null
	return ImageTexture.create_from_image(image)

func _make_panel_style(texture: Texture2D) -> StyleBox:
	if texture == null:
		var fallback := StyleBoxFlat.new()
		fallback.bg_color = Color(0.16, 0.12, 0.08, 0.96)
		fallback.corner_radius_top_left = 10
		fallback.corner_radius_top_right = 10
		fallback.corner_radius_bottom_right = 10
		fallback.corner_radius_bottom_left = 10
		fallback.content_margin_left = 10
		fallback.content_margin_right = 10
		fallback.content_margin_top = 10
		fallback.content_margin_bottom = 10
		return fallback

	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = 16
	style.texture_margin_top = 8
	style.texture_margin_right = 16
	style.texture_margin_bottom = 8
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	return style

func _apply_button_style(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _make_button_style(_button_texture))
	button.add_theme_stylebox_override("hover", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))
	button.add_theme_stylebox_override("pressed", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))
	button.add_theme_stylebox_override("focus", _make_button_style(_button_pressed_texture if _button_pressed_texture != null else _button_texture))

func _make_button_style(texture: Texture2D) -> StyleBox:
	if texture == null:
		var fallback := StyleBoxFlat.new()
		fallback.bg_color = Color(0.30, 0.20, 0.10, 1.0)
		return fallback

	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = 14
	style.texture_margin_top = 6
	style.texture_margin_right = 14
	style.texture_margin_bottom = 6
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	return style
