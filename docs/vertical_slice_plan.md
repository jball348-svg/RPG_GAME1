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
**Status:** 🔄 In progress (tileset proof done by Cascade, runtime-generated layout)

**Goal:** A town map that is designed in Godot's TileMap editor, not assembled in GDScript at runtime.

**Why this matters:** Runtime-generated maps can't be iterated on visually. Every level design decision for the rest of the game will be made in the editor. Establish that pattern now.

**Tasks:**
- [X] Acquire a town building tileset (facades, rooftops, doors, windows) — 32×32, CC0, matching art direction
- [ ] Redesign the starting town in the TileMap editor: paths, buildings, shop locations, NPC placement zones
- [ ] Remove the runtime tile-generation code from `Map.gd` — map data lives in the `.tscn`, not in script
- [ ] Place collision shapes on impassable tiles (walls, trees, buildings)
- [ ] Place trigger zones for: town exit (north), bookstore entrance, key NPC positions
- [ ] Camera bounds set to match the designed map

**Verification:**
- [ ] Walk around the town — collision works, camera stays in bounds
- [ ] Town reads as a town: buildings are identifiable, paths are clear, there's a sense of place
- [ ] Trigger zones are in place even if not yet wired
- [ ] No runtime tile generation remaining in Map.gd

**Done state:** The starting town exists as a real designed level.

---

## Stage 2 — NPC dialogue system
**Status:** ⬜ Not started

**Goal:** A reusable dialogue system that any NPC in the game can use. Supports stat gates and gold gates.

**Why this matters:** Three NPCs are needed for the core loop (intel NPC, moral choice NPC, bookstore). The system that powers them will power every NPC in the game. Design it once, reusable forever.

**Tasks:**
- [ ] Build `DialogueManager` autoload — loads dialogue data, manages conversation state, emits signals
- [ ] Dialogue data format: JSON or GDScript Dictionary — each NPC has a dialogue tree with nodes, conditions, branches
- [ ] Condition types: `stat_gte` (stat path + minimum value), `gold_gte` (minimum gold), `flag_set` (flag name), `pure_path`, `mixed_path`
- [ ] Dialogue box scene: bottom-third panel, speaker name header, portrait slot (left), text body, advance prompt
- [ ] Wire `E` key / interact button to trigger dialogue when player is in an NPC's trigger zone
- [ ] Write dialogue for the three core loop NPCs:
  - Intel NPC: base info (always), full mine detail (Social ≥ threshold + gold ≥ threshold)
  - Moral choice NPC: alerts player to the Shaman — always fires, one-time only
  - Bookstore NPC: sells the new Destruction spell if Intelligence ≥ threshold

**Verification:**
- [ ] Talk to intel NPC with low Social/gold — gets basic info only
- [ ] Talk to intel NPC with high Social/gold — gets full mine detail
- [ ] Talk to moral choice NPC — dialogue fires once, flag set, won't repeat
- [ ] Talk to bookstore NPC — spell available if Intelligence threshold met, locked otherwise
- [ ] Dialogue box looks correct: speaker name, portrait placeholder, text, advance prompt

**Done state:** Three wired, conditionally branching NPCs are in the town.

---

## Stage 3 — Town exit and mine entrance cutscene
**Status:** ⬜ Not started

**Goal:** Leaving the town triggers a point-of-no-return prompt. Confirming plays a cutscene.

**Tasks:**
- [ ] Town exit trigger zone (north edge of map) — overlap fires a confirmation dialogue: "You are leaving town. The mine awaits. Continue?"
- [ ] Confirmation yes → transition to cutscene state
- [ ] Confirmation no → player stays in town
- [ ] Cutscene: player sprite walks toward the mine entrance, class-specific animation plays, equipment loadout visible
- [ ] Cutscene fires `Will.resolve` and `Holy.faith` stat increments (entering danger willingly)
- [ ] Cutscene ends → transition to mine map

**Verification:**
- [ ] Walk to town exit → prompt appears
- [ ] Say no → stay in town, can continue playing
- [ ] Say yes → cutscene plays, player walks to mine, correct class animation fires
- [ ] Equipment visible in cutscene sprite
- [ ] Stat increments fire during cutscene (visible in debug panel)
- [ ] Smooth transition into mine map at end of cutscene

**Done state:** Leaving town into the mine is a meaningful, cinematic moment.

---

## Stage 4 — Mine dungeon map
**Status:** ⬜ Not started

**Goal:** A dungeon map for the mine. Navigable, atmospheric, with Kobold encounter trigger zones.

**Tasks:**
- [ ] Acquire a dungeon/cave tileset — 32×32, CC0, stone walls/floors/torches, matching art direction
- [ ] Design the mine map in TileMap editor: entrance corridor, branching paths, enemy rooms, boss room at the end
- [ ] Collision on all walls and impassable tiles
- [ ] Place Kobold encounter trigger zones (3–5 encounters before the boss)
- [ ] Place boss room trigger zone (separate from regular encounters)
- [ ] Place mine exit trigger zone (only accessible after boss room resolved)
- [ ] Atmospheric details: torch placement, dead ends, visual sense of depth

**Verification:**
- [ ] Walk through mine — collision works, no gaps or shortcuts to boss room
- [ ] Mine reads as a mine: dark, stone, atmospheric
- [ ] Encounter zones are placed even if not yet wired to battle
- [ ] Boss room is clearly a distinct space
- [ ] Exit is blocked until boss room flag is set

**Done state:** The mine exists as a real designed level.

---

## Stage 5 — Battle system
**Status:** ⬜ Not started

**Goal:** A real turn-based battle that replaces the spike's button proof. Kobold enemy type. Player class abilities.

**This is the biggest single stage. Budget accordingly.**

**Tasks:**
- [ ] Battle scene redesign: proper layout — player party (left), enemies (right), action menu (bottom)
- [ ] Turn order system: player turn → enemy turn, repeat until combat resolved
- [ ] Player action menu: Attack, Spell (if Magik class), Use Item, Flee
- [ ] Kobold enemy type: HP, attack damage, simple AI (attacks player on its turn)
- [ ] Player starting class abilities (implement for ONE Pure class and ONE Mixed class for the slice)
- [ ] Damage calculation: Physical.Strength + weapon modifier vs enemy defence
- [ ] Spell damage: Magik.Spellcasting + spell power vs enemy resistance
- [ ] Victory state: all enemies defeated → loot roll → return to map
- [ ] Defeat state: player HP reaches 0 → game over screen (simple for now)
- [ ] Stat increments fire on every action: Attack → Physical.Strength, Cast → Magik.Spellcasting etc.
- [ ] Battle backgrounds: static image per environment (mine interior for mine battles)
- [ ] Wire Kobold encounter trigger zones from Stage 4 to launch battle

**Verification:**
- [ ] Enter mine, trigger encounter → battle launches
- [ ] Player can Attack, Cast Spell, Flee
- [ ] Kobold attacks back on its turn
- [ ] Victory → loot → back to mine map at correct position
- [ ] Defeat → game over screen
- [ ] Stats increment correctly during battle (debug panel confirms)
- [ ] At least one Pure class and one Mixed class have distinct, working abilities

**Done state:** The mine has real, functional combat.

---

## Stage 6 — Boss room and moral choice
**Status:** ⬜ Not started

**Goal:** The Half-Kobold Orc Shaman encounter. The moral choice. Branching outcomes.

**Tasks:**
- [ ] Boss room trigger fires a cutscene: the Shaman emerges, addresses the player
- [ ] Shaman dialogue presents the choice clearly: recruit or fight
- [ ] Branch A — Recruit:
  - Shaman joins as companion (flag: `shaman_recruited = true`)
  - Mixed stat boosts fire (Social.Empathy, Holy.Justice)
  - If Pure path: Pure reputation ghost flag decrements
  - Shaman sprite follows player on map (simple follow behaviour)
- [ ] Branch B — Fight:
  - Boss battle launches: Shaman has higher HP and a Magik attack
  - On victory: loot drop, flag `shaman_killed = true`
  - Pure reputation ghost flag increments
  - Ghost flag set: `world_remembers_shaman_killed = true` (used later by world NPCs)
- [ ] After either branch: mine exit trigger unlocks
- [ ] Pure/Mixed allegiance affects Shaman's opening dialogue (he reads your path)

**Verification:**
- [ ] Recruit path: Shaman joins, stat boosts fire, companion visible, exit unlocks
- [ ] Kill path: boss battle plays, loot drops, ghost flag set, exit unlocks
- [ ] Pure player gets different Shaman opening line than Mixed player
- [ ] Ghost flags are set correctly (debug panel confirms)

**Done state:** The moral choice works and has real mechanical consequences.

---

## Stage 7 — Mine exit and area transition
**Status:** ⬜ Not started

**Goal:** Leaving the mine reveals a new area. The main quest path is now open.

**Tasks:**
- [ ] Mine exit trigger (post-boss) → cutscene: player emerges from mine into a new region
- [ ] New region map stub: just enough to show the world continues (a road, distant mountains, a signpost)
- [ ] Quest flag set: `mine_cleared = true`, `main_quest_path_open = true`
- [ ] If Shaman recruited: companion emerges with player in cutscene
- [ ] A moment of breathing room — no immediate combat, just the world opening up

**Verification:**
- [ ] Exit mine → cutscene plays, new area appears
- [ ] Quest flags set correctly
- [ ] Recruited Shaman appears in exit cutscene if applicable
- [ ] New area feels like arrival — the loop has a satisfying resolution

**Done state:** The core loop completes. The player has arrived somewhere new.

---

## Stage 8 — Save system
**Status:** ⬜ Not started

**Goal:** Full save and load. Every state that matters is persisted.

**Tasks:**
- [ ] `SaveManager` autoload: `save_game()`, `load_game()`, `has_save()`
- [ ] Save data includes: full `StatRegistry.stats`, `PlayerData` (class, path, flags, ghost flags, age, equipment, gold, inventory), `GameClock` time, current location/scene, quest flags
- [ ] Save to `user://save_game.json` (Godot's user data directory)
- [ ] Save triggered: on map state entry, on dialogue completion, on battle victory, on moral choice resolution
- [ ] Load on game start: if save exists, restore all state and boot to saved location
- [ ] New game path: if no save, boot to character creation (stub for now — just set defaults)

**Verification:**
- [ ] Play for 5 minutes, quit, relaunch — all stats, flags, clock, and location restored correctly
- [ ] Stats that were incrementing are at the right values after load
- [ ] Ghost flags persist across sessions
- [ ] Clock resumes from saved time, not from zero

**Done state:** Progress is never lost.

---

## Stage 9 — Polish and playtester pass
**Status:** ⬜ Not started

**Goal:** The loop is complete. Now make it feel good enough to put in front of a real person.

**Tasks:**
- [ ] Remove all spike dev controls (B, H, C, 1, 2 hotkeys) — replace with proper in-game triggers
- [ ] Remove debug panel from shipped build (keep as a launch flag for dev)
- [ ] Sound: ambient track for town, ambient track for mine, battle music, victory sting — source from freesound/OpenGameArt
- [ ] SFX: footstep, attack, spell cast, dialogue advance, menu open/close
- [ ] Transition polish: fade to black between major state changes
- [ ] UI pass: dialogue box, HUD stat display, battle action menu — match art direction (stone/parchment aesthetic)
- [ ] At least one NPC portrait (placeholder or sourced CC0)
- [ ] Game over screen — simple, in keeping with the tone
- [ ] First external playtester: one person, watch them play, say nothing, note where they get confused

**Verification:**
- [ ] A person who has never seen the game can complete the loop without help
- [ ] No debug text visible during normal play
- [ ] Audio plays throughout the loop
- [ ] Transitions between states feel smooth

**Done state:** Vertical slice is complete. Production continues to the next quest area.

---

## Current status summary

| Stage | Task | Status |
|---|---|---|
| 1 | Real town map (editor-designed) | 🔄 In progress |
| 2 | NPC dialogue system | ⬜ |
| 3 | Town exit + mine entrance cutscene | ⬜ |
| 4 | Mine dungeon map | ⬜ |
| 5 | Battle system | ⬜ |
| 6 | Boss room + moral choice | ⬜ |
| 7 | Mine exit + area transition | ⬜ |
| 8 | Save system | ⬜ |
| 9 | Polish + playtester pass | ⬜ |

---

## How to use this document

At the start of each Cascade/Claude session for the vertical slice:

> "Here is the project context: [HANDOVER.md]. I am working on vertical slice Stage X — [stage name]. Here is the plan: [paste this stage's section]. Help me complete the tasks."

After each session: tick completed tasks, update status in the summary table above.
When a stage passes all its verification checks: mark it ✅ and start the next.
