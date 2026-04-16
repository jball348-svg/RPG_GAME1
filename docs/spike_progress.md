# Technical Spike - Progress Log

## Status

The technical spike is complete and archived.

What it proved:
- map movement and stat events
- battle action wiring
- clock continuity across states
- Pure/Mixed-aware dialogue branching
- the four-state shell that the later slice was built on

This file is now historical reference, not an active plan.

---

## Goal

Prove the foundational scene architecture and systemic loops before vertical-slice production began.

---

## Success Criteria

- [x] Walk on map -> Movement skill increments in the debug panel
- [x] Press attack in battle -> Strength increments
- [x] Clock runs across the four state transitions without pausing
- [x] Pure/Mixed flag -> NPC shows different dialogue line

---

## Day Log

### Day 1 - Autoloads and scaffold

- [x] `SignalBus.gd`
- [x] `StatRegistry.gd`
- [x] `GameClock.gd`
- [x] `PlayerData.gd`
- [x] autoload registration in `project.godot`
- [x] initial folder structure
- [x] stat-registry design doc

### Day 2 - SceneManager and map

- [x] `SceneManager.gd` added as the exclusive state-transition owner
- [x] `Main.tscn` and `Main.gd` added as the permanent shell
- [x] `Map.tscn` and `Map.gd` added with bounded four-direction movement
- [x] `DebugPanel.tscn` and `DebugPanel.gd` added as a persistent overlay
- [x] walking emits `SignalBus.action_performed({ "type": "walk" })`
- [x] debug panel displays live stats, flags, and clock
- [x] movement stat proof completed

### Day 3 - Battle scene

- [x] `Battle.tscn` and `Battle.gd` added as the first battle proof
- [x] debug battle trigger added on `B`
- [x] battle actions for `Attack`, `Cast Spell`, and `Return to Map`
- [x] map -> battle -> map round-trip confirmed
- [x] attack and cast stat increments confirmed

### Day 4 - HUD and cutscene

- [x] HUD overlay added under `OverlayHost`
- [x] HUD toggle added on `H`
- [x] map movement blocked while HUD is open
- [x] clock continues while HUD is open
- [x] cutscene trigger added on `C`
- [x] path-dependent dialogue proof added
- [x] cutscene returns to map through `SceneManager`

### Day 5 - Wire and verify

- [x] blank `chosen_path` defaults to `pure`
- [x] path switching reflects immediately in debug UI and HUD
- [x] cutscene branch changes with Pure vs Mixed
- [x] battle proof rerun after the full shell wiring
- [x] all remaining spike success criteria closed

---

## Spike Outcome

The spike shipped the architecture that the vertical slice later expanded:
- persistent main shell
- exclusive scene-state transitions
- map, battle, HUD, and cutscene separation
- stat/event plumbing
- debug-first validation tools

No spike work remains open in this repo.
