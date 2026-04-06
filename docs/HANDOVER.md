# Project Handover — RPG_GAME1
> **For LLM agents.** Read this before doing anything. It is the source of truth for where this project is and what has been decided. Do not contradict decisions marked as locked without flagging it explicitly to the developer first.

---

## Who you are working with

**Developer:** John — solo developer, "vibe coder". Works with AI-assisted tooling. Primary stack is Next.js/React/Vercel for web projects. This project is his first Godot game. He is decisive, moves fast, and has strong creative instincts. He does not need hand-holding on concepts but does need concrete, specific technical help. Do not over-explain. Do not pad responses. Be direct.

**Working style:** John uses the GSD (Get Shit Done) methodology. He scopes hard, cuts ruthlessly, and ships. When he asks for your opinion, give it honestly — including pushback if something is out of scope or a bad idea.

**AI stack in use:**
- Claude — architecture, scoping, design decisions, prompt generation
- Windsurf / Cascade — implementation
- GitHub MCP — direct repo operations (John's account is `jball348-svg`)

---

## The game — one paragraph

An archetypal high fantasy RPG where the player chooses at the start whether they are **Pure** (one class, optionally specialised) or **Mixed** (multiclass, versatile but diluted). This choice is the spine of the game's central conflict: a war between Pure and Mixed factions. The allegory is intentional and not subtle — it mirrors bigotry and racism using the fantasy genre as the frame. The game features a deep but legible stat system, classic JRPG pacing (top-down 2D map, turn-based battle, HUD menus, cutscenes), and a constant low-level dopamine loop where every action contributes to character growth.

**Engine:** Godot 4 (GDScript)
**Platform target:** PC / Steam (v1.0)
**Repo:** `github.com/jball348-svg/RPG_GAME1`

---

## Locked decisions — do not revisit without flagging

These have been explicitly decided and should not be re-opened unless John raises them.

| Decision | Detail |
|---|---|
| Engine | Godot 4, GDScript |
| Genre | 2D top-down RPG, pixel art |
| Setting | Archetypal high fantasy — all tropes, played straight |
| Central conflict | Pure vs Mixed class war — allegory for bigotry/racism |
| Class system | Pure path (1 class + optional specialisation) vs Mixed path (multiclass, watered down) |
| Stat system | 6 top-level stats, skills beneath each, open registry (add skills during production) |
| Visibility tiers | Tier 1 always shown, Tier 2 unlocked at milestones, Tier 3 ghost/never shown |
| Luck | Derived stat under Social — not directly trained, calculated from Charm + Reputation + Empathy |
| Holy stat | Named "Holy" (not Spirit). Skills: Faith, Intuition, Peace, Justice |
| Will stat | Named "Will" (not Willpower). Skills: Resolve, Focus, Resistance |
| Magik | Stylised with a 'k'. Skills: Spellcasting, Attunement, Mana |
| Time system | Always-on clock, ~2× real time, never pauses, accelerates on rest/sleep, Age is a stat |
| Ghost layer | Hidden flags and stats that silently influence world — player never sees them directly |
| Pure/Mix flag | Not a stat. A flag + reputation score. Lives in PlayerData.gd |
| Tooling | Notion (planning), GitHub (code + docs), Aseprite (art, later) |
| Art approach | Free CC0 asset packs (Kenney.nl, OpenGameArt, itch.io) + curation for consistency |

---

## V1.0 scope — locked

**In scope:**
- Full main quest arc, playable start to finish
- Class selection — Pure and Mixed paths, all mechanical consequences
- Specialisation trees within Pure classes
- Stat system fully operational
- Four game states: Map, Battle, HUD, Cutscene — with clean transitions
- Enough world to serve the main quest (~6–10 locations, key NPCs, Pure/Mixed factions)
- Battle system with class abilities and stat integration
- Save system (full stat snapshot, quest state, clock, class, location)
- PC / Steam as platform target

**Explicitly out of scope for v1.0:**
- Guilds
- Side quests
- Open world / free roam
- Post-game content
- Crafting
- Housing / base building
- Economy / trading system
- Companion system (beyond the Shaman recruit mechanic in the core loop)
- Mounts
- Dynamic weather
- Full faction reputation system
- Multiplayer
- Mod support

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

**Open registry principle:** The skills listed are a starting set. New skills are added during production as content demands them. To add a skill: add a key to `stats` Dictionary in `StatRegistry.gd` and add entries to `action_modifiers`. No architectural change required.

Full design doc: `docs/stat_registry.md`

---

## Core loop — the reference scenario

This is the concrete 20-minute player experience that every system must serve. It is the vertical slice target.

1. **Load save** → player is in a town near a Kobold-occupied mine
2. **Town (map state)** → free roam, NPC conversations, shops
   - NPC intel: mine info, gated by Social stat + gold threshold
   - Unmissable NPC: alerts to moral choice ahead (recruit or kill the Half-Kobold Orc Shaman)
   - Bookstore: player just unlocked a new Destruction spell level, learns it here (Intelligence gate)
3. **Leave town** → prompted, point-of-no-return warning, confirm
4. **Cutscene** → class-specific mine entrance animation, current equipment loadout visible
5. **Mine dungeon (map state)** → navigation, Kobold encounters, stat ticks on every action
6. **Battle (battle state)** → Kobold fights, new spell available, class abilities, stat engine firing
7. **Boss room (moral choice)** → meet the Half-Kobold Orc Shaman
   - Recruit → Mixed stat boosts, companion added, Pure reputation slightly drops
   - Kill → Pure reputation up, loot, ghost flag set (world remembers)
8. **Exit mine** → new map area revealed, main quest path opens, loop complete

**Key design notes from this loop:**
- Information gating (stat + gold thresholds on NPC dialogue) is a reusable pattern — build it once, use everywhere
- The Shaman is a Mixed-race being — the moral choice IS the allegory in action
- Equipment is visible in cutscenes and HUD but NOT on map or battle sprites
- The stat engine runs constantly through every step — it never sleeps
- The Pure/Mix flag affects NPC dialogue, shop access, and ghost flags from the very first interaction

---

## Four game states

| State | What happens | Stat activity |
|---|---|---|
| Map | Top-down movement, NPC interaction, exploration | Movement, Social, Endurance ticking |
| Battle | Turn-based combat, skills, spells | Strength, Spellcasting, Will, Holy ticking |
| HUD | Inventory, equipment, skill tree overlay | Minimal — clock still runs |
| Cutscene | Scripted NPC movement, dialogue, automated sequences | Clock runs, specific story flags fire |

Transitions: Map ↔ Battle, Map ↔ Cutscene, Map + HUD overlay (HUD does not replace map).

---

## Pre-production status — COMPLETE ✅

All 8 pre-production steps are done. The project is now in **production**.

| Step | Status |
|---|---|
| 1. One-page pitch | ✅ Complete |
| 2. Scope document | ✅ Complete |
| 3. World and setting | ✅ Complete |
| 4. Core loop document | ✅ Complete |
| 5. Stat registry | ✅ Complete |
| 6. Technical spike in Godot | ✅ Complete — all 5 days, all 4 criteria passed |
| 7. Art direction document | ✅ Complete — see `docs/art_direction.md` |
| 8. Vertical slice | 🔄 Next — build the core loop scenario for real |

---

## Technical spike — COMPLETE ✅

All four success criteria passed. All five days complete.

- [x] Walk on map → Movement skill increments in debug panel
- [x] Press attack in battle → Strength increments
- [x] Clock runs across all four state transitions without pausing
- [x] Pure/Mix flag → NPC shows different dialogue line

### Infrastructure proven and in place

| File | Purpose |
|---|---|
| `autoloads/SignalBus.gd` | All game signals: action_performed, stat_changed, clock_ticked, new_day, state_changed, flag_set |
| `autoloads/StatRegistry.gd` | Full stat tree, action_modifiers map, temp modifier system, derived Luck, clock-driven decay |
| `autoloads/GameClock.gd` | Always-on clock at 2× real time, set_speed_multiplier() for rest/sleep, day rollover |
| `autoloads/PlayerData.gd` | Class, path, specialisation, flags, ghost_flags, age (tied to clock), equipment slots |
| `autoloads/SceneManager.gd` | Exclusive game-state loader for Map / Battle / Cutscene |
| `scenes/main/` | Root shell with StateHost + persistent OverlayHost |
| `scenes/map/` | Placeholder map, WASD movement, stat event emission |
| `scenes/battle/` | Attack + Cast Spell buttons, stat events, round-trip to map |
| `scenes/hud/` | Persistent overlay, clock/status, stat summary, equipment placeholders |
| `scenes/cutscene/` | Scripted sequence, Pure/Mixed dialogue branching |
| `scenes/debug/` | Dev-only stat/clock/flag overlay — remove before vertical slice |

**Spike controls (dev only — remove in vertical slice):**
`WASD/arrows` move · `B` enter battle · `H` toggle HUD · `C` cutscene · `1` Pure path · `2` Mixed path

---

## Current phase — production

**The spike is the skeleton. Production puts flesh on it.**

The immediate next steps in order:

### Step 7 (completing): Art direction document
Before any real asset work, one document must exist: `docs/art_direction.md`.
It must answer: tile resolution (16×16 or 32×32?), colour palette (how many colours, what tone?), reference games for visual style, asset sources to use, and what consistency rules to follow when mixing packs.
**This decision gates all art work. Do not source or place any assets until it exists.**

### Step 8: Vertical slice — the core loop, for real
Build the reference scenario (town → mine → boss → exit) with:
- Real tilesets replacing placeholder rectangles
- Real NPC dialogue system (not spike placeholders)
- Real stat gating on NPC conversations
- Real battle with Kobold enemies and the player's starting class abilities
- Real moral choice with the Half-Kobold Orc Shaman
- Real cutscene at the mine entrance
- Save/load working

This is the first thing a playtester will ever see. It must be complete and polished before production continues into further areas or quest content.

### Production order after vertical slice
1. Class selection screen (character creation)
2. Save system (full stat + quest + clock snapshot)
3. Main quest — remaining acts and locations
4. Polish pass on vertical slice
5. Steam page + first devlog (marketing starts here — not at launch)

---

## Repo structure

```
autoloads/          Global singletons (always running)
  SignalBus.gd
  StatRegistry.gd
  GameClock.gd
  PlayerData.gd
  SceneManager.gd
scenes/
  main/             Entry point
  map/              Top-down map state
  battle/           Battle state
  hud/              HUD overlay
  cutscene/         Cutscene state
  debug/            Dev-only spike overlay (remove before vertical slice)
assets/
  placeholder/      Spike-only — replace entirely during vertical slice
docs/
  HANDOVER.md       This file — LLM context document (keep current)
  stat_registry.md  Stat design reference
  spike_progress.md Spike day-by-day log (archived — spike complete)
  art_direction.md  Art direction decisions (to be created)
project.godot       Godot project config
```

---

## How to use this document

**Starting a new session:** Paste the raw URL or contents at the top of your conversation, then state what you are working on. Example:

> "Here is the project context: [paste HANDOVER.md]. I am working on the art direction document. Help me make the decisions and write `docs/art_direction.md`."

**After each session:** Update this document if any locked decisions change, new decisions are made, or phase status changes. The HANDOVER is the shared memory. Keep it current or it becomes useless.

**Raw file URL:** `https://raw.githubusercontent.com/jball348-svg/RPG_GAME1/main/docs/HANDOVER.md`
