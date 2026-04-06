# SignalBus.gd
# Global signal declarations. Every game event passes through here.
# Nothing else lives in this file — just signals.
# Any scene or system can emit or connect to these without direct references.
extends Node

# --- Action signals ---
# Emitted whenever the player performs any tracked action.
# payload: Dictionary with keys relevant to the action type.
# e.g. { "type": "walk", "location": "town", "companions": 0 }
signal action_performed(payload: Dictionary)

# --- Stat signals ---
# Emitted by StatRegistry after it processes a stat change.
# Anything that displays stats (HUD, debug panel) listens here.
signal stat_changed(stat_path: String, new_value: float)

# --- Clock signals ---
# Emitted by GameClock on every in-game time increment.
signal clock_ticked(in_game_time: Dictionary)
# Emitted when a new in-game day begins.
signal new_day(day_number: int)

# --- State signals ---
# Emitted by SceneManager when the game changes state.
signal state_changed(from_state: String, to_state: String)

# --- Dialogue signals ---
# Emitted by DialogueManager when an NPC conversation starts or ends.
signal dialogue_started(npc_id: String)
signal dialogue_ended(npc_id: String)

# --- Flag signals ---
# Emitted when a major player flag is set (Pure/Mix choice, moral decisions).
signal flag_set(flag_name: String, value: Variant)
