# RPG_GAME1

An archetypal high fantasy RPG. You choose at the start whether you are **Pure** (one class, optionally specialised) or **Mixed** (multiclass, versatile but diluted). This choice drives the game's central conflict — a war between Pure and Mixed factions — and every NPC, faction, and moral decision responds to it. The allegory is intentional.

Built solo in Godot 4 (GDScript). Target platform: PC / Steam.

---

## Status

Currently in production — building the vertical slice (core loop playable start to finish).

| Phase | Status |
|---|---|
| Pre-production | ✅ Complete |
| Technical spike | ✅ Complete |
| Vertical slice | 🔄 In progress — Stage 2 of 9 |

See `docs/vertical_slice_plan.md` for the full stage breakdown.

---

## Setup

1. Install Godot 4.6+
2. Clone this repo
3. Open Godot → Import → select this folder
4. Run the project (`F5`) or open `scenes/main/Main.tscn`
5. The game boots into the starting town map

**Movement:** `WASD` or arrow keys  
**Dev controls (spike era, will be removed):** `B` battle · `H` HUD · `C` cutscene · `1` Pure path · `2` Mixed path

---

## Architecture

```
autoloads/        Global singletons — always running
  SignalBus.gd    All game signals
  StatRegistry.gd Stat tree, action modifiers, Luck derivation
  GameClock.gd    Always-on clock, never pauses
  PlayerData.gd   Class, path, flags, ghost flags, age, equipment
  SceneManager.gd Game state loader (Map / Battle / HUD / Cutscene)
scenes/
  main/           Entry point and persistent overlay host
  map/            Top-down map state
  battle/         Turn-based battle state
  hud/            HUD overlay (stat summary, equipment, inventory)
  cutscene/       Scripted sequence state
  debug/          Dev-only stat/clock overlay (removed before release)
assets/
  art/            Mood boards and sourced tilesets
docs/
  HANDOVER.md           LLM agent context — source of truth
  vertical_slice_plan.md Stage-by-stage build plan
  stat_registry.md       Stat design reference
  art_direction.md       All visual decisions and asset rules
```

---

## Design

- **Stat system:** 6 top-level stats (Physical, Magik, Intelligence, Social, Will, Holy), each with sub-skills that increase through use — Oblivion-style. Every action feeds something.
- **Visibility tiers:** Some stats always shown, some unlock at milestones, some are ghost stats the player never sees but always feels.
- **Pure vs Mixed:** Not just a class choice — a political identity. The world responds.
- **Time:** An always-on clock that never pauses. Age is a stat. Buffs expire. The world ticks while you read menus.

Full design documentation in `docs/`.
