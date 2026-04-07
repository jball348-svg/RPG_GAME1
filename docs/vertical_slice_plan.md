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
**Status:** 🔄 Current (Slice Day 3)

**Goal:** Leaving the town triggers a point-of-no-return prompt, plays a lightweight but clear transition cutscene, and lands the player in the mine start map.

**Already complete:**
- [x] North exit `Area2D` + confirmation prompt wired in town map
- [x] Exit trigger arm timing and top-half guard prevent popup on scene load

**Day 3 implementation plan (do not over-art):**
1. **Build the mine start map stub (minimum viable):**
   - Use existing tileset assets in `assets/art/tilesets/basic caves and dungeons 32x32 standard - v1.0` (start with `assets/assets-all.png`)
   - Create a small mine entrance scene: entry chamber + short walkable corridor + spawn marker
   - Keep full dungeon layout and encounter spacing for Stage 4
2. **Rework cutscene into a transition sequence (placeholder quality is fine):**
   - Keep simple actor blocks/sprites (same spirit as spike cutscene)
   - Sequence: confirm exit → player movement beat → short sentry/context line → transition out
3. **Add low-cost personalization in cutscene visuals:**
   - Path tint baseline: Pure = muted gold, Mixed = muted teal
   - Class accent tint overlay based on selected class for readable differentiation without full equipment rendering
4. **Wire state handoff into mine map begin:**
   - On cutscene end, set mine entry location/region fields in `PlayerData`
   - Transition to mine map start scene at the entrance spawn marker
5. **Keep stat meaning on transition:**
   - Increment `will.resolve` and `holy.faith` once when the player commits to entering danger

**Day 3 verification checklist:**
- [ ] Walk to north exit → confirmation popup appears
- [ ] Cancel → player remains in town with no state break
- [ ] Confirm → cutscene plays with path/class-reactive player tint
- [ ] Cutscene completes → mine map loads at entrance spawn
- [ ] Debug panel shows `will.resolve` and `holy.faith` increments

**Done state:** Town exit → cutscene → mine start is fully playable and stable, with clear path/class flavor and no blocked progression.

---

## Stage 4 — Mine dungeon map
**Status:** ⬜ Not started

**Goal:** A dungeon map for the mine. Navigable, atmospheric, with Kobold encounter trigger zones.

**Tasks:**
- [x] Dungeon/cave tileset sourced and available at `assets/art/tilesets/basic caves and dungeons 32x32 standard - v1.0`
- [ ] Design the mine map in TileMap editor: entrance corridor, branching paths, enemy rooms, boss room at the end
- [ ] Collision on all walls and impassable tiles
- [ ] Place Kobold encounter trigger zones (3–5 encounters before the boss)
- [ ] Place boss room trigger zone (separate from regular encounters)
- [ ] Place mine exit trigger zone (only accessible after boss room resolved)
- [ ] Atmospheric details: torch placement, dead ends, visual sense of depth

**Verification:**
- [ ] Walk through mine — collision works, no shortcuts to boss room
- [ ] Mine reads as a mine: dark, stone, atmospheric
- [ ] Encounter zones placed
- [ ] Boss room is clearly a distinct space
- [ ] Exit blocked until boss room flag set

**Done state:** The mine exists as a real designed level.

---

## Stage 5 — Battle system
**Status:** ⬜ Not started

**Goal:** Real turn-based battle. Kobold enemy type. Player class abilities.

**This is the biggest single stage. Budget accordingly.**

**Tasks:**
- [ ] Battle scene redesign: player party (left), enemies (right), action menu (bottom)
- [ ] Turn order: player turn → enemy turn, repeat until resolved
- [ ] Player action menu: Attack, Spell (if Magik class), Use Item, Flee
- [ ] Kobold enemy: HP, attack damage, simple AI
- [ ] One Pure class and one Mixed class with distinct working abilities
- [ ] Damage: Physical.Strength + weapon modifier vs enemy defence
- [ ] Spell damage: Magik.Spellcasting + spell power vs enemy resistance
- [ ] Victory: loot roll → return to map at correct position
- [ ] Defeat: game over screen
- [ ] Stat increments on every action
- [ ] Battle backgrounds: static image per environment
- [ ] Wire encounter trigger zones from Stage 4

**Verification:**
- [ ] Trigger encounter → battle launches
- [ ] Attack, Cast Spell, Flee all work
- [ ] Kobold attacks back
- [ ] Victory → loot → back to mine map
- [ ] Defeat → game over
- [ ] Stats increment (debug panel confirms)
- [ ] Pure and Mixed classes feel distinct

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

**Verification:**
- [ ] Recruit path works end to end
- [ ] Kill path works end to end
- [ ] Pure and Mixed players get different opening dialogue
- [ ] Ghost flags set correctly

**Done state:** The moral choice works and has real mechanical consequences.

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
| 3 | Town exit + mine entrance cutscene | 🔄 Current (Slice Day 3) |
| 4 | Mine dungeon map | ⬜ |
| 5 | Battle system | ⬜ |
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
