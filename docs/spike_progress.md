# Technical Spike — Progress Log

## Goal
Prove four things before building the game.

## Success criteria
- [x] Walk on map → Movement skill increments in debug panel
- [x] Press attack in battle → Strength increments
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
- [x] `Battle.tscn` / `Battle.gd` added as a minimal battle proof scene
- [x] `project.godot` updated with `debug_battle` on `B`, plus reserved Day 4 inputs: `toggle_hud`, `debug_cutscene`, `set_path_pure`, `set_path_mixed`
- [x] `Map.tscn` / `Map.gd` updated with an on-screen hint and a temporary map-side `B` trigger into battle through `SceneManager.change_state("battle")`
- [x] Battle scene includes `Attack`, `Cast Spell`, and `Return to Map` buttons
- [x] `Attack` emits `SignalBus.action_performed({ "type": "attack" })`
- [x] `Cast Spell` emits `SignalBus.action_performed({ "type": "cast" })`
- [x] Return path to map goes back through `SceneManager.change_state("map")`
- [x] Proof complete: `attack` increments `physical.strength`, `cast` increments `magik.spellcasting` + `magik.attunement`, and the clock/debug overlay persist across the map → battle → map round-trip

### Day 4 — HUD + Cutscene
- [ ] Add a minimal HUD overlay under `OverlayHost` (not a `SceneManager` state)
- [ ] Toggle HUD on `H` while keeping the map visible underneath
- [ ] Block map movement while HUD is open, but keep the clock running
- [ ] Show placeholder inventory/equipment framing, current clock, current path/class, and a compact stat summary
- [ ] Add a temporary map-side cutscene trigger on `C`
- [ ] Use `PlayerData.chosen_path` as the spike source of truth, defaulting to `pure` if unset
- [ ] Add dev-only allegiance switches: `1` = Pure, `2` = Mixed
- [ ] Create `Cutscene.tscn` / `Cutscene.gd`
- [ ] Run one short scripted placeholder movement sequence
- [ ] Show one of two dialogue lines based on the Pure/Mixed path
- [ ] Return to map through `SceneManager` and verify clock continuity across map, HUD, and cutscene

### Day 5 — Wire + verify
TODO
