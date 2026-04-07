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

**Known issues (deferred to Stage 9 polish):**
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

**Verification:**
- [x] Press `E` near intel NPC with low Social/gold — gets basic info only
- [x] Press `E` near intel NPC with high Social/gold — gets full mine detail
- [x] Press `E` near moral choice NPC — warning fires, flag `shaman_warning_given` set, repeat fallback line appears on revisit
- [x] Press `E` near bookstore NPC with low Intelligence — locked message
- [x] Press `E` near bookstore NPC with high Intelligence — unlock dialogue, then repeat acknowledgement on revisit
- [x] Dialogue box renders correctly in the bottom screen band with speaker name, portrait placeholder, text, and advance prompt
- [x] Clock keeps running during dialogue
- [x] Stats relevant to gates visible in debug panel for testing (including debug bump controls)

**Done state:** Three wired, conditionally branching NPCs are in the town.

---

## Stage 3 — Town exit and mine entrance cutscene
**Status:** ✅ Complete (Slice Day 3 resolved)

**Goal:** Leaving the town triggers a point-of-no-return prompt, plays a lightweight but clear transition cutscene, and lands the player in the mine start map.

**Already complete:**
- [x] North exit `Area2D` + confirmation prompt wired in town map
- [x] Exit trigger arm timing and top-half guard prevent popup on scene load

**Day 3 implementation plan (do not over-art):**
- [x] **Build the mine start map stub (minimum viable):**
  - Uses existing tileset assets in `assets/art/tilesets/basic caves and dungeons 32x32 standard - v1.0` (`tiles/tiles-all-32x32.png` + `assets/assets-all.png`)
  - Small mine entrance map variant built in `Map.gd`: entry chamber + short corridor + `MineSpawn` marker handoff
  - Full dungeon layout and encounter spacing remain Stage 4 scope
- [x] **Rework cutscene into a transition sequence (placeholder quality is fine):**
  - Keeps simple actor block visuals
  - Sequence now: confirm exit → player movement beat → sentry/context line → fade transition out
- [x] **Add low-cost personalization in cutscene visuals:**
  - Path tint baseline: Pure = muted gold, Mixed = muted teal
  - Class accent tint overlay from selected class/specialisation
- [x] **Wire state handoff into mine map begin:**
  - On cutscene end, `PlayerData.current_region/current_location` are set to mine entry
  - Returns to `map` state and spawns at mine entrance marker
- [x] **Keep stat meaning on transition:**
  - One-time increment applied on confirm (`will.resolve`, `holy.faith`) guarded by `mine_entry_commit_applied` flag

**Day 3 verification checklist:**
- [x] Walk to north exit → confirmation popup appears
- [x] Cancel → player remains in town with no state break
- [x] Confirm → cutscene plays with path/class-reactive player tint
- [x] Cutscene completes → mine map loads at entrance spawn
- [x] Debug panel shows `will.resolve` and `holy.faith` increments

**Done state:** Town exit → cutscene → mine start is fully playable and stable, with clear path/class flavor and no blocked progression.

---

## Stage 4 — Mine dungeon map
**Status:** ✅ Complete (Slice Day 4 resolved)

**Goal:** A dungeon map for the mine. Navigable, atmospheric, with Kobold encounter trigger zones.

**Day 4 kickoff implemented:**
- [x] Replace mine-entry stub with a larger runtime blockout in `Map.gd` (entrance chamber, west/east branches, antechamber, boss chamber, post-boss exit corridor)
- [x] Collision pass is active on new mine geometry via existing blocking-layer world-collision build
- [x] Ordered encounter trigger scaffolding added (4 zones) with progression flags (`mine_encounter_progress`, `mine_boss_ready`)
- [x] Boss trigger placeholder + mine exit gate unlock flow added (`mine_boss_resolved`, `mine_exit_unlocked`, `mine_cleared`)
- [x] Responsive mine objective/status hint + viewport-aware confirmation dialog sizing added for map overlays
- [x] Cross-overlay stability pass started in map/HUD/dialogue/cutscene (remaining manual verification tracked below)

**Tasks:**
- [x] Dungeon/cave tileset sourced and available at `assets/art/tilesets/basic caves and dungeons 32x32 standard - v1.0`
- [x] Move runtime mine blockout into a TileMap editor-authored map (final Stage 4 map-delivery requirement)
- [x] Collision on all walls and impassable tiles (runtime blockout pass)
- [x] Place Kobold encounter trigger zones (3–5 encounters before the boss)
- [x] Place boss room trigger zone (separate from regular encounters)
- [x] Place mine exit trigger zone (only accessible after boss room resolved)
- [x] Atmospheric details: torch placement, dead ends, visual sense of depth
- [x] Persistent overlay sizing/alignment pass completed and merged before Stage 4 sign-off

**Verification:**
- [x] Walk through mine blockout — collision works, no shortcuts to boss room
- [x] Mine reads as a mine: dark, stone, atmospheric
- [x] Encounter zones are placed and progression-gated in order
- [x] Boss room trigger and post-boss exit-gate unlock flow are wired
- [x] Exit remains blocked until boss room placeholder resolve flag is set
- [x] Overlay sizing/alignment is stable in map + cutscene + HUD + dialogue + confirmation popup at `480x270` internal / `1280x720` window
- [x] Headless smoke run passes: `godot --headless --path . --quit-after 4`

**Done state:** The mine exists as a real designed level, and overlay sizing/alignment issues are resolved for Day 4 sign-off.

---

## Stage 5 — Battle system
**Status:** ✅ Complete (Slice Day 5 resolved)

**Goal:** Real turn-based battle. Kobold enemy type. Player class abilities.

**This is the biggest single stage. Budget accordingly.**

**Implemented battle pass:**
- [x] Knight battle sprite uses `assets/art/player/universal-lpc-sprite_male_01_full.png`
- [x] Battlemage battle sprite uses `assets/art/battle/LPC_starhat/sample.png`
- [x] Kobold enemy sprite uses `assets/art/battle/LPC imp/attack - vanilla.png`
- [x] Player presentation faces right and enemy presentation faces left in battle
- [x] Spell/Item submenu auto-sizes and opens above the bottom battle menu so options stay on-screen

**Tasks:**
- [x] Battle scene redesign: player party (left), enemies (right), action menu (bottom)
- [x] Turn order: player turn → enemy turn, repeat until resolved
- [x] Player action menu: Attack, Spell (if Magik class), Use Item, Flee
- [x] Kobold enemy: HP, attack damage, simple AI
- [x] One Pure class and one Mixed class with distinct working abilities
- [x] Damage: Physical.Strength + weapon modifier vs enemy defence
- [x] Spell damage: Magik.Spellcasting + spell power vs enemy resistance
- [x] Victory: loot roll → return to map at correct position
- [x] Defeat: game over screen
- [x] Stat increments on every action
- [x] Battle backgrounds: static image per environment
- [x] Wire encounter trigger zones from Stage 4

**Verification:**
- [x] Trigger encounter → battle launches
- [x] Attack, Cast Spell, Flee all work
- [x] Kobold attacks back
- [x] Victory → loot → back to mine map
- [x] Defeat → game over
- [x] Stats increment (debug panel confirms)
- [x] Pure and Mixed classes feel distinct
- [x] Requested LPC knight, battlemage, and kobold battle art are wired into `Battle.gd`
- [x] Spell and Item submenu panels remain fully visible at the slice battle viewport
- [x] Headless smoke run passes: `godot --headless --path . --quit-after 4`

**Done state:** The mine has real, functional combat.

---

## Stage 6 — Boss room and moral choice
**Status:** ⬜ Not started

**Goal:** The Half-Kobold Orc Shaman encounter. The moral choice. Branching outcomes.

**Tasks:**
- [ ] Boss room trigger → cutscene: Shaman emerges, addresses player
- [ ] Dialogue presents choice: recruit or fight
- [ ] Recruit branch: `shaman_recruited = true`, Mixed stat boosts, companion follows, Pure ghost rep decrements
- [ ] Fight branch: boss battle, `shaman_killed = true`, loot, `world_remembers_shaman_killed = true` ghost flag
- [ ] Mine exit unlocks after either branch
- [ ] Pure/Mixed path affects Shaman's opening line

**Implementation plan:**
1. **Replace the Stage 6 placeholder handoff**
   - Update `scenes/map/Map.gd` so `_on_mine_boss_trigger_body_entered()` stops routing straight into `BATTLE_KIND_BOSS_PLACEHOLDER` once Stage 6 work starts.
   - Reuse the existing `SceneManager` payload flow and send the player into `cutscene` first with a sequence identifier such as `shaman_intro` plus return-region/location/suppressed-trigger data.
   - Keep the current boss-trigger suppression behavior so re-entry into the room does not immediately retrigger while the branch is unresolved.
2. **Make `Cutscene.gd` payload-driven for multiple sequences**
   - Refactor the current mine-entry cutscene logic behind a `cutscene_id` or similar payload key so the scene can support both `mine_entry` and `shaman_intro` without duplicating a second state scene.
   - Add Shaman-specific actor staging, camera beats, and a path-reactive opening line that branches on `PlayerData.is_pure()` / `PlayerData.is_mixed()`.
   - Add a simple two-choice UI at the end of the intro beat: `Recruit` and `Fight`.
3. **Implement the recruit branch in map/cutscene state, not battle**
   - On recruit, set `shaman_recruited = true`, `mine_boss_resolved = true`, and `mine_exit_unlocked = true` via `PlayerData.set_flag()`.
   - Apply the intended Mixed reward and Pure consequence immediately after the choice: stat bumps for Mixed-facing resolution, plus the ghost/reputation decrement flagging needed for later world reactivity.
   - Return the player to `map` at a safe post-boss-room position with a status payload so `Map.gd` can refresh the mine hint, gate visuals, and suppressed-trigger state.
4. **Replace the boss placeholder in `Battle.gd` with a real boss encounter kind**
   - Add a new encounter kind for the kill path instead of overloading `BATTLE_KIND_STANDARD`.
   - Give the Shaman battle its own HP, damage, resistance/defence tuning, intro log line, and victory resolution path.
   - On victory, set `shaman_killed = true`, `world_remembers_shaman_killed = true`, `mine_boss_resolved = true`, and `mine_exit_unlocked = true`, then return to map with loot/status text.
5. **Resolve aftermath state in `Map.gd`**
   - Keep `_restore_mine_progress_state()` as the authoritative place that opens the exit gate after `mine_boss_resolved` is set.
   - Update mine objective text so the sequence becomes: clear encounters → boss room → exit trigger.
   - Ensure the boss room no longer retriggers after either recruit or kill and that exit prompt behavior stays unchanged once unlocked.
6. **Verification order for the Stage 6 pass**
   - Test the intro line as Pure and Mixed using the existing debug path toggles.
   - Run the recruit path end to end: boss trigger → intro → recruit → map return → exit unlock.
   - Run the kill path end to end: boss trigger → intro → boss battle → victory → map return → exit unlock.
   - Re-enter the boss room after resolution and confirm no repeat trigger.
   - Finish with `godot --headless --path . --quit-after 4` plus one manual mine-to-exit playthrough.

**Verification:**
- [ ] Recruit path works end to end
- [ ] Kill path works end to end
- [ ] Pure and Mixed players get different opening dialogue
- [ ] Ghost flags set correctly

---

## Stage 7 — Mine exit and area transition
**Status:** ⬜ Not started

**Goal:** Leaving the mine reveals a new area. The main quest path opens.

**Tasks:**
- [ ] Mine exit trigger → cutscene: player emerges into new region
- [ ] New region map stub: road, distant mountains, signpost
- [ ] Quest flags: `mine_cleared = true`, `main_quest_path_open = true`
- [ ] Shaman companion appears in exit cutscene if recruited

**Verification:**
- [ ] Exit → cutscene → new area
- [ ] Quest flags set
- [ ] Companion present if recruited
- [ ] New area feels like arrival

**Done state:** The core loop completes.

---

## Stage 8 — Save system
**Status:** ⬜ Not started

**Goal:** Full save and load. Every state that matters is persisted.

**Tasks:**
- [ ] `SaveManager` autoload: `save_game()`, `load_game()`, `has_save()`
- [ ] Saves: full StatRegistry.stats, PlayerData, GameClock time, location, quest flags
- [ ] Save file: `user://save_game.json`
- [ ] Auto-save triggers: map entry, dialogue complete, battle victory, moral choice resolved
- [ ] On launch: load if save exists, else boot to new game defaults

**Verification:**
- [ ] Play 5 mins, quit, relaunch — all state restored
- [ ] Clock resumes from saved time
- [ ] Ghost flags persist

**Done state:** Progress is never lost.

---

## Stage 9 — Polish and playtester pass
**Status:** ⬜ Not started

**Goal:** Loop complete. Make it good enough to put in front of a real person.

**Tasks:**
- [ ] Remove spike dev controls (B, H, C, 1, 2)
- [ ] Remove debug panel from release build
- [ ] Audio: ambient town, ambient mine, battle music, victory sting
- [ ] SFX: footstep, attack, spell cast, dialogue advance, menu sounds
- [ ] Fade to black between major state transitions
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
| 9 | Polish + playtester pass | ⬜ |

---

## How to use this document

At the start of each Cascade/Claude session:

> "Read `docs/HANDOVER.md` and `docs/vertical_slice_plan.md`. I am on Vertical Slice Stage X — [name]. Help me complete the tasks."

After each session: tick completed tasks, update the status table.
When a stage passes all verification checks: mark ✅ and start the next.
