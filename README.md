# RPG_GAME1

An archetypal high-fantasy RPG vertical slice built in Godot 4.
This repo now represents a completed technical spike plus a completed vertical slice, and is being kept as the reference baseline before the next phase begins in a cloned repo.

---

## Status

| Phase | Status |
|---|---|
| Pre-production | Complete |
| Technical spike | Complete |
| Vertical slice | Complete |

Current repo mode:
- Finished slice baseline
- Documentation and handoff reference
- No new active feature phase inside this repo

Next phase:
- clone the repo
- rename it for the next production branch
- run a foundation pass to mark what code should be kept, removed, or rebuilt
- do not start that work here unless explicitly asked

---

## What This Repo Actually Ships

- A full playable loop: Town -> mine commitment -> mine exploration -> three regular encounters -> Shaman choice -> mine exit -> crossroads
- Fresh boot defaults to the Pure/Fighter slice profile if no save exists
- Mixed/Battlemage is still available through save state or debug path switching
- A dedicated class-selection screen is not part of this repo yet
- Town interaction with three named NPC beats:
  - Village Guard: deeper intel requires `social.charm >= 10` and `20` gold
  - Traveling Merchant: one-time warning about the Shaman
  - Bookstore Keeper: `intelligence.understanding >= 10` unlocks the bookstore flag path
- Turn-based combat with:
  - `Attack`
  - `Spell`
  - `Item`
  - `Flee`
  - `Ability`
- Slice class expression:
  - Pure/Fighter: `Shield Bash`
  - Mixed/Battlemage: `Flamebolt` and `Arcane Strike`
- Progression and HUD systems:
  - XP rewards and level-ups
  - stat-family point spending
  - alignment label
  - equipment tab
  - quest tab
  - map tab placeholder
- Stage 10 presentation systems:
  - `ActorVisuals` for shared actor identity across map, battle, HUD, dialogue, cutscene, and follower states
  - `AudioManager` for locked music cues and pooled SFX playback
  - town collision cleanup and mine readability cleanup
  - release-safe debug gating
  - runtime harness plus evidence output under `tools/evidence/stage_10/`

---

## Setup

1. Install Godot 4.6+
2. Clone this repo
3. Import the folder into Godot
4. Run the project with `F5`, or open `scenes/main/Main.tscn`
5. If `user://save_game.json` exists, the game resumes from that save
6. If no save exists, the game starts from the town slice baseline

---

## Controls

Normal play:
- `WASD` or arrow keys: move
- `E`: interact on the map
- `E`, `Space`, or `Enter`: advance dialogue and confirm prompts
- `Esc` or other Godot cancel input: back out of prompts or close the HUD
- `H`: open or close the HUD

Debug-only behavior:
- debug panel, loader, battle skip, path switching, and reset tools are gated behind `OS.is_debug_build()`
- see `docs/HANDOVER.md` for the full debug control list

---

## Gameplay Snapshot

Town:
- The player starts in Frontier Hamlet near the Kobold mine.
- Leaving town triggers a point-of-no-return prompt and a one-time stat bump to `will.resolve` and `holy.faith`.

Mine:
- Progression is intentionally ordered.
- The player clears the Collapsed Hall, Western Den, and Eastern Den before the boss route fully opens.
- Blocked routes explain why they are blocked.

Battle:
- Standard Kobold encounters grant `30 XP`.
- The Shaman battle grants `80 XP`.
- The Shaman battle blocks fleeing.
- Health potions are usable in battle.
- The player starts with a `Starter Blade`, and the battle presentation includes the Stage 8.5 weapon-overlay spike.

Progression:
- `xp_to_next_level` is a flat `100`.
- Each level grants `3` unspent stat points.
- Spending one point on a stat family adds `+1` to every non-derived child skill in that family.
- `social.luck` stays derived and is never spent directly.

Choice outcome:
- Recruiting the Shaman grants stat rewards, unlocks the exit, and enables the crossroads follower.
- Killing the Shaman grants the talisman item, unlocks the exit, and records the kill branch instead.

HUD:
- `Stats`, `Equipment`, `Quest`, and `Map`
- `Map` is still placeholder text in this repo

Save behavior:
- autosave on map entry
- autosave when dialogue ends on the map
- autosave after battle victory
- autosave after Shaman recruit resolution

---

## Architecture

```text
autoloads/        Global singletons
  SignalBus.gd    Cross-scene signals
  StatRegistry.gd Stat tree, modifiers, Luck derivation
  GameClock.gd    Always-on clock
  PlayerData.gd   Identity, flags, inventory, equipment, HP, progression
  SceneManager.gd State loader (Map / Battle / Cutscene)
  DialogueManager.gd Dialogue trees and branching
  SaveManager.gd  Save/load orchestration
  AlignmentSystem.gd Derived alignment labels
  ActorVisuals.gd Shared actor presentation registry
  AudioManager.gd Shared music and SFX layer
scenes/
  main/           Entry point and persistent overlay host
  map/            Top-down exploration state
  battle/         Turn-based combat state
  hud/            Tabbed HUD overlay
  cutscene/       Scripted sequence state
  debug/          Dev-only overlay
  ui/             Dialogue, prompt, and transition support
assets/
  art/            Tilesets, UI, sprites, portraits, generated support art
  Music/          Locked Stage 10 music candidates
  SFX/            Stage 10 runtime SFX plus provenance notes
docs/
  HANDOVER.md                Source-of-truth handoff
  vertical_slice_plan.md     Archived stage-by-stage slice ledger
  stage_10_master_plan.md    Stage 10 closure summary
  stage_10_identity_matrix.md Actor presentation matrix
  stage_10_audio_asset_research.md Music lock and SFX inventory
  stage_10_playtest_packet.md Archived Stage 10 verification packet
tools/
  stage_8_5_runtime_harness.*
  stage_10_runtime_harness.*
  evidence/
```

---

## Key References

- `docs/HANDOVER.md`
- `docs/vertical_slice_plan.md`
- `docs/stage_10_master_plan.md`
- `docs/stage_10_identity_matrix.md`
- `docs/stage_10_audio_asset_research.md`
- `tools/stage_10_runtime_harness.tscn`
- `tools/evidence/stage_10/`

---

## Notes

- The Stage 10 harness has been run and evidence is stored under `tools/evidence/stage_10/`.
- The repo still uses placeholder-quality art/audio in places, but all active runtime assets are documented in-repo.
- The next step is not more vertical-slice work in `RPG_GAME1`. It is a cloned-repo foundation pass.
