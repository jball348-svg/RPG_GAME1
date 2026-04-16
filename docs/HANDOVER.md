# Project Handover - RPG_GAME1
> For LLM agents. Read this before doing anything. This is the source of truth for the current repo state.

---

## Who You Are Working With

**Developer:** John - solo developer, first Godot game, fast-moving, decisive, and comfortable with blunt technical feedback.

**Working style:** GSD methodology. Scope hard, cut ruthlessly, ship. Do not pad. Do not over-explain. Push back when something is out of scope or structurally weak.

**AI stack:**
- Claude: architecture, scoping, design decisions, prompt generation
- Codex / Windsurf / Cascade: implementation
- GitHub MCP: direct repo operations (`jball348-svg`)

---

## Repo Status

| Track | Status |
|---|---|
| Technical spike | Complete |
| Vertical slice stages 1-10 | Complete |
| Runtime harness evidence | Captured |
| Active work inside this repo | None |

This repo should now be treated as:
- the finished spike-plus-slice reference baseline
- the historical record of what was built and verified
- the input to the next phase

The next phase is:
1. clone the repo
2. rename it
3. run a foundation pass to mark what code stays, what gets removed, and what should be rebuilt

Do not start that next phase inside `RPG_GAME1` unless explicitly asked.

---

## The Project

The broader project is an archetypal high-fantasy RPG centered on a Pure vs Mixed class conflict. The allegory is intentional: fantasy bigotry and factional identity are standing in for racism and purity politics.

The current repo is narrower than the full project vision. What exists here is a completed vertical slice of that world.

Important repo-truth notes:
- Fresh boot does not present a real class-selection screen.
- If no save exists, the slice defaults to the Pure/Fighter profile through `PlayerData.ensure_spike_defaults()`.
- Mixed/Battlemage exists and is playable, but it is entered through save state or debug profile switching.
- The current HUD `Map` tab is still placeholder text.
- The bookstore path sets a progression/dialogue flag but does not add a new combat spell in this repo.

**Engine:** Godot 4 (GDScript)  
**Platform target:** PC / Steam  
**Repo:** `github.com/jball348-svg/RPG_GAME1`

---

## Locked Project Decisions

| Decision | Detail |
|---|---|
| Engine | Godot 4, GDScript |
| Genre | 2D top-down RPG, pixel art |
| Setting | Archetypal high fantasy played straight |
| Central conflict | Pure vs Mixed class war |
| Current slice class expression | Pure = Fighter, Mixed = Battlemage |
| Current start behavior | Fresh boot defaults to Pure/Fighter if no save exists |
| Class selection screen | Not implemented in this repo |
| Stat system | 6 top-level stat families, skills beneath each, open registry |
| Visibility tiers | Tier 1 always shown, Tier 2 milestone-based, Tier 3 hidden |
| Luck | Derived from Charm + Reputation + Empathy |
| Holy | `Holy` with Faith, Intuition, Peace, Justice |
| Will | `Will` with Resolve, Focus, Resistance |
| Magik | Spelled with a `k` |
| Time system | Always-on clock, about 2x real time, never pauses, accelerates on rest/sleep |
| Pure/Mixed identity | Stored as flags/data on `PlayerData.gd`, not as a stat |
| Tile resolution | 32x32, scrolling map |
| Art tone | Desaturated earth tones, grim beauty, no bright primaries |
| Actor presentation | `ActorVisuals.gd` is the source of truth for map, battle, portrait, cutscene, follower, and tint/accent presentation |
| Audio | `AudioManager.gd` owns the Stage 10 music cue lock and pooled SFX playback |
| Placeholder asset policy | Allowed only when provenance is logged in-repo |

---

## Current Slice Mechanics

### Core Loop

1. Boot from save or start fresh in Frontier Hamlet
2. Talk to town NPCs for gated intel and warning beats
3. Confirm leaving town for the mine
4. Watch the mine-entry cutscene
5. Explore the mine and clear three ordered Kobold encounters
6. Enter the Shaman chamber
7. Recruit or fight the Shaman
8. Exit the mine and arrive at the crossroads

### Town

- Village Guard
  - base line always available
  - deeper intel requires `social.charm >= 10` and `20` gold
- Traveling Merchant
  - gives the Shaman warning once
  - sets `shaman_warning_given`
- Bookstore Keeper
  - requires `intelligence.understanding >= 10`
  - sets `destruction_spell_unlocked`
  - does not wire a new battle spell in this repo
- Leaving town applies the one-time mine commitment stats:
  - `will.resolve +1`
  - `holy.faith +1`

### Mine

- Region music, footsteps, and route messaging are wired through Stage 10 systems.
- Progression is ordered and readable:
  - encounter 1: Collapsed Hall
  - encounter 2: Western Den
  - encounter 3: Eastern Den
  - boss route opens after encounter progress reaches `3`
  - exit opens after the Shaman branch resolves
- Mine blocker messaging is now code-driven and named in `Map.gd`.

### Battle

- Standard encounter enemy: Kobold
- Boss encounter enemy: Shaman
- Player actions:
  - `Attack`
  - `Spell`
  - `Item`
  - `Flee`
  - `Ability`
- Slice class behavior:
  - Fighter: `Shield Bash`
  - Battlemage: `Flamebolt` and `Arcane Strike`
- Items:
  - health potions are live
  - starter weapon overlay spike is live
- Flee:
  - works in standard encounters
  - blocked in the Shaman fight
- Rewards:
  - Kobold: `30 XP`
  - Shaman: `80 XP`
  - Shaman kill also grants the talisman item

### Progression

- `PlayerData` owns:
  - `level`
  - `xp`
  - `xp_to_next_level`
  - `unspent_stat_points`
- `xp_to_next_level` is flat at `100` in this repo
- each level grants `3` stat points
- spending one point on a family adds `+1` to every non-derived child skill in that family
- `social.luck` stays derived-only

### Alignment

`AlignmentSystem.gd` is derived-only.

Current label inputs:
- `pure_rep_shaman_mercy` -> Good
- `mixed_betrayed_own` -> Evil
- `shaman_recruited` -> Chaotic
- `shaman_killed` on Pure path -> Lawful

If both axes are neutral, the HUD shows `True Neutral`.

### Shaman Outcome

Recruit branch:
- sets `shaman_recruited`
- sets `mine_boss_resolved`
- sets `mine_exit_unlocked`
- sets ghost flags for the mercy path
- grants `social.charm +3`
- grants `magik.attunement +2`
- enables the Shaman follower at the crossroads

Kill branch:
- sets `shaman_killed`
- sets `mine_boss_resolved`
- sets `mine_exit_unlocked`
- sets kill-branch ghost flags
- grants the Shaman talisman item

### HUD

The HUD is a map overlay, not a separate scene state.

Tabs:
- `Stats`
- `Equipment`
- `Quest`
- `Map`

Current HUD truth:
- `Stats` shows level, XP, points, alignment, gold, and family averages
- `Equipment` mirrors the current eight-slot data model
- `Quest` shows one active objective block based on mine progress
- `Map` is placeholder text only
- if a battle returns after level-up, the HUD can open directly to `Stats`

### Save and Resume

`SaveManager.gd` is live.

Save path:
- `user://save_game.json`

Autosave currently happens on:
- map entry
- dialogue end while on the map
- battle victory
- Shaman recruit resolution

Save payload includes:
- stat registry
- player identity, flags, ghost flags, inventory, equipment, HP, age, and progression
- game clock
- world return context for map reload

---

## Stat Families

| Family | Skills |
|---|---|
| Physical | Strength, Endurance, Movement |
| Magik | Spellcasting, Attunement, Mana |
| Intelligence | Understanding, Tactics, Persuasion |
| Social | Charm, Reputation, Empathy, Luck (derived) |
| Will | Resolve, Focus, Resistance |
| Holy | Faith, Intuition, Peace, Justice |

Open-registry rule: add keys in `StatRegistry.gd` and `action_modifiers`; no architecture rewrite required.

---

## Game States

| State | Role |
|---|---|
| Map | Exploration, NPC interaction, route gating, encounter triggers |
| Battle | Turn-based combat, XP, loot, defeat handling |
| HUD | Overlay for stats, equipment, quest, and placeholder map review |
| Cutscene | Mine entry, Shaman intro, and mine exit sequences |

Transitions:
- Map <-> Battle
- Map <-> Cutscene
- HUD overlays the map and does not replace it

---

## Current Completion Summary

| Stage | Status |
|---|---|
| Technical spike | Complete |
| 1 - Real town map | Complete |
| 2 - NPC dialogue system | Complete |
| 3 - Town exit and mine entrance cutscene | Complete |
| 4 - Mine dungeon map | Complete |
| 5 - Battle system | Complete |
| 6 - Boss room and moral choice | Complete |
| 6.5 - Dev skip and scene loader | Complete |
| 7 - Mine exit and area transition | Complete |
| 8 - Save system | Complete |
| 8.5 - MVP feature pass | Complete |
| 9 - Developer sign-off | Complete |
| 10 - Polish and slice closeout | Complete |

Evidence:
- Stage 10 runtime harness: `tools/stage_10_runtime_harness.tscn`
- Stage 10 evidence output: `tools/evidence/stage_10/`

No active stage work remains in this repo.

---

## Infrastructure Reference

| File | Purpose |
|---|---|
| `autoloads/SignalBus.gd` | Cross-scene signals |
| `autoloads/StatRegistry.gd` | Stat tree, modifiers, Luck derivation |
| `autoloads/GameClock.gd` | Always-on clock |
| `autoloads/PlayerData.gd` | Identity, flags, inventory, equipment, HP, progression |
| `autoloads/SceneManager.gd` | Scene-state loader and payload passing |
| `autoloads/DialogueManager.gd` | Dialogue trees and condition evaluation |
| `autoloads/SaveManager.gd` | Save/load orchestration |
| `autoloads/AlignmentSystem.gd` | Derived-only alignment labels |
| `autoloads/ActorVisuals.gd` | Shared actor presentation registry |
| `autoloads/AudioManager.gd` | Shared music and pooled SFX layer |
| `scenes/main/` | Root shell and overlay host |
| `scenes/map/` | Exploration, progression, collisions, triggers |
| `scenes/battle/Battle.gd` | Battle loop and victory flow |
| `scenes/hud/` | Tabbed HUD overlay |
| `scenes/cutscene/` | `mine_entry`, `shaman_intro`, `mine_exit` |
| `scenes/ui/DialogueBox.gd` | Dialogue UI with `portrait_id` support |
| `scenes/ui/PromptModal.gd` | Confirmation modal for town and mine exits |
| `scenes/debug/` | Debug-only overlay and controls |

---

## Archived Stage Packs

Stage 8.5 archive:
- `docs/stage_8_5_master_plan.md`
- `docs/stage_8_5_asset_research.md`
- `docs/stage_8_5_systems_spec.md`
- `docs/stage_8_5_tickets.md`

Stage 10 archive:
- `docs/stage_10_master_plan.md`
- `docs/stage_10_identity_matrix.md`
- `docs/stage_10_audio_asset_research.md`
- `docs/stage_10_playtest_packet.md`
- `docs/stage_10_tickets.md`

Use these as historical reference, not as active stage instructions.

---

## Dev Controls

Debug builds only:
- `WASD` / arrows: move
- `E`: interact
- `H`: toggle HUD
- `B`: force battle
- `C`: force cutscene
- `L`: open location/spawn loader
- `P`: skip battle to victory
- `O`: toggle debug overlay visibility
- `1`: set Pure/Fighter profile
- `2`: set Mixed/Battlemage profile
- `3`: bump Social and gold
- `4`: bump Intelligence
- `0`: reset debug stats and gold
- `F9`: full reset

These are not release-behavior promises.

---

## Repo Structure

```text
autoloads/
scenes/
  main/
  map/
  battle/
  hud/
  cutscene/
  debug/
  ui/
assets/
  art/
  Music/
  SFX/
docs/
  HANDOVER.md
  vertical_slice_plan.md
  spike_progress.md
  stat_registry.md
  art_direction.md
  stage_8_5_*
  stage_10_*
tools/
  stage_8_5_runtime_harness.*
  stage_10_runtime_harness.*
  evidence/
project.godot
```

`assets/SFX/` now contains committed runtime `ogg` files and provenance notes.

---

## Next Phase

The next phase should happen in a cloned repo, not here.

Goal of that phase:
1. clone and rename the project
2. audit the finished slice baseline
3. mark systems/assets/code paths as:
   - keep
   - cut
   - rebuild
4. establish the production foundation for what comes after the slice

This repo should remain the frozen reference for the completed spike and vertical slice.

---

## How To Use This Document

For any future audit or transition-planning session:
1. read `README.md`
2. read `docs/HANDOVER.md`
3. read `docs/vertical_slice_plan.md`
4. open the archived Stage 8.5 or Stage 10 pack only if you need implementation history

Update this file only if repo behavior changes or if the project formally changes what this repo represents.
