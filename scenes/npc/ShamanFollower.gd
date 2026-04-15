extends Node2D

const FOLLOW_SPEED := 190.0
const FOLLOW_OFFSET := Vector2(-20.0, 14.0)

@onready var sprite: AnimatedSprite2D = $Sprite

var _target: Node2D
var _facing := "down"

func configure(target: Node2D, sprite_frames: SpriteFrames, tint: Color, sprite_scale: Vector2) -> void:
	_target = target
	if sprite_frames != null:
		sprite.sprite_frames = sprite_frames
	sprite.modulate = tint
	sprite.scale = sprite_scale
	_play_idle()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_target):
		return

	var desired_position := _target.global_position + FOLLOW_OFFSET
	var to_target := desired_position - global_position
	if to_target.length() <= 1.0:
		_play_idle()
		return

	var movement := to_target.normalized() * minf(to_target.length(), FOLLOW_SPEED * delta)
	global_position += movement
	_play_walk(movement)

func _play_walk(movement: Vector2) -> void:
	var direction := _direction_from_vector(movement)
	_facing = direction
	var animation_name := "walk_%s" % direction
	if sprite.animation != animation_name:
		sprite.play(animation_name)
	elif not sprite.is_playing():
		sprite.play()

func _play_idle() -> void:
	var animation_name := "idle_%s" % _facing
	if sprite.animation != animation_name:
		sprite.play(animation_name)
	elif not sprite.is_playing():
		sprite.play()

func _direction_from_vector(movement: Vector2) -> String:
	if absf(movement.x) > absf(movement.y):
		return "right" if movement.x > 0.0 else "left"
	if movement.y < 0.0:
		return "up"
	return "down"
