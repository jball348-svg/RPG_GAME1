# Stage 10 Audio Asset Research

## Status

This file is now the Stage 10 audio lock, not just a shortlist.

What changed in implementation:
- all six active music beats now have a primary and fallback file chosen from `assets/Music/`
- the exit/victory cue is no longer a gap because `Victory  Main Theme Seed 1/2.mp3` exists in-repo and is wired
- first-pass runtime SFX were generated locally, converted to stable `OGG` runtime files, and committed under `assets/SFX/`
- the runtime uses `AudioManager.gd` with one shared music layer and pooled SFX players

Limits of this pass:
- the SFX set is placeholder-quality by design
- cue audition still needs a human playtest pass in-engine

---

## Music Lock

| Beat | Primary | Fallback | Runtime cue id | Notes |
|---|---|---|---|---|
| Town | `Town Theme — Frontier Hamlet 1.mp3` | `Town Theme — Frontier Hamlet 2.mp3` | `town` | Used for town and crossroads for this slice. |
| Mine | `Mine_Dungeon Ambient — Into the Dark 1.mp3` | `Mine_Dungeon Ambient — Into the Dark 2.mp3` | `mine` | Region ambience for the mine. |
| Regular battle | `Battle Theme — Blood and Iron 1.mp3` | `Battle Theme — Blood and Iron 2.mp3` | `battle` | Used for standard encounters. |
| Boss battle | `Boss Theme — The Shaman_s Chamber 1.mp3` | `Boss Theme — The Shaman_s Chamber 2.mp3` | `boss` | Used for Shaman/boss encounters. |
| Moral choice | `Moral Choice Sting — The Weight 1.mp3` | `Moral Choice Sting — The Weight 2.mp3` | `moral_choice` | Triggered on choice reveal. |
| Victory / exit | `Victory  Main Theme Seed 1.mp3` | `Victory  Main Theme Seed 2.mp3` | `victory_exit` | Triggered during `mine_exit`. |

Implementation note:
- `AudioManager` discovers these files by filename pattern inside `assets/Music/`, so the cue lock is resilient to exact Unicode punctuation in filenames.

---

## Runtime SFX Inventory

All current SFX live in `assets/SFX/` and are documented again in `assets/SFX/SFX_List.md`.

| SFX id | File | Use |
|---|---|---|
| `ui_confirm` | `ui_confirm_01.ogg` | HUD open/tab confirm, prompt confirm, cutscene choice confirm |
| `ui_cancel` | `ui_cancel_01.ogg` | HUD close, prompt cancel, submenu cancel |
| `dialogue_advance` | `dialogue_advance_01.ogg` | Dialogue advance |
| `step_town` | `step_town_01.ogg` | Town and crossroads footsteps |
| `step_mine` | `step_mine_01.ogg` | Mine footsteps |
| `attack_swing` | `attack_swing_01.ogg` | Melee swing, shield bash wind-up |
| `attack_hit` | `attack_hit_01.ogg` | Hit impact, enemy strike impact |
| `spell_cast` | `spell_cast_01.ogg` | Flamebolt, Arcane Strike, Shaman magic |
| `gate_open` | `gate_open_01.ogg` | Gate / ward / exit opening beats |
| `loot_pickup` | `loot_pickup_01.ogg` | Victory / loot feedback |

Provenance for all ten files:
- repo-local generated placeholder assets
- authored on 2026-04-15 with Python standard-library synthesis and converted in-repo to `OGG`
- no third-party asset import occurred in this pass

---

## Wiring Summary

`AudioManager` is called directly from scenes. No audio signals were added to `SignalBus`.

Current Stage 10 wiring:
- map
  - `town` music in town and crossroads
  - `mine` music in the mine
  - `step_town` and `step_mine` on movement cadence
  - `gate_open` on town departure, boss chamber gate beat, and mine exit trigger beat
- battle
  - `battle` music for standard encounters
  - `boss` music for boss and placeholder boss encounters
  - UI confirm/cancel, swing, hit, spell, and loot cues
- dialogue / prompt / HUD
  - dialogue advance, prompt confirm/cancel, HUD open/close/tab confirm
- cutscene
  - `moral_choice` on Shaman choice reveal
  - `victory_exit` on mine exit cutscene
  - gate and confirm cues on transition beats

---

## Follow-up Guidance

- Outside playtest is the right time to decide whether any placeholder SFX need to be replaced with sourced assets.
- If sourced replacements are imported later:
  - keep the stable runtime filenames
  - update `assets/SFX/SFX_List.md` immediately
  - note license and attribution obligations at import time
