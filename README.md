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
5. The Day 2 spike boots straight into the map prototype with the debug overlay visible

## Structure
```
autoloads/       — Global singletons (SignalBus, StatRegistry, GameClock, PlayerData, SceneManager)
scenes/          — Game state scenes (Map, Battle, HUD, Cutscene, Main, Debug)
assets/          — Placeholder only during spike
docs/            — Design documents
```

## Spike controls and debug
- Movement: `WASD` or arrow keys
- Debug overlay: top-left panel shows current state, clock, player path/flags, and the live stat snapshot
- Day 2 proof target: each completed walking step increments `physical.movement` by `0.02`

## Day progress
- [x] Day 1 — Autoloads + project scaffold
- [x] Day 2 — SceneManager + Map scene
- [ ] Day 3 — Battle scene + map round-trip
- [ ] Day 4 — HUD + Cutscene
- [ ] Day 5 — Wire + verify all four success criteria
