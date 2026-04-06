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
| 6. Technical spike in Godot | 🔄 In progress — Day 3 done |
| 7. Art direction document | ⬜ Not started |
| 8. Vertical slice | ⬜ Not started |

---

## Technical spike — current status

**Goal:** Prove four things before building the game proper.

**Success criteria (all four must be green before spike is complete):**
- [x] Walk on map → Movement skill increments in debug panel
- [x] Press attack in battle → Strength increments
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

### Day 2 — COMPLETE ✅
**Goal achieved:** permanent scene shell is in place, the project boots into the map prototype, walking emits stat events, and the debug overlay shows Movement ticking live.

**Files created / updated:**
- `autoloads/SceneManager.gd` — exclusive game-state loader for Map / Battle / Cutscene
- `scenes/main/Main.tscn`, `scenes/main/Main.gd` — root shell with `StateHost` + persistent `OverlayHost`
- `scenes/map/Map.tscn`, `scenes/map/Map.gd` — bounded placeholder map with 4-direction movement
- `scenes/debug/DebugPanel.tscn`, `scenes/debug/DebugPanel.gd` — persistent overlay showing state, clock, flags, and the stat snapshot
- `project.godot` — `SceneManager` autoload added, `move_up`, `move_down`, `move_left`, `move_right` mapped to `WASD` + arrow keys

**Verification completed:**
- Project now boots successfully into `scenes/main/Main.tscn`
- Startup performs one clean transition into `map`
- Walking emits `SignalBus.action_performed({ "type": "walk" })` once per completed step threshold
- `physical.movement` increases by the existing `0.02` action modifier and appears immediately in the debug panel
- Clock remains visible and continues advancing while the map scene is active

### Day 3 — COMPLETE ✅
**Goal achieved:** battle round-trip proof is now in place. The map can enter battle through a dev-only trigger, combat actions fire stat events, and the project returns cleanly to map without losing the clock or debug overlay.

**Files created / updated:**
- `scenes/battle/Battle.tscn`, `scenes/battle/Battle.gd` — minimal battle proof scene with `Attack`, `Cast Spell`, and `Return to Map`
- `scenes/map/Map.tscn`, `scenes/map/Map.gd` — on-screen spike hint plus temporary `B` trigger into battle
- `scenes/debug/DebugPanel.gd` — title generalized from Day 2 to a spike-wide debug label
- `project.godot` — `debug_battle` on `B` plus reserved Day 4 controls: `toggle_hud`, `debug_cutscene`, `set_path_pure`, `set_path_mixed`

**Verification completed:**
- Entering battle from map goes through `SceneManager.change_state("battle")`
- `Attack` emits `SignalBus.action_performed({ "type": "attack" })` and increments `physical.strength` by the existing `0.05` modifier
- `Cast Spell` emits `SignalBus.action_performed({ "type": "cast" })` and increments `magik.spellcasting` by `0.05` plus `magik.attunement` by `0.02`
- `Return to Map` goes back through `SceneManager.change_state("map")`
- The debug overlay persists and the clock keeps advancing through the full map → battle → map round-trip

### Day 4 — TODO
**Goal:** prove the remaining two spike requirements with the lightest possible implementation: HUD as a persistent overlay, Cutscene as an exclusive state, and Pure/Mixed dialogue branching off `PlayerData.chosen_path`.

**Tasks:**
1. Add a minimal HUD `Control` under `OverlayHost` rather than under `SceneManager`
2. Toggle HUD with `H` while keeping the map visible underneath
3. Block map input while HUD is open, but keep the clock running
4. Show placeholder inventory/equipment framing, current clock, current path/class, and a compact stat summary
5. Add a temporary cutscene trigger on `C` from the map
6. Use `PlayerData.chosen_path` as the spike source of truth; if unset, initialize it to `pure`
7. Add dev-only allegiance switches: `1` sets Pure, `2` sets Mixed
8. Create `scenes/cutscene/Cutscene.tscn` + `Cutscene.gd`
9. Run one short scripted placeholder movement sequence
10. Show one of two dialogue lines based on the current path
11. Return to map through `SceneManager` and verify clock continuity across map, HUD, and cutscene

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
  SceneManager.gd
scenes/
  main/             Entry point
  map/              Top-down map state
  battle/           Battle state
  hud/              HUD overlay
  cutscene/         Cutscene state
  debug/            Persistent debug overlay for the spike
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

**Current spike convention:** gameplay world movement uses dedicated `move_*` actions in `project.godot` (`WASD` + arrow keys). Use `debug_*`, `toggle_hud`, and `set_path_*` for spike-only proof controls. Keep `ui_*` reserved for menus and overlays.

**This document lives at:** `docs/HANDOVER.md` in the repo. Keep it current. It is the shared memory of the project.
