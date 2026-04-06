# RPG_GAME1 — Technical Spike

Archetypal fantasy RPG. Pure vs Mixed class allegory. Deep character stat system.

## Spike goal
Prove four things before building the game:
1. Signal bus fires stat events → StatRegistry responds
2. Four game states transition cleanly
3. Clock runs continuously across all state changes
4. Pure/Mix flag influences downstream NPC dialogue

## Setup
1. Open Godot 4 (4.2+)
2. Open this folder as a project
3. Autoloads are pre-configured in `project.godot`
4. Run the project or open `scenes/main/Main.tscn`
5. The Day 4 spike boots straight into the map prototype with the debug overlay visible plus battle, HUD, cutscene, and path-switch proof controls

## Structure
```
autoloads/       — Global singletons (SignalBus, StatRegistry, GameClock, PlayerData, SceneManager)
scenes/          — Game state scenes (Map, Battle, HUD, Cutscene, Main, Debug)
assets/          — Placeholder only during spike
docs/            — Design documents
```

## Spike controls and debug
- Movement: `WASD` or arrow keys
- Enter battle proof: `B`
- Toggle HUD overlay: `H`
- Enter cutscene proof: `C`
- Set path to Pure: `1`
- Set path to Mixed: `2`
- Debug overlay: top-left panel shows current state, clock, player path/flags, and the live stat snapshot
- HUD proof target: `H` opens a full-screen overlay above the map, blocks movement, and keeps the clock running
- Cutscene proof target: `C` runs the placeholder scripted sequence and branches dialogue off the current Pure/Mixed path
- Battle proof target: `B` enters battle, `Attack` increments `physical.strength`, `Cast Spell` increments magik stats, and `Return to Map` preserves the clock + debug overlay

## Day 4 manual runbook
1. Boot into `scenes/main/Main.tscn` and confirm the debug panel shows `Path: pure` if no path was set yet.
2. Walk on the map, open HUD with `H`, and confirm the clock keeps advancing while movement is paused.
3. Press `1`, then `2`, and confirm the path updates immediately in the debug panel and HUD.
4. Press `C` while Pure and confirm the Pure sentry line, then return to map.
5. Press `2`, then `C`, and confirm the Mixed sentry line, then return to map.
6. Press `B` and rerun the battle proof to make sure Day 3 still holds after the Day 4 overlay/cutscene wiring.

## Day progress
- [x] Day 1 — Autoloads + project scaffold
- [x] Day 2 — SceneManager + Map scene
- [x] Day 3 — Battle scene + map round-trip
- [x] Day 4 — HUD + Cutscene implementation
- [ ] Day 5 — Wire + verify all four success criteria
