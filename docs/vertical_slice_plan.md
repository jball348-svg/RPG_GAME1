# Vertical Slice Plan — RPG_GAME1
> Same structure as the technical spike: define the goal, build the minimum to prove it, verify, lock, move on.
> Do not start the next stage until the current one passes its verification check.
> Each stage is a Cascade/Claude session (or a few). Some take one sitting, some take several.

---

## What the vertical slice must deliver

A complete, polished, playable run of the core loop:
**Load → Town → Leave → Cutscene → Mine → Battles → Boss (moral choice) → Exit**

When a playtester can complete that loop without guidance and find it fun, the vertical slice is done.
Everything else is production.

---

## Stage 1 — Real town map (editor-designed)
**Status:** ✅ Complete

**Goal:** A town map designed in Godot's TileMap editor, not assembled in GDScript at runtime.

**What was built:**
- Real TileMap-authored starting town (Frontier Hamlet) using sourced CC0 outdoor tileset
- Runtime tile generation removed — map data lives in `Map.tscn`
- Collision built dynamically from tile layer data via `_build_world_collision()` in `Map.gd`
- `TownExitTrigger` Area2D at north edge — fires confirmation dialogue, deferred arm prevents false trigger on load
- Camera follows player, bounded to map rect via `get_used_rect()`
- Viewport set to 480×270 internal / 1280×720 window, stretch mode `viewport`, aspect `keep`
- Player placeholder upgraded to gold 32×32 square sprite

**Known issues (deferred to Stage 10 polish):**
- Some tree tiles do not block — collision layer assignment incomplete on a subset of props

---

## Stage 2 — NPC dialogue system
**Status:** ✅ Complete (Slice Day 2)

**Goal:** A reusable dialogue system that any NPC in the game can use. Supports stat gates and gold gates.

**Why this matters:** Three NPCs are needed for the core loop (intel NPC, moral choice NPC, bookstore). The system that powers them will power every NPC in the game. Design it once, reusable forever.

**Tasks:**
- [x] Build `DialogueManager` autoload — loads dialogue data, manages conversation state, emits signals
- [x] Dialogue data format: GDScript Dictionary (or JSON) — each NPC has a dialogue tree with nodes, conditions, branches
- [x] Condition types: `stat_gte` (stat path + minimum value), `gold_gte` (minimum gold), `flag_set` (flag name), `pure_path`, `mixed_path`
- [x] `interact` input action added to `project.godot` — mapped to `E`
- [x] NPC scene includes interaction zone and solid body collision so NPCs are physically blocking
- [x] Dialogue box scene: bottom-third panel, speaker header, portrait slot (left), text body, advance prompt (`E` or Space), resized to a smaller footprint
- [x] Write dialogue for the three core loop NPCs:
  - **Intel NPC** (village elder / guard): base info always; full mine detail gated on `social.charm >= 10` AND `gold >= 20`
  - **Moral choice NPC** (travelling merchant / wanderer): one-time warning node sets flag `shaman_warning_given`, then falls back to repeat acknowledgement on revisits
  - **Bookstore NPC**: unlock node if `intelligence.understanding >= 10`, locked dialogue below threshold, repeat acknowledgement after unlock
- [x] Place and wire the three NPC nodes in `Map.tscn`

**Verification:** All checks passed.

**Done state:** Three wired, conditionally branching NPCs are in the town.

---

## Stage 3 — Town exit and mine entrance cutscene
**Status:** ✅ Complete (Slice Day 3 resolved)

**Goal:** Leaving the town triggers a point-of-no-return prompt, plays a lightweight but clear transition cutscene, and lands the player in the mine start map.

**Verification:** All checks passed.

**Done state:** Town exit → cutscene → mine start is fully playable and stable, with clear path/class flavor and no blocked progression.

---

## Stage 4 — Mine dungeon map
**Status:** ✅ Complete (Slice Day 4 resolved)

**Goal:** A dungeon map for the mine. Navigable, atmospheric, with Kobold encounter trigger zones.

**Verification:** All checks passed.

**Done state:** The mine exists as a real designed level, and overlay sizing/alignment issues are resolved for Day 4 sign-off.

---

## Stage 5 — Battle system
**Status:** ✅ Complete (Slice Day 5 resolved)

**Goal:** Real turn-based battle. Kobold enemy type. Player class abilities.

**What was built:**
- Full `Battle.gd` turn-based system (~42KB): player turn → enemy turn alternation
- Player actions: Attack, Spell (Battlemage only), Item (Health Potion), Flee, class Ability
- Fighter class: +2 strength passive, Shield Bash ability (damage + Stagger, 4-turn cooldown)
- Battlemage class: Arcane Strike (physical + Magik dual damage, 3-turn cooldown), reduced Flamebolt power
- Kobold enemy: HP 30, attack 6, defence 3, resistance 2, 80/20 attack/defend AI, Staggered state support
- HitFlash.gdshader: colour flash on hit; screen shake via Camera2D offset tween on heavy hits
- Sprite bob idle animation via `_process`
- Real art assets wired: LPC knight, LPC battlemage, LPC imp, volcano background, Kenney UI
- HP bars (gradient fill, numeric readout), battle log (4-line rolling), turn indicator
- Victory, defeat, and boss-placeholder sequences all functional
- Responsive layout scaling from 480×270 reference
- `suppressed_trigger_type` + `suppressed_trigger_index` passed back to map to prevent re-trigger

**Verification:** All checks passed.

**Done state:** The mine has real, functional, class-differentiated combat.

---

## Stage 6 — Boss room and moral choice
**Status:** ⬜ Not started

**Goal:** The Half-Kobold Orc Shaman encounter. The moral choice. Branching outcomes. This is the allegory made mechanical — the central premise of the game embodied in a single scene.

**Design notes:**
- The Shaman is a Half-Kobold Orc — mixed-race, liminal, belonging to neither Pure nor Mixed faction fully. He is the living embodiment of the game's allegory.
- Pure players face the Shaman as a symbol of what they fear. Mixed players face him as a mirror.
- The recruit/kill choice has no "correct" answer. Both paths have costs and rewards. The ghost flags ensure the world remembers.
- The moral weight must come through in the Shaman's dialogue. Treat the writing carefully — it is load-bearing.

**Flags to add to `PlayerData.gd`:**
- `shaman_recruited` (bool flag) — set on recruit path
- `shaman_killed` (bool flag) — set on kill path
- Ghost flags: `world_remembers_shaman_killed`, `world_remembers_shaman_spared`, `pure_rep_shaman_mercy`, `mixed_betrayed_own`

**Implementation plan:**
1. **Replace the Stage 6 placeholder handoff in `Map.gd`**
   - `_on_mine_boss_trigger_body_entered()` currently routes to `BATTLE_KIND_BOSS_PLACEHOLDER`.
   - Replace this with a `cutscene` state payload using `cutscene_id = "shaman_intro"` plus return-region/location/suppressed-trigger data.
   - Keep boss-trigger suppression so re-entry into the room does not retrigger while the branch is unresolved.

2. **Make `Cutscene.gd` payload-driven for multiple sequences**
   - Refactor current mine-entry cutscene logic behind a `cutscene_id` key so one scene handles both `mine_entry` and `shaman_intro`.
   - Add Shaman actor staging (distinct coloured sprite — deep purple 64×80 if no art asset available), camera beats, and path-reactive opening line:
     - Pure: *"Another pureblood who fears what they cannot name."*
     - Mixed: *"You carry both bloods. I see the war in you."*
     - Bonus (if `shaman_warning_given` flag is set): append *"Someone warned you. And still you came."*
   - Add a two-button choice panel at the end of the intro beat: **"Speak with the Shaman"** (recruit) and **"Fight"** (fight).

3. **Recruit branch (handled in cutscene/map state, not Battle.gd)**
   - Set flags: `shaman_recruited = true`, `mine_boss_resolved = true`, `mine_exit_unlocked = true`
   - Apply stat boosts: `social.charm +3`, `magik.attunement +2` via `StatRegistry`
   - Set ghost flags:
     - `world_remembers_shaman_spared = true` (always)
     - If Pure path: also `pure_rep_shaman_mercy = true` (Pure player showed mercy — significant)
   - Return player to map with status text: *"The Shaman lowers his staff. The chamber is quiet."*
   - No combat. No loot. The cost to Pure is reputational (ghost flag), the gain to Mixed is mechanical (stat boost).

4. **Fight branch — real boss encounter in `Battle.gd`**
   - Add `BATTLE_KIND_BOSS_SHAMAN` encounter kind constant.
   - Replace `_run_boss_placeholder_sequence()` with a proper boss flow that checks for this kind.
   - **Shaman stats:** HP 60, attack 9, defence 4, resistance 4
   - **Shaman AI (weighted rotation, resets each turn):**
     - 60%: Attack (physical, flat 9 damage before player defence)
     - 25%: Hex — debuff player, -2 to their next attack roll (apply a `player_hexed` flag, consume on next player attack)
     - 15%: Heal — recover 10 HP (usable ONCE per battle; after use, remove from rotation permanently)
   - **Boss intro log line:** *"The Shaman steps forward. He does not look afraid."*
   - **On victory:**
     - Set flags: `shaman_killed = true`, `mine_boss_resolved = true`, `mine_exit_unlocked = true`
     - Set ghost flags: `world_remembers_shaman_killed = true`
     - If Mixed path: also `mixed_betrayed_own = true` (Mixed player who killed a half-breed — weight this)
     - Loot: 25 gold + add item `shaman_talisman` to inventory (display in loot panel as *"Shaman's Talisman"*)
     - Return to map with status text: *"The Shaman falls. The mine is silent."*
   - **Hex mechanic in `Battle.gd`**: add `_player_hexed: bool` var, set on Hex turn, consume (-2 to attack) on next player physical attack, log it.

5. **Resolve aftermath in `Map.gd`**
   - `_restore_mine_progress_state()` already opens the exit gate when `mine_boss_resolved` is set — no change needed there.
   - Update mine objective text sequence: clear encounters → boss room unlocked → exit trigger.
   - Confirm boss room trigger does not re-fire after either branch resolves.

6. **What NOT to build in this stage:**
   - Companion follow mechanic (recruit = flag only for VS; companion system is post-VS production)
   - Shaman appearing on the map or in the exit cutscene (Stage 7 scope)
   - Multiple fight phases for the boss
   - Any sound/music (Stage 10 scope)

**Verification:**
- [x] Enter boss trigger zone → Shaman intro dialogue fires via `Cutscene.gd` with `cutscene_id = "shaman_intro"`
- [x] Pure player gets Pure-specific opening line
- [x] Mixed player gets Mixed-specific opening line
- [ ] `shaman_warning_given` flag set → Shaman references the warning
- [x] "Speak with the Shaman" → recruit flags set, stat boosts applied (`social.charm`, `magik.attunement`), mine exit unlocks, returns to map
- [x] "Fight" → boss battle launches with Shaman HP 60 and correct stats
- [x] Shaman Hex debuff reduces player attack next turn (log confirms, debug panel confirms stat recalc)
- [x] Shaman Heal fires (once only), recovers HP, removed from rotation after use
- [ ] Boss victory → kill flags + ghost flags set, 25 gold + `shaman_talisman` awarded, mine exit unlocks
- [x] Ghost flags correct for all 4 permutations: Pure+recruit, Pure+kill, Mixed+recruit, Mixed+kill
- [x] `mine_boss_resolved` and `mine_exit_unlocked` set after either branch
- [x] Boss trigger does not re-fire on map return (suppressed_trigger wired correctly)
- [x] Stats increment during boss fight (debug panel confirms)
- [x] Clock continues running throughout
- [x] Headless smoke run passes: `godot --headless --path . --quit-after 4`

**Done state:** The moral choice works and has real mechanical and flag consequences. The allegory is embodied in a single scene.

---

## Stage 7 — Mine exit and area transition
**Status:** ⬜ Not started

**Goal:** Leaving the mine reveals a new area. The main quest path opens.

**Tasks:**
- [ ] Mine exit trigger → cutscene: player emerges into new region
- [ ] New region map stub: road, distant mountains, signpost
- [ ] Quest flags: `mine_cleared = true`, `main_quest_path_open = true`
- [ ] Shaman companion appears in exit cutscene if `shaman_recruited` flag is set

**Verification:**
- [ ] Exit → cutscene → new area
- [ ] Quest flags set
- [ ] Companion present if recruited
- [ ] New area feels like arrival

**Done state:** The core loop completes.

---

## Stage 8 — Save system + Broader functionality shoppinglist
**Status:** ⬜ Not started

**Goal:** Full save and load. Every state that matters is persisted. Implement POC/MVP features that will be present in game, such as a character/boss picture for dialogue, class specific map sprites, absolute MVP (spike style) implementation of 'Alignment' with a matrix such as is in d&d and baldurs gate (like this assets/art/Mood Board/bg3-alignment-chart-v0-lb31w8gqv26c1.webp), absolute MVP (spike style) implementation of player HUD - 'player' card with stats, 'equipment' card with helm, armour, weapon, boots, spellbook (for mage) / knight abilities (for knight), quest tab, map tab. Some of this (like map tab) can be placeholder. Absolute MVP (spike style) implementation of equipment loading on/off of player sprite

**Tasks:**
- [ ] `SaveManager` autoload: `save_game()`, `load_game()`, `has_save()`
- [ ] Saves: full StatRegistry.stats, PlayerData (including all flags + ghost flags), GameClock time, location, quest flags
- [ ] Save file: `user://save_game.json`
- [ ] Auto-save triggers: map entry, dialogue complete, battle victory, moral choice resolved
- [ ] On launch: load if save exists, else boot to new game defaults

**Verification:**
- [ ] Play 5 mins, quit, relaunch — all state restored
- [ ] Clock resumes from saved time
- [ ] Ghost flags persist
- [ ] Shaman branch outcome persists correctly across save/load

**Done state:** Progress is never lost.

---

## Stage 9 — Final feature checklist (developer sign-off)
**Status:** ⬜ Not started

**Goal:** Before polish begins, John plays through the complete loop and confirms every feature is working and directionally correct. No code changes unless something is broken or fundamentally wrong. This is a personal review, not an iteration sprint.

**Checklist:**
- [ ] Complete core loop start to finish without using debug controls: Town → Leave → Cutscene → Mine → 3 encounters → Boss choice → Exit
- [ ] Fighter path feels distinct and satisfying in combat — Shield Bash has impact
- [ ] Battlemage path feels distinct and satisfying — versatility is legible
- [ ] Recruit branch feels like a real moral choice, not a soft option
- [ ] Kill branch feels like a real moral choice, not the "easy" path
- [ ] Pure opening line from the Shaman lands as intended allegory
- [ ] Mixed opening line from the Shaman lands as intended allegory
- [ ] Kobold encounters feel appropriately challenging — not trivial, not punishing
- [ ] Boss fight is clearly harder than regular encounters
- [ ] Stat increments are visible and feel meaningful (check debug panel at end of run)
- [ ] All flags correct: `shaman_recruited`/`shaman_killed` and all ghost flags set as expected
- [ ] Clock is running throughout — time passes in the mine
- [ ] HUD overlay is readable and not obstructing gameplay
- [ ] All transitions feel smooth enough for a playtester (town exit, mine entry, battle in/out, mine exit)
- [ ] No progression blockers or softlocks found
- [ ] Anything that feels wrong or missing is logged as a note for Stage 10 or production

**Done state:** John is happy with the game as an unpolished experience. Stage 10 polish can begin.

---

## Stage 10 — Polish and playtester pass
**Status:** ⬜ Not started

**Goal:** Loop complete. Make it good enough to put in front of a real person.

**Tasks:**
- [ ] Remove spike dev controls (B, H, C, 1, 2)
- [ ] Remove debug panel from release build
- [ ] Audio: ambient town, ambient mine, battle music, victory sting
- [ ] SFX: footstep, attack, spell cast, dialogue advance, menu sounds
- [ ] Fade to black between all major state transitions
- [ ] UI pass: dialogue box, HUD, battle menu — match art direction
- [ ] Fix known Stage 1 issues: remaining tree collision
- [ ] At least one NPC portrait
- [ ] Game over screen
- [ ] First external playtester pass

**Verification:**
- [ ] Unknown player completes loop without help
- [ ] No debug text in normal play
- [ ] Audio throughout
- [ ] Smooth transitions

**Done state:** Vertical slice complete.

---

## Current status summary

| Stage | Task | Status |
|---|---|---|
| 1 | Real town map (editor-designed) | ✅ Complete |
| 2 | NPC dialogue system | ✅ Complete (Slice Day 2) |
| 3 | Town exit + mine entrance cutscene | ✅ Complete (Slice Day 3 resolved) |
| 4 | Mine dungeon map | ✅ Complete (Slice Day 4 resolved) |
| 5 | Battle system | ✅ Complete (Slice Day 5 resolved) |
| 6 | Boss room + moral choice | ⬜ |
| 7 | Mine exit + area transition | ⬜ |
| 8 | Save system | ⬜ |
| 9 | Final feature checklist (developer sign-off) | ⬜ |
| 10 | Polish + playtester pass | ⬜ |

---

## How to use this document

At the start of each Cascade/Claude session:

> "Read `docs/HANDOVER.md` and `docs/vertical_slice_plan.md`. I am on Vertical Slice Stage X — [name]. Help me complete the tasks."

After each session: tick completed tasks, update the status table.
When a stage passes all verification checks: mark ✅ and start the next.
