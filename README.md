# RPG_GAME1

An archetypal high fantasy RPG built in Godot 4. The player chooses **Pure** or **Mixed** at the start, and that identity drives the central faction conflict, progression flavor, and moral framing of the slice.

---

## Status

| Phase | Status |
|---|---|
| Pre-production | Complete |
| Technical spike | Complete |
| Vertical slice | Stage 10 implementation complete, awaiting outside feedback |

Current focus: prepare and run the first outside playtest, then handle follow-up fixes in a separate pass.

Primary references:
- `docs/HANDOVER.md`
- `docs/vertical_slice_plan.md`
- `docs/stage_10_master_plan.md`
- `docs/stage_10_identity_matrix.md`
- `docs/stage_10_audio_asset_research.md`
- `docs/stage_10_playtest_packet.md`
- `tools/stage_10_runtime_harness.tscn`

---

## Setup

1. Install Godot 4.6+
2. Clone this repo
3. Open Godot and import this folder
4. Run the project with `F5`, or open `scenes/main/Main.tscn`
5. The game boots into the current map state, or resumes from `user://save_game.json` if a save exists

Normal controls:
- `WASD` or arrow keys to move
- `E` / `Space` to interact or advance dialogue
- `H` to open the HUD

Debug controls are gated behind `OS.is_debug_build()` and should not be treated as release behavior.

---

## Current Slice Snapshot

- Core loop playable end to end: Load -> Town -> Leave -> Cutscene -> Mine -> Battles -> Boss choice -> Exit -> Crossroads
- Stage 10 now includes:
  - `AudioManager` autoload for music and pooled SFX
  - `ActorVisuals` autoload as the shared actor presentation registry
  - dialogue portrait IDs plus registry-driven actor lookup
  - registry-driven player, NPC, battle, cutscene, and follower visuals
  - town collision cleanup and named mine blocker/walkable data
  - release-safe debug gating in main flow and map hints
  - Stage 10 runtime harness scaffold plus playtest packet
- First-pass Stage 10 SFX are repo-local generated placeholder `OGG` files committed under `assets/SFX/`
- Outside feedback integration is intentionally deferred to the next pass

---

## Architecture

```text
autoloads/        Global singletons
  SignalBus.gd    Cross-scene signals
  StatRegistry.gd Stat tree, modifiers, Luck derivation
  GameClock.gd    Always-on clock
  PlayerData.gd   Class, path, flags, inventory, HP, progression
  SceneManager.gd State loader (Map / Battle / Cutscene)
  DialogueManager.gd Dialogue trees and branching
  SaveManager.gd  Save/load orchestration
  AlignmentSystem.gd Derived alignment labels
  ActorVisuals.gd Shared actor presentation registry
  AudioManager.gd Shared music + SFX layer
scenes/
  main/           Entry point and persistent overlay host
  map/            Top-down exploration state
  battle/         Turn-based combat state
  hud/            Tabbed HUD overlay
  cutscene/       Scripted sequence state
  debug/          Dev-only overlay
assets/
  art/            Tilesets, UI, sprites, portraits, generated support art
  Music/          Locked Stage 10 music candidates
  SFX/            Stage 10 placeholder runtime SFX + provenance notes
docs/
  HANDOVER.md                Source-of-truth project handoff
  vertical_slice_plan.md     Stage-by-stage slice status
  stage_10_master_plan.md    Stage 10 implementation summary
  stage_10_identity_matrix.md Shared actor visual mapping
  stage_10_audio_asset_research.md Music lock + SFX inventory
  stage_10_playtest_packet.md Playtest brief, checklist, issue log template
tools/
  stage_8_5_runtime_harness.*
  stage_10_runtime_harness.*
  evidence/
```

---

## Notes

- Placeholder art and audio remain allowed only when provenance is logged in-repo.
- The Stage 10 runtime harness was added, but Godot CLI was not available in this shell session, so the harness was not executed here.
- The next milestone is not more implementation scope. It is outside playtest coverage plus a tightly-scoped follow-up fix pass.
