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

## Pre-production status

| Step | Status |
|---|---|
| 1. One-page pitch | ✅ Complete |
| 2. Scope document | ✅ Complete |
| 3. World and setting | ✅ Complete |
| 4. Core loop document | ✅ Complete |
| 5. Stat registry | ✅ Complete |
| 6. Technical spike in Godot | 🔄 In progress — Day 1 done |
| 7. Art direction document | ⬜ Not started |
| 8. Vertical slice | ⬜ Not started |

---

## Technical spike — current status

**Goal:** Prove four things before building the game proper.

**Success criteria (all four must be green before spike is complete):**
- [ ] Walk on map → Movement skill increments in debug panel
- [ ] Press attack in battle → Strength increments
- [ ] Clock runs across all four state transitions without pausing
- [ ] Pure/Mix flag → NPC shows different dialogue line

### Day 1 — COMPLETE ✅
All four autoloads created and pushed to repo. `project.godot` configured with autoloads pre-registered.

**Files created:**
- `autoloads/SignalBus.gd` — all game signals: action_performed, stat_changed, clock_ticked, new_day, state_changed, flag_set
- `autoloads/StatRegistry.gd` — full stat tree, action_modifiers map, temp modifier system, derived Luck, clock-driven decay
- `autoloads/GameClock.gd` — always-on clock at 2× real time, set_speed_multiplier() for rest/sleep, day rollover
- `autoloads/PlayerData.gd` — class, path, specialisation, mixed_classes, flags, ghost_flags, age (tied to clock), equipment slots, inventory sketch
- `project.godot` — autoloads registered, main scene pointed at `scenes/main/Main.tscn`
- `docs/stat_registry.md`, `docs/spike_progress.md`
- Scene folder structure: `scenes/main`, `scenes/battle`, `scenes/hud`, `scenes/cutscene`, `assets/placeholder`

### Day 2 — TODO
**Goal:** SceneManager autoload + Map scene. Player can move around. Walking fires stat events. Debug panel shows Movement ticking.

**Tasks:**
1. Create `autoloads/SceneManager.gd` — `change_state(new_state: String)` function, loads correct scene, handles transitions
2. Create `scenes/main/Main.tscn` + `Main.gd` — entry point, initialises game, calls SceneManager
3. Create `scenes/map/Map.tscn` + `Map.gd` — placeholder rectangle tilemap, coloured square player, WASD/arrow movement
4. Every step emits `SignalBus.action_performed({ "type": "walk" })`
5. Create `scenes/debug/DebugPanel.tscn` — overlay showing all stat values live, clock time, active flags
6. Verify: walk on map → Movement stat increments visibly in debug panel

### Day 3 — TODO
Battle scene. Two buttons (Attack, Cast Spell). Each fires correct signal. Transition from map to battle and back. Clock does not pause during transition.

### Day 4 — TODO
HUD scene (overlay, not replacing map). Cutscene scene — NPC moves, dialogue box reads Pure/Mix flag, shows one of two lines.

### Day 5 — TODO
Wire everything together. Run all four success criteria. Debug anything broken.

---

## Repo structure

```
autoloads/          Global singletons (always running)
  SignalBus.gd
  StatRegistry.gd
  GameClock.gd
  PlayerData.gd
scenes/
  main/             Entry point
  map/              Top-down map state
  battle/           Battle state
  hud/              HUD overlay
  cutscene/         Cutscene state
assets/
  placeholder/      Spike-only placeholder art
docs/
  HANDOVER.md       This file — LLM context document
  stat_registry.md  Stat design reference
  spike_progress.md Day-by-day checklist
project.godot       Godot project config
```

---

## How to use this document

**Starting a new session:** Paste this document (or link to it) at the top of your conversation with the agent, then state what you are working on today. Example:

> "Here is the project context: [paste HANDOVER.md]. I am working on Day 2 of the technical spike. Help me build the SceneManager and Map scene."

**After each session:** Update `docs/spike_progress.md` to reflect what was completed. Update this document if any locked decisions change or new decisions are made.

**This document lives at:** `docs/HANDOVER.md` in the repo. Keep it current. It is the shared memory of the project.
