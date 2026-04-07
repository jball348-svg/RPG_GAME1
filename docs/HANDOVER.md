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
| Tile resolution | 32×32. Scrolling map, not screen-shifting. |
| Art tone | Desaturated earth tones, grim beauty, no bright primaries, no cartoon. Refs: Baldur's Gate, LotR, Game of Thrones, Elden Ring |
| Character personalisation | Map = generic class sprite only. Battle + HUD + Cutscene = full equipment/armour render. |

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
- Guilds, side quests, open world / free roam, post-game content
- Crafting, housing, full economy/trading system
- Companion system (beyond the Shaman recruit mechanic in the core loop)
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

**Open registry principle:** Skills are a starting set. Add new ones during production — add a key to `stats` in `StatRegistry.gd` and entries to `action_modifiers`. No architecture change required.

Full design doc: `docs/stat_registry.md`

---

## Character art — by game state

| State | Character art | Personalisation visible? |
|---|---|---|
| Map | Generic class sprite, 32×32 or 32×64, top-down | No — class silhouette only |
| Battle | Larger sprite, side-on/3/4 view, 64×64 or 96×96 | Yes — armour, weapons, equipment rendered |
| HUD / equipment tab | Portrait or full-body character view | Yes — full equipment loadout visible |
| Cutscene | Full character sprite, animated, equipment visible | Yes — armour and loadout rendered |

Map sprites colour-coded for Pure/Mixed (subtle gold vs teal accent) but no equipment shown.
Battle sprites use layered composition: base body + armour layer + weapon layer.
Full art rules: `docs/art_direction.md`

---

## Core loop — the reference scenario

The concrete 20-minute player experience. Every system serves this. It is the vertical slice target.

1. **Load save** → player in a town near a Kobold-occupied mine
2. **Town (map state)** → NPC intel (Social + gold gated), unmissable moral choice alert, bookstore spell unlock (Intelligence gated)
3. **Leave town** → point-of-no-return prompt, confirm
4. **Cutscene** → class-specific mine entrance animation, equipment loadout visible
5. **Mine dungeon (map state)** → navigation, Kobold encounters, stat ticks constantly
6. **Battle (battle state)** → Kobold fights, new spell, class abilities, stat engine firing
7. **Boss room** → Half-Kobold Orc Shaman → recruit (Mixed boosts, companion) or kill (Pure rep up, loot, ghost flag)
8. **Exit mine** → new area revealed, main quest path opens

Key notes: information gating is a reusable pattern. The Shaman IS the allegory in action. Stat engine never sleeps. Pure/Mix flag affects NPCs, shops, ghost flags from first interaction.

---

## Four game states

| State | What happens | Stat activity |
|---|---|---|
| Map | Top-down movement, NPC interaction, exploration | Movement, Social, Endurance ticking |
| Battle | Turn-based combat, skills, spells | Strength, Spellcasting, Will, Holy ticking |
| HUD | Inventory, equipment, skill tree overlay | Minimal — clock still runs |
| Cutscene | Scripted NPC movement, dialogue, automated sequences | Clock runs, story flags fire |

Transitions: Map ↔ Battle, Map ↔ Cutscene, HUD overlays map (does not replace it).

---

## Pre-production — COMPLETE ✅

| Step | Status |
|---|---|
| 1. One-page pitch | ✅ |
| 2. Scope document | ✅ |
| 3. World and setting | ✅ |
| 4. Core loop document | ✅ |
| 5. Stat registry | ✅ |
| 6. Technical spike | ✅ All 5 days, all 4 criteria passed |
| 7. Art direction document | ✅ See `docs/art_direction.md` |
| 8. Vertical slice | 🔄 **Current — in progress** |

---

## Technical spike — COMPLETE ✅

- [x] Walk on map → Movement increments in debug panel
- [x] Attack in battle → Strength increments
- [x] Clock runs across all four state transitions
- [x] Pure/Mix flag → NPC shows different dialogue line

### Proven infrastructure

| File | Purpose |
|---|---|
| `autoloads/SignalBus.gd` | All game signals |
| `autoloads/StatRegistry.gd` | Stat tree, action modifiers, temp modifiers, Luck derivation |
| `autoloads/GameClock.gd` | Always-on clock, speed multiplier, day rollover |
| `autoloads/PlayerData.gd` | Class, path, flags, ghost flags, age, equipment slots |
| `autoloads/SceneManager.gd` | Game state loader |
| `scenes/main/` | Root shell, persistent OverlayHost |
| `scenes/map/` | WASD movement, stat event emission |
| `scenes/battle/` | Attack/cast buttons, stat events, round-trip |
| `scenes/hud/` | Persistent overlay, stat summary, equipment placeholders |
| `scenes/cutscene/` | Scripted sequence, Pure/Mixed dialogue branching |
| `scenes/debug/` | Dev-only overlay — **remove before vertical slice** |

**Dev controls (spike only — remove in vertical slice):**
`WASD/arrows` move · `B` battle · `H` HUD · `C` cutscene · `1` Pure · `2` Mixed · `3` Social+Gold · `4` Intel · `0` Reset stats

---

## Current phase — vertical slice

**Goal:** Build the core loop scenario for real. Town → mine → boss → exit. First thing a playtester sees. Must be polished before production continues.

### Vertical slice task list

- [x] Source and integrate real tilesets (outdoor town + dungeon/mine) per `docs/art_direction.md`
- [x] Replace placeholder map with real tile layout: starting town + mine entrance area
- [x] Build NPC dialogue system — reusable, supports stat gates and gold gates
- [x] Place and wire town NPCs (intel NPC, moral choice NPC, bookstore)
- [ ] Build mine dungeon map layout
- [ ] Build real battle system — turn structure, player actions, Kobold enemy type
- [ ] Implement class abilities for the starting class (one Pure, one Mixed)
- [ ] Build moral choice scene — Half-Kobold Orc Shaman, recruit vs kill branching
- [ ] Build mine exit → new area transition
- [ ] Build class-specific cutscene at mine entrance
- [ ] Implement save/load (full stat + quest state + clock + location)
- [ ] Remove spike dev controls and debug overlay
- [ ] First playtester pass

### Latest implementation update

- Stage 1 town map pass is stable: blocking collision generation, camera bounds, and north exit confirmation are implemented; exit false-fire-on-load is fixed via delayed arming + top-half guard.
- Stage 2 is complete: reusable `DialogueManager`, bottom-band `DialogueBox`, physically solid NPCs + interaction zones, and three wired town NPCs with stat/gold/flag-gated dialogue.
- Debug testing workflow now supports path and gate testing via `1/2` (Pure/Mixed), `3` (Social+Gold), `4` (Intelligence), and `0` (reset stats/gold).
- Stage 3 is now the active focus: town exit → transition cutscene → mine map start handoff.

### Production order after vertical slice
1. Class selection / character creation screen
2. Main quest — remaining acts and locations
3. Steam page + first devlog — do not wait until launch

---

## Repo structure

```
autoloads/          Global singletons
scenes/
  main/             Entry point
  map/              Map state
  battle/           Battle state
  hud/              HUD overlay
  cutscene/         Cutscene state
  debug/            Dev-only (remove before vertical slice)
assets/
  art/              Mood boards (mood_[category]_[desc].png — John sources these)
  placeholder/      Spike-only — replace in vertical slice
docs/
  HANDOVER.md       This file — keep current
  stat_registry.md  Stat design reference
  art_direction.md  Art direction — all asset decisions against this
  spike_progress.md Archived — spike complete
project.godot
```

---

## How to use this document

Paste raw contents or URL at the top of any new agent session, then state what you are working on.

**Raw URL:** `https://raw.githubusercontent.com/jball348-svg/RPG_GAME1/main/docs/HANDOVER.md`

After each session: update this file if decisions change or phase status changes. It is the shared memory. Keep it current.
