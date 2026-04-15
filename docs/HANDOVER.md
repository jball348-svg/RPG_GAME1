# Project Handover - RPG_GAME1
> **For LLM agents.** Read this before doing anything. This is the source of truth. Do not contradict locked decisions without flagging it to the developer first.

---

## Who you are working with

**Developer:** John - solo developer, "vibe coder". First Godot game. Decisive, moves fast, strong creative instincts. Does not need hand-holding. Needs concrete, specific technical help. Do not over-explain. Do not pad. Be direct.

**Working style:** GSD methodology. Scope hard, cut ruthlessly, ship. Give honest opinions, including pushback when something is out of scope or a bad idea.

**AI stack:**
- Claude - architecture, scoping, design decisions, prompt generation
- Codex / Windsurf / Cascade - implementation
- GitHub MCP - direct repo operations (`jball348-svg`)

---

## The game

An archetypal high fantasy RPG. At the start, the player chooses **Pure** (one class, optionally specialised) or **Mixed** (multiclass, versatile but diluted). This choice drives the game's central conflict: a war between Pure and Mixed factions. The allegory mirrors bigotry and racism using fantasy as the frame - intentional, not subtle.

Classic JRPG pacing: top-down 2D map, turn-based battle, HUD menus, cutscenes. Deep but legible stat system. Constant dopamine loop - every action grows the character.

**Engine:** Godot 4 (GDScript)  
**Platform:** PC / Steam  
**Repo:** `github.com/jball348-svg/RPG_GAME1`

---

## Locked project decisions

| Decision | Detail |
|---|---|
| Engine | Godot 4, GDScript |
| Genre | 2D top-down RPG, pixel art |
| Setting | Archetypal high fantasy - all tropes, played straight |
| Central conflict | Pure vs Mixed class war - allegory for bigotry/racism |
| Class system | Pure (1 class + optional specialisation) vs Mixed (multiclass, diluted) |
| Stat system | 6 top-level stat families, skills beneath each, open registry |
| Visibility tiers | Tier 1 always shown, Tier 2 unlocked at milestones, Tier 3 ghost / never shown |
| Luck | Derived stat under Social - calculated from Charm + Reputation + Empathy |
| Holy stat | Named `Holy`. Skills: Faith, Intuition, Peace, Justice |
| Will stat | Named `Will`. Skills: Resolve, Focus, Resistance |
| Magik | Stylised with a `k`. Skills: Spellcasting, Attunement, Mana |
| Time system | Always-on clock, about 2x real time, never pauses, accelerates on rest/sleep. Age is tracked. |
| Ghost layer | Hidden flags and stats silently influence the world - never shown to the player |
| Pure/Mixed flag | Not a stat. A flag plus reputation logic. Lives in `PlayerData.gd`. |
| Tile resolution | 32x32. Scrolling map, not screen-shifting. |
| Art tone | Desaturated earth tones, grim beauty, no bright primaries, no cartoon. Refs: Baldur's Gate, LotR, GoT, Elden Ring |
| Character art | Map = class sprite only. Battle + HUD + Cutscene = full equipment render target. |
| Placeholder art policy | Free-compatible placeholder sources are allowed only when provenance, license, and attribution obligations are logged in `docs/stage_8_5_asset_research.md`. |
| Audio | Music generated via AI (Suno/Udio). SFX from free-compatible sources. Stored locally, gitignored. |

---

## Current vertical slice state

See `docs/vertical_slice_plan.md` for the full stage breakdown.

**Stages complete:** 1-8  
**Current focus:** Stage 8.5 implementation prep and feature pass handoff  
**Recently completed:** Stage 8 save system, plus the Stage 8.5 admin/spec pack in this docs pass

### Vertical slice checklist
- [x] Real tilesets integrated
- [x] Real town map
- [x] NPC dialogue system
- [x] Town exit -> cutscene -> mine
- [x] Mine dungeon map
- [x] Battle system (turn-based, class abilities)
- [x] Boss room - Shaman intro + moral choice
- [x] Mine exit -> new area
- [x] Save system
- [ ] Stage 8.5 MVP feature implementation (portraits, sprites, HUD, leveling, alignment, equipment-render spike)
- [ ] Dev sign-off
- [ ] Polish + playtester pass

---

## Stage 8 snapshot - save system is live

Stage 8 is treated as complete based on repo state and developer confirmation.

Current behavior:
- `SaveManager` is an autoload registered in `project.godot`
- Save path is `user://save_game.json`
- `Main.gd` boots from save automatically if one exists; otherwise it starts a fresh map session
- Autosave currently fires on:
  - map entry
  - dialogue completion while on map
  - battle victory
  - Shaman recruit resolution in cutscene
- Save payload currently persists:
  - `StatRegistry` stats
  - `PlayerData` identity, path, flags, ghost flags, gold, inventory, equipment, HP, and age
  - `GameClock` time
  - map/world return context for load back into the map state

Important limitation:
- Progression fields appear in the `PlayerData` save payload as placeholders today, but real `level`, `xp`, `xp_to_next_level`, and `unspent_stat_points` logic is a Stage 8.5 task. Do not claim that Stage 8 already shipped the full leveling system.

---

## Stage 8.5 design locks

These are locked for the next implementation pass unless John explicitly changes them.

- `PlayerData` becomes the source of truth for real progression state: `level`, `xp`, `xp_to_next_level`, and `unspent_stat_points`.
- `SignalBus` gains `level_up(level: int)`.
- `StatRegistry` gains a public category-allocation helper for Stage 8.5.
- Stage 8.5 level-up spending does **not** create new parent stat values. One point spent on a top-level category adds `+1` to every non-derived child skill in that category.
- `social.luck` stays derived. It is recalculated after Social allocation and is never directly increased by level-up spending.
- `AlignmentSystem` is derived-only. It reads flags and ghost flags from `PlayerData`, exposes a label for UI, and is not saved independently.
- The Stage 8.5 HUD target is a tabbed overlay with `Stats`, `Equipment`, `Quest`, and `Map`.
- The Stage 8.5 Equipment tab keeps the current eight equipment keys and shows eight display slots. Do not force a seven-slot refactor in this pass.
- The Stage 8.5 battle equipment spike is one conditional weapon overlay tied to `PlayerData.equipment["weapon"]`, not a full compositing system.
- Battlemage map art may come from an external source if the repo candidate fails fit or provenance review.

Full implementation detail lives in:
- `docs/stage_8_5_master_plan.md`
- `docs/stage_8_5_asset_research.md`
- `docs/stage_8_5_systems_spec.md`
- `docs/stage_8_5_tickets.md`

---

## V1.0 scope

**In scope:**
- Full main quest arc, start to finish
- Pure and Mixed class paths with all mechanical consequences
- Specialisation trees within Pure classes
- Stat system fully operational
- Four game states: Map, Battle, HUD, Cutscene - clean transitions
- About 6-10 locations, key NPCs, Pure/Mixed factions
- Battle system with class abilities and stat integration
- Levelling system with stat allocation
- Save system (full snapshot: stats, flags, clock, location)
- PC / Steam

**Out of scope for v1.0:**
- Guilds, side quests, open world, post-game content
- Crafting, housing, full economy/trading
- Companion system beyond the Shaman recruit flag
- Mounts, dynamic weather, full faction reputation system, multiplayer, mod support

---

## Stat registry

| Top-level family | Skills |
|---|---|
| Physical | Strength, Endurance, Movement |
| Magik | Spellcasting, Attunement, Mana |
| Intelligence | Understanding, Tactics, Persuasion |
| Social | Charm, Reputation, Empathy, Luck (derived) |
| Will | Resolve, Focus, Resistance |
| Holy | Faith, Intuition, Peace, Justice |

Open registry principle: add a key to `StatRegistry.gd` and entries to `action_modifiers`. No architecture change required. Full reference: `docs/stat_registry.md`

---

## Character art by game state

| State | Art | Equipment visible? |
|---|---|---|
| Map | Class sprite, 32x32 top-down | No |
| Battle | Side-on sprite, about 64-96 px | Yes - armour + weapon layers are the target |
| HUD | Portrait or full-body | Yes - full loadout target |
| Cutscene | Full sprite, animated | Yes |

Map sprites: Pure = muted gold accent, Mixed = muted teal accent. Battle sprites: target layered rendering, but current implementation is still placeholder-driven.

---

## Four game states

| State | What happens | Stat activity |
|---|---|---|
| Map | Movement, NPC interaction, exploration | Movement, Social, Endurance |
| Battle | Turn-based combat | Strength, Spellcasting, Will, Holy |
| HUD | Current summary overlay; Stage 8.5 target is tabbed review and stat allocation | Clock keeps running |
| Cutscene | Scripted sequences, dialogue, flags | Clock keeps running, story flags fire |

Transitions: Map <-> Battle, Map <-> Cutscene. HUD overlays map and does not replace it.

---

## Core loop reference scenario

1. Load save or start new session in town near the Kobold-occupied mine
2. Town -> NPC intel (Social + gold gated), moral choice warning, bookstore unlock (Intelligence gated)
3. Leave town -> point-of-no-return confirm
4. Cutscene -> class/path tinted mine entrance
5. Mine -> navigation, Kobold encounters, stat ticks
6. Battle -> Kobold fights, class abilities
7. Boss room -> Shaman -> recruit or kill
8. Exit mine -> new area, main quest path opens

---

## Infrastructure reference

| File | Purpose |
|---|---|
| `autoloads/SignalBus.gd` | All game signals |
| `autoloads/StatRegistry.gd` | Stat tree, action modifiers, Luck derivation |
| `autoloads/GameClock.gd` | Always-on clock |
| `autoloads/PlayerData.gd` | Class, path, flags, ghost flags, age, inventory, equipment, HP, save payload placeholders for progression |
| `autoloads/SceneManager.gd` | Game state loader, payload passing |
| `autoloads/DialogueManager.gd` | NPC dialogue trees and condition evaluation |
| `autoloads/SaveManager.gd` | Save/load orchestration and autosave hooks |
| `scenes/main/` | Root shell, persistent `OverlayHost` |
| `scenes/map/` | WASD movement, town/mine/crossroads regions, encounter triggers, stat events |
| `scenes/battle/Battle.gd` | Full turn-based battle system and victory/return flow |
| `scenes/hud/` | Current summary overlay; Stage 8.5 target is a tabbed rebuild |
| `scenes/cutscene/` | Payload-driven `mine_entry`, `shaman_intro`, and `mine_exit` sequences |
| `scenes/ui/DialogueBox.gd` | Existing dialogue portrait slot and portrait-path loader |
| `scenes/debug/` | Dev-only overlay - gated by `OS.is_debug_build()` |

---

## Dev controls

Debug builds only:
- `WASD` / arrows - move
- `P` - skip battle to victory
- `L` - open location/spawn loader on map
- `B` - force battle
- `H` - toggle HUD
- `C` - force cutscene
- `1` / `2` - set Pure / Mixed path
- `3` - bump Social + gold
- `4` - bump Intelligence
- `0` - reset stats

---

## Repo structure

```text
autoloads/
scenes/
  main/
  map/
  battle/
  hud/
  cutscene/
  debug/
assets/
  art/
    tilesets/
    battle/
    player/
    UI/
    Mood Board/
  audio/          (gitignored - local only, not committed)
docs/
  HANDOVER.md
  vertical_slice_plan.md
  stat_registry.md
  art_direction.md
  stage_8_5_master_plan.md
  stage_8_5_asset_research.md
  stage_8_5_systems_spec.md
  stage_8_5_tickets.md
project.godot
```

Audio files are gitignored. Store them in `assets/audio/` locally. Do not commit binary audio to the repo.

---

## Stage 8.5 doc pack

Start every Stage 8.5 implementation session with these files:
- `docs/HANDOVER.md`
- `docs/vertical_slice_plan.md`
- `docs/stage_8_5_master_plan.md`
- `docs/stage_8_5_asset_research.md`
- `docs/stage_8_5_systems_spec.md`
- `docs/stage_8_5_tickets.md`

Suggested opener for future agents:
> "Read `docs/HANDOVER.md`, `docs/vertical_slice_plan.md`, and the Stage 8.5 spec pack. I am implementing Ticket TXX from Stage 8.5."

---

## Production order after the vertical slice

1. Class selection / character creation screen
2. Main quest - remaining acts and locations
3. Steam page + first devlog - do not wait until launch

---

## How to use this document

Paste the raw URL at the top of any new agent session, then state the current stage and ticket.

**Raw URL:** `https://raw.githubusercontent.com/jball348-svg/RPG_GAME1/main/docs/HANDOVER.md`

Update this file when decisions change, when phase status changes, or when a Stage 8.5 ticket materially changes the implementation baseline.
