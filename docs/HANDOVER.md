# Project Handover — RPG_GAME1
> **For LLM agents.** Read this before doing anything. This is the source of truth. Do not contradict locked decisions without flagging it to the developer first.

---

## Who you are working with

**Developer:** John — solo developer, "vibe coder". First Godot game. Decisive, moves fast, strong creative instincts. Does not need hand-holding. Needs concrete, specific technical help. Do not over-explain. Do not pad. Be direct.

**Working style:** GSD methodology. Scopes hard, cuts ruthlessly, ships. Give honest opinions including pushback when something is out of scope or a bad idea.

**AI stack:**
- Claude — architecture, scoping, design decisions, prompt generation
- Codex / Windsurf / Cascade — implementation
- GitHub MCP — direct repo operations (`jball348-svg`)

---

## The game

An archetypal high fantasy RPG. At the start, the player chooses **Pure** (one class, optionally specialised) or **Mixed** (multiclass, versatile but diluted). This choice drives the game's central conflict: a war between Pure and Mixed factions. The allegory mirrors bigotry and racism using fantasy as the frame — intentional, not subtle.

Classic JRPG pacing: top-down 2D map, turn-based battle, HUD menus, cutscenes. Deep but legible stat system. Constant dopamine loop — every action grows the character.

**Engine:** Godot 4 (GDScript) · **Platform:** PC / Steam · **Repo:** `github.com/jball348-svg/RPG_GAME1`

---

## Locked decisions

| Decision | Detail |
|---|---|
| Engine | Godot 4, GDScript |
| Genre | 2D top-down RPG, pixel art |
| Setting | Archetypal high fantasy — all tropes, played straight |
| Central conflict | Pure vs Mixed class war — allegory for bigotry/racism |
| Class system | Pure (1 class + optional specialisation) vs Mixed (multiclass, diluted) |
| Stat system | 6 top-level stats, skills beneath each, open registry |
| Visibility tiers | Tier 1 always shown · Tier 2 unlocked at milestones · Tier 3 ghost/never shown |
| Luck | Derived stat under Social — calculated from Charm + Reputation + Empathy |
| Holy stat | Named "Holy". Skills: Faith, Intuition, Peace, Justice |
| Will stat | Named "Will". Skills: Resolve, Focus, Resistance |
| Magik | Stylised with a 'k'. Skills: Spellcasting, Attunement, Mana |
| Time system | Always-on clock, ~2× real time, never pauses, accelerates on rest/sleep. Age is a stat. |
| Ghost layer | Hidden flags and stats that silently influence world — never shown to player |
| Pure/Mix flag | Not a stat. A flag + reputation score. Lives in `PlayerData.gd`. |
| Art approach | Free CC0 asset packs (Kenney.nl, OpenGameArt, itch.io) + curation |
| Tile resolution | 32×32. Scrolling map, not screen-shifting. |
| Art tone | Desaturated earth tones, grim beauty, no bright primaries, no cartoon. Refs: Baldur's Gate, LotR, GoT, Elden Ring |
| Character art | Map = class sprite only. Battle + HUD + Cutscene = full equipment render. |
| Audio | Music generated via AI (Suno/Udio). SFX from CC0 sources (freesound.org, Kenney). Stored locally, gitignored. |

---

## V1.0 scope

**In scope:**
- Full main quest arc, start to finish
- Pure and Mixed class paths with all mechanical consequences
- Specialisation trees within Pure classes
- Stat system fully operational
- Four game states: Map, Battle, HUD, Cutscene — clean transitions
- ~6–10 locations, key NPCs, Pure/Mixed factions
- Battle system with class abilities and stat integration
- Levelling system with stat allocation
- Save system (full snapshot: stats, flags, clock, location)
- PC / Steam

**Out of scope for v1.0:**
- Guilds, side quests, open world, post-game content
- Crafting, housing, full economy/trading
- Companion system (beyond Shaman recruit flag)
- Mounts, dynamic weather, full faction reputation system, multiplayer, mod support

---

## Stat registry

| Top-level stat | Skills |
|---|---|
| Physical | Strength, Endurance, Movement |
| Magik | Spellcasting, Attunement, Mana |
| Intelligence | Understanding, Tactics, Persuasion |
| Social | Charm, Reputation, Empathy, Luck (derived) |
| Will | Resolve, Focus, Resistance |
| Holy | Faith, Intuition, Peace, Justice |

Open registry principle: add a key to `StatRegistry.gd` and entries to `action_modifiers`. No architecture change required. Full doc: `docs/stat_registry.md`

---

## Character art by game state

| State | Art | Equipment visible? |
|---|---|---|
| Map | Class sprite, 32×32 top-down | No |
| Battle | Side-on sprite, 64–96px | Yes — armour + weapon layers |
| HUD | Portrait or full-body | Yes — full loadout |
| Cutscene | Full sprite, animated | Yes |

Map sprites: Pure = muted gold tint, Mixed = muted teal tint. Battle sprites: layered (base body + armour + weapon).

---

## Core loop (reference scenario)

1. Load save → player in town near Kobold-occupied mine
2. Town → NPC intel (Social + gold gated), moral choice warning, bookstore unlock (Intelligence gated)
3. Leave town → point-of-no-return confirm
4. Cutscene → class-specific mine entrance, path tint
5. Mine → navigation, Kobold encounters, stat ticks
6. Battle → Kobold fights, class abilities, levelling
7. Boss room → Shaman → recruit or kill
8. Exit mine → new area, main quest path opens

---

## Four game states

| State | What happens | Stat activity |
|---|---|---|
| Map | Movement, NPC interaction, exploration | Movement, Social, Endurance |
| Battle | Turn-based combat | Strength, Spellcasting, Will, Holy |
| HUD | Inventory, stats, equipment, quests | Clock runs, minimal stat activity |
| Cutscene | Scripted sequences, dialogue, flags | Clock runs, story flags fire |

Transitions: Map ↔ Battle, Map ↔ Cutscene. HUD overlays map (does not replace it).

---

## Current phase — vertical slice 🔄

See `docs/vertical_slice_plan.md` for full stage breakdown and status.

**Stages complete:** 1–7
**Current focus:** Stage 8 (save system)
**Recently completed:** Stage 6 (boss room), Stage 6.5 (dev skip tools), Stage 7 (mine exit + crossroads)

### Vertical slice checklist
- [x] Real tilesets integrated
- [x] Real town map
- [x] NPC dialogue system
- [x] Town exit → cutscene → mine
- [x] Mine dungeon map
- [x] Battle system (turn-based, class abilities)
- [x] Boss room — Shaman intro + moral choice
- [x] Mine exit → new area
- [ ] Save system
- [ ] MVP feature pass (portraits, sprites, HUD, levelling, alignment)
- [ ] Dev sign-off
- [ ] Polish + playtester pass

---

## Infrastructure reference

| File | Purpose |
|---|---|
| `autoloads/SignalBus.gd` | All game signals |
| `autoloads/StatRegistry.gd` | Stat tree, action modifiers, Luck derivation |
| `autoloads/GameClock.gd` | Always-on clock |
| `autoloads/PlayerData.gd` | Class, path, flags, ghost flags, age, equipment, level, XP |
| `autoloads/SceneManager.gd` | Game state loader, payload passing |
| `autoloads/DialogueManager.gd` | NPC dialogue trees, condition evaluation |
| `scenes/main/` | Root shell, persistent OverlayHost |
| `scenes/map/` | WASD movement, town/mine/crossroads regions, encounter triggers, stat events |
| `scenes/battle/Battle.gd` | Full turn-based battle system |
| `scenes/battle/HitFlash.gdshader` | Hit colour flash |
| `scenes/hud/` | Persistent overlay, tabs: Stats, Equipment, Quest, Map |
| `scenes/cutscene/` | Payload-driven: `mine_entry`, `shaman_intro`, and `mine_exit` sequences |
| `scenes/debug/` | Dev-only overlay — gated by `OS.is_debug_build()` |

**Dev controls** (debug builds only):
- `WASD/arrows` — move
- `P` — skip battle to victory (Battle scene)
- `L` — open location/spawn loader (Map scene)
- `B` `H` `C` — force state transitions (spike-era, remove in Stage 10)
- `1` / `2` — set Pure / Mixed path
- `3` — bump Social + gold
- `4` — bump Intelligence
- `0` — reset stats

---

## Repo structure

```
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
  audio/          (gitignored — local only, not committed)
docs/
  HANDOVER.md
  vertical_slice_plan.md
  stat_registry.md
  art_direction.md
project.godot
```

**Audio files are gitignored.** Store in `assets/audio/` locally. Do not commit binary audio to the repo — this is standard practice. See notes in `Audio` section of locked decisions.

---

## Production order after vertical slice
1. Class selection / character creation screen
2. Main quest — remaining acts and locations
3. Steam page + first devlog — do not wait until launch

---

## How to use this document

Paste raw URL at the top of any new agent session, then state the current stage.

**Raw URL:** `https://raw.githubusercontent.com/jball348-svg/RPG_GAME1/main/docs/HANDOVER.md`

Update this file when decisions change or phase status changes. It is the shared memory.
