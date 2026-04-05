# Technical Spike — Progress Log

## Goal
Prove four things before building the game.

## Success criteria
- [x] Walk on map → Movement skill increments in debug panel
- [ ] Press attack in battle → Strength increments
- [ ] Clock runs across all four state transitions without pausing
- [ ] Pure/Mix flag → NPC shows different dialogue line

## Day log

### Day 1 — Autoloads + scaffold
- [x] SignalBus.gd — all game signals declared
- [x] StatRegistry.gd — full stat tree, action modifier map, temp modifiers
- [x] GameClock.gd — always-on clock, speed multiplier, day/night cycle
- [x] PlayerData.gd — class, path, flags, ghost flags, age, inventory sketch
- [x] project.godot — autoloads registered
- [x] Folder structure created
- [x] Stat registry design doc

### Day 2 — SceneManager + Map
- [x] `SceneManager.gd` added as an autoload for exclusive state changes
- [x] `Main.tscn` / `Main.gd` added as the permanent scene shell
- [x] `Map.tscn` / `Map.gd` added with bounded 4-direction placeholder movement
- [x] `DebugPanel.tscn` / `DebugPanel.gd` added as a persistent overlay
- [x] `project.godot` updated with `move_*` actions for `WASD` + arrow keys
- [x] Walking emits `SignalBus.action_performed({ "type": "walk" })` on step intervals
- [x] Debug panel shows live state, clock, flags, and stat values
- [x] Proof complete: walking increments `physical.movement` by `0.02` and displays immediately

### Day 3 — Battle scene
- [ ] Add `Battle.tscn` + `Battle.gd`
- [ ] Add a temporary trigger from map into battle through `SceneManager.change_state("battle")`
- [ ] Add `Attack` and `Cast Spell` buttons
- [ ] Emit `SignalBus.action_performed({ "type": "attack" })` and `SignalBus.action_performed({ "type": "cast" })`
- [ ] Return to map through `SceneManager`
- [ ] Verify the clock and debug overlay persist across the map → battle → map round-trip

### Day 4 — HUD + Cutscene
TODO

### Day 5 — Wire + verify
TODO
