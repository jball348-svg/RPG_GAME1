# GameClock.gd
# Always-on in-game clock. Never pauses. Never stops.
# Runs at CLOCK_SPEED x real time by default.
# Can be accelerated (rest, wait) via set_speed_multiplier().
# Emits SignalBus.clock_ticked every in-game minute.
# Emits SignalBus.new_day when the in-game day rolls over.
extends Node

# --- Config ---
# 1 real second = CLOCK_SPEED in-game minutes at default speed.
# Default: 1 real second = 2 in-game minutes
# So 1 real hour = 120 in-game hours (5 in-game days). Adjust to taste.
const CLOCK_SPEED: float = 2.0

# --- State ---
var in_game_minute: int = 0
var in_game_hour: int   = 8   # game starts at 8am
var in_game_day: int    = 1
var speed_multiplier: float = 1.0  # 1.0 = normal, 4.0 = resting, 8.0 = sleeping

# Accumulates real-time seconds until a full in-game minute has passed.
var _accumulator: float = 0.0

# Seconds of real time per in-game minute at default speed.
# At CLOCK_SPEED=2: 1 in-game minute = 0.5 real seconds.
var _seconds_per_ingame_minute: float = 1.0 / CLOCK_SPEED

func _ready() -> void:
	pass  # Clock runs via _process — no setup needed.

func _process(delta: float) -> void:
	_accumulator += delta * speed_multiplier

	# Advance one in-game minute per threshold crossed.
	while _accumulator >= _seconds_per_ingame_minute:
		_accumulator -= _seconds_per_ingame_minute
		_tick_minute()

func _tick_minute() -> void:
	in_game_minute += 1

	if in_game_minute >= 60:
		in_game_minute = 0
		in_game_hour += 1

	if in_game_hour >= 24:
		in_game_hour = 0
		in_game_day += 1
		SignalBus.new_day.emit(in_game_day)

	SignalBus.clock_ticked.emit(get_time())

# Returns current in-game time as a Dictionary.
func get_time() -> Dictionary:
	return {
		"day":    in_game_day,
		"hour":   in_game_hour,
		"minute": in_game_minute,
		"display": _format_time(),
	}

# Human-readable time string for HUD display.
func _format_time() -> String:
	var h: String = str(in_game_hour).pad_zeros(2)
	var m: String = str(in_game_minute).pad_zeros(2)
	return "Day %d  %s:%s" % [in_game_day, h, m]

# Accelerate or decelerate the clock.
# 1.0 = normal, 4.0 = resting, 8.0 = sleeping, 24.0 = waiting a full day
func set_speed_multiplier(multiplier: float) -> void:
	speed_multiplier = clamp(multiplier, 1.0, 24.0)

# Reset to normal speed.
func resume_normal_speed() -> void:
	speed_multiplier = 1.0
