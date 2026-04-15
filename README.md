# RPG_GAME1

An archetypal high fantasy RPG. You choose at the start whether you are **Pure** (one class, optionally specialised) or **Mixed** (multiclass, versatile but diluted). This choice drives the game's central conflict - a war between Pure and Mixed factions - and every NPC, faction, and moral decision responds to it. The allegory is intentional.

Built solo in Godot 4 (GDScript). Target platform: PC / Steam.

---

## Status

Currently in production - building the vertical slice (core loop playable start to finish).

| Phase | Status |
|---|---|
| Pre-production | Complete |
| Technical spike | Complete |
| Vertical slice | In progress - Stage 8 complete, Stage 8.5 spec pack published |

Current focus: Stage 8.5 implementation prep. The admin/spec pass is documented and the next implementation pass should execute the Stage 8.5 tickets.

Primary references:
- `docs/vertical_slice_plan.md`
- `docs/HANDOVER.md`
- `docs/stage_8_5_master_plan.md`

---

## Setup

1. Install Godot 4.6+
2. Clone this repo
3. Open Godot -> Import -> select this folder
4. Run the project (`F5`) or open `scenes/main/Main.tscn`
5. The game boots into the starting town map, or loads `user://save_game.json` if a save already exists

**Movement:** `WASD` or arrow keys  
**Current debug controls:** `P` skip battle -> victory, `L` location loader, `B` battle, `H` HUD, `C` cutscene, `1` Pure path, `2` Mixed path, `3` Social + gold, `4` Intelligence, `0` reset stats

---

## Current slice snapshot

- Core loop currently playable: Load -> Town -> Leave -> Cutscene -> Mine -> Battles -> Boss choice -> Exit
- Stage 8 save/load is implemented through `SaveManager` and currently persists live vertical-slice systems: stats, flags, ghost flags, inventory, equipment, HP, clock, and world return context
- Stage 8.5 is not implemented yet. The repo now includes a full planning/spec pack for portraits, map sprites, HUD rebuild, leveling, alignment, and battle equipment rendering

---

## Architecture

```text
autoloads/        Global singletons - always running
  SignalBus.gd    All game signals
  StatRegistry.gd Stat tree, action modifiers, Luck derivation
  GameClock.gd    Always-on clock, never pauses
  PlayerData.gd   Class, path, flags, ghost flags, age, inventory, equipment, HP
  SceneManager.gd Game state loader (Map / Battle / HUD / Cutscene)
  DialogueManager.gd NPC dialogue trees and condition checks
  SaveManager.gd  Save/load orchestration for the vertical slice
scenes/
  main/           Entry point and persistent overlay host
  map/            Top-down map state
  battle/         Turn-based battle state
  hud/            Current summary overlay; Stage 8.5 target is a tabbed HUD rebuild
  cutscene/       Scripted sequence state
  debug/          Dev-only stat/clock overlay (removed before release)
assets/
  art/            Mood boards, tilesets, sprites, battle art, UI art
docs/
  HANDOVER.md               Shared project memory and current state
  vertical_slice_plan.md    Stage-by-stage build plan
  art_direction.md          Visual rules plus placeholder-art policy
  stage_8_5_master_plan.md  Stage 8.5 execution order and planning method
  stage_8_5_asset_research.md Asset audit, provenance notes, source shortlist
  stage_8_5_systems_spec.md Stage 8.5 design lock for systems and interfaces
  stage_8_5_tickets.md      Ticket-by-ticket implementation handoff
```

---

## Design

- **Stat system:** 6 top-level stat families (Physical, Magik, Intelligence, Social, Will, Holy), each with sub-skills that increase through use.
- **Visibility tiers:** Some stats are always shown, some unlock later, and some remain ghost systems the player never directly sees.
- **Pure vs Mixed:** Not just a class choice - a political identity. The world responds.
- **Time:** An always-on clock that never pauses. Age is tracked. Buffs expire. The world keeps moving while menus are open.
- **Art sourcing policy:** Placeholder art can come from any free-compatible source, but provenance, license, and attribution obligations must be logged before it becomes a default implementation asset.

Full design and implementation planning live in `docs/`.
