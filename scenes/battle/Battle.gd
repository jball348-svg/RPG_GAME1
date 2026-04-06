extends Node2D

@onready var attack_button: Button = $UI/BattlePanel/Margin/Content/AttackButton
@onready var cast_spell_button: Button = $UI/BattlePanel/Margin/Content/CastSpellButton
@onready var return_button: Button = $UI/BattlePanel/Margin/Content/ReturnButton

func _ready() -> void:
	PlayerData.current_location = "spike_battle"
	PlayerData.current_region = "debug_arena"

	attack_button.pressed.connect(_on_attack_pressed)
	cast_spell_button.pressed.connect(_on_cast_spell_pressed)
	return_button.pressed.connect(_on_return_pressed)

	queue_redraw()

func _on_attack_pressed() -> void:
	SignalBus.action_performed.emit({"type": "attack"})

func _on_cast_spell_pressed() -> void:
	SignalBus.action_performed.emit({"type": "cast"})

func _on_return_pressed() -> void:
	SceneManager.change_state("map")

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(960.0, 540.0)), Color(0.08, 0.06, 0.12), true)
	draw_rect(Rect2(Vector2(0.0, 340.0), Vector2(960.0, 200.0)), Color(0.16, 0.10, 0.08), true)
	draw_rect(Rect2(Vector2(0.0, 0.0), Vector2(960.0, 540.0)), Color(0.44, 0.28, 0.16), false, 4.0)

	var player_rect := Rect2(Vector2(180.0, 300.0), Vector2(72.0, 112.0))
	draw_rect(player_rect, Color(0.20, 0.62, 0.84), true)
	draw_rect(player_rect, Color(0.04, 0.10, 0.15), false, 3.0)

	var enemy_rect := Rect2(Vector2(700.0, 186.0), Vector2(94.0, 142.0))
	draw_rect(enemy_rect, Color(0.78, 0.24, 0.24), true)
	draw_rect(enemy_rect, Color(0.18, 0.04, 0.04), false, 3.0)
