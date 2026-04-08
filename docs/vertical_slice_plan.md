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

**Known issues (deferred to Stage 11 polish):**
- Some tree tiles do not block — collision layer assignment incomplete on a subset of props

---

## Stage 2 — NPC dialogue system
**Status:** ✅ Complete (Slice Day 2)

**Goal:** A reusable dialogue system that any NPC in the game can use. Supports stat gates and gold gates.

**Tasks:**
- [x] Build `DialogueManager` autoload — loads dialogue data, manages conversation state, emits signals
- [x] Dialogue data format: GDScript Dictionary — each NPC has a dialogue tree with nodes, conditions, branches
- [x] Condition types: `stat_gte`, `gold_gte`, `flag_set`, `pure_path`, `mixed_path`
- [x] `interact` input action mapped to `E`
- [x] NPC scene includes interaction zone and solid body collision
- [x] Dialogue box: bottom-third panel, speaker header, portrait slot, text body, advance prompt
- [x] Three core loop NPCs wired: intel NPC, moral choice NPC, bookstore NPC

**Verification:** All checks passed.

**Done state:** Three wired, conditionally branching NPCs are in the town.

---

## Stage 3 — Town exit and mine entrance cutscene
**Status:** ✅ Complete (Slice Day 3 resolved)

**Goal:** Leaving the town triggers a point-of-no-return prompt, plays a transition cutscene, and lands the player in the mine.

**Verification:** All checks passed.

**Done state:** Town exit → cutscene → mine start is fully playable and stable.

---

## Stage 4 — Mine dungeon map
**Status:** ✅ Complete (Slice Day 4 resolved)

**Goal:** A dungeon map for the mine. Navigable, atmospheric, with Kobold encounter trigger zones.

**Verification:** All checks passed.

**Done state:** The mine exists as a real designed level with working encounter and exit gate flow.

---

## Stage 5 — Battle system
**Status:** ✅ Complete (Slice Day 5 resolved)

**Goal:** Real turn-based battle. Kobold enemy type. Player class abilities.

**What was built:**
- Full `Battle.gd` turn-based system: player turn → enemy turn alternation
- Player actions: Attack, Spell (Battlemage only), Item (Health Potion), Flee, class Ability
- Fighter: +2 strength passive, Shield Bash (damage + Stagger, 4-turn cooldown)
- Battlemage: Arcane Strike (physical + Magik dual damage, 3-turn cooldown), reduced Flamebolt power
- Kobold: HP 30, attack 6, defence 3, resistance 2, 80/20 attack/defend AI
- HitFlash.gdshader, screen shake, sprite bob, responsive layout
- Real art: LPC knight, LPC battlemage, LPC imp, volcano background, Kenney UI
- Victory, defeat, and boss-placeholder sequences all functional

**Verification:** All checks passed.

**Done state:** The mine has real, functional, class-differentiated combat.

---

## Stage 6 — Boss room and moral choice
**Status:** 🔄 In progress

**Goal:** The Half-Kobold Orc Shaman encounter. The moral choice. Branching outcomes. This is the allegory made mechanical.

**Design notes:**
- The Shaman is Half-Kobold Orc — liminal, belonging fully to neither faction. He is the living embodiment of the allegory.
- Pure players face him as a symbol of what they fear. Mixed players face him as a mirror.
- No correct answer. Both paths have costs and rewards. Ghost flags ensure the world remembers.
- The writing is load-bearing. Treat it carefully.

**Flags to add to `PlayerData.gd`:**
- `shaman_recruited`, `shaman_killed` (bool flags)
- Ghost flags: `world_remembers_shaman_killed`, `world_remembers_shaman_spared`, `pure_rep_shaman_mercy`, `mixed_betrayed_own`

**Implementation plan:**
1. Replace `BATTLE_KIND_BOSS_PLACEHOLDER` in `Map.gd` with a `cutscene` payload (`cutscene_id = "shaman_intro"`)
2. Refactor `Cutscene.gd` to be payload-driven (`cutscene_id` key routes `mine_entry` vs `shaman_intro`)
3. Shaman intro: path-reactive opening line, optional warning reference, two-button choice panel
4. Recruit branch: flags + stat boosts (`social.charm +3`, `magik.attunement +2`) + ghost flags, no combat
5. Fight branch: `BATTLE_KIND_BOSS_SHAMAN` — HP 60, attack 9, defence 4, resistance 4; Hex/Heal AI; kill flags + loot on victory
6. Verify aftermath: exit gate opens, boss trigger suppressed on return

**Shaman dialogue:**
- Pure: *"Another pureblood who fears what they cannot name."*
- Mixed: *"You carry both bloods. I see the war in you."*
- If `shaman_warning_given`: append *"Someone warned you. And still you came."*

**Verification:**
- [x] Boss trigger → Shaman intro fires via `Cutscene.gd` with `cutscene_id = "shaman_intro"`
- [x] Pure player gets Pure-specific opening line
- [x] Mixed player gets Mixed-specific opening line
- [ ] `shaman_warning_given` flag → Shaman references the warning
- [x] Recruit → flags set, stat boosts applied, mine exit unlocks, returns to map
- [x] Fight → boss battle launches with correct stats
- [x] Shaman Hex debuff reduces player attack next turn
- [x] Shaman Heal fires once only, removed from rotation after use
- [ ] Boss victory → kill flags + ghost flags set, 25 gold + `shaman_talisman` awarded, mine exit unlocks
- [x] Ghost flags correct for all 4 permutations (Pure+recruit, Pure+kill, Mixed+recruit, Mixed+kill)
- [x] `mine_boss_resolved` and `mine_exit_unlocked` set after either branch
- [x] Boss trigger does not re-fire on map return
- [x] Stats increment during boss fight
- [x] Clock continues running throughout
- [x] Headless smoke run passes

**Done state:** The moral choice works and has real mechanical and flag consequences.

## Stage 6.5 — Dev 'cheatcode'
**Status:** ⬜ Not started

**Tasks:**
- scope to be set

**Verification:**
- scope to be set

**Done state:** Player can skip battles to victory status by pressing 'P' during battle on their turn

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

## Stage 8 — Save system
**Status:** ⬜ Not started

**Goal:** Full save and load. Every state that matters is persisted.

**Tasks:**
- [ ] `SaveManager` autoload: `save_game()`, `load_game()`, `has_save()`
- [ ] Saves: full `StatRegistry.stats`, `PlayerData` (flags + ghost flags), `GameClock` time, location, quest flags
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

## Stage 8b — MVP feature pass
**Status:** ⬜ Not started

**Goal:** Before the developer review pass, implement a set of MVP/spike-quality features that need to exist in the game — even if placeholder, rough, or incomplete — so Stage 9 can assess the full experience. Nothing here needs to be polished. It needs to be present and functional enough to evaluate.

**Features:**

### Dialogue portraits
- NPC dialogue box currently has a portrait slot but no image.
- Source or generate a static portrait image for at least one NPC (the Shaman is the priority — he's the most dramatically important character in the VS).
- Portrait does not need to be final art. A cropped CC0 image or a generated image is fine.
- Wire it into the dialogue box portrait slot for that NPC.

### Class-specific map sprites
- Player currently appears as a generic coloured square on the map.
- Replace with a class-specific 32×32 sprite: one for Fighter (Pure), one for Battlemage (Mixed).
- Use LPC spritesheet assets already in the project — crop a top-down walking frame.
- Pure/Mixed path tint accent (gold/teal) should remain on top.

### NPC sprites
- NPCs currently appears as a generic coloured square on the map.
- Replace with a random 32×32 sprite from LPC spritesheet assets already in project

### Alignment system — spike
- Implement a minimal D&D-style alignment matrix (Law–Chaos axis, Good–Evil axis = 9-cell grid).
- Reference: `assets/art/Mood Board/bg3-alignment-chart-v0-lb31w8gqv26c1.webp`
- Player's position on the grid is derived from existing flags and ghost flags — no new input required from the player.
- Example derivations (establish the full mapping in code):
  - `pure_rep_shaman_mercy = true` → shifts toward Good
  - `mixed_betrayed_own = true` → shifts toward Evil
  - `shaman_recruited` → shifts toward Chaotic
  - `shaman_killed` (Pure path) → shifts toward Lawful
- Display: shown as a highlighted cell in the HUD stats tab. Label only (e.g. "Lawful Good"). No animation needed.
- This is a spike. The derivation logic will be expanded in production.

### HUD — MVP pass
The HUD overlay exists but is minimal. Implement the following tabs at spike quality:

**Stats tab (already partially exists):**
- Show all 6 top-level stats with their current values.
- Show the player's alignment label (from alignment system above).
- Show current gold.

**Equipment tab:**
- Six slots displayed as labelled boxes: Helm, Armour, Weapon, Boots, Offhand, Accessory.
- For spellbook/ability slot: show "Spellbook" if Battlemage, "Shield" if Fighter.
- Slots show item name if equipped, "Empty" if not.
- No drag-and-drop. No equip/unequip in this stage — display only.

**Quest tab:**
- Static placeholder. Show current quest name ("Into the Mine") and one line of objective text derived from `mine_encounter_progress` and `mine_boss_resolved` flags.
- No full quest log system — just the active objective display.

**Map tab:**
- Static placeholder image or a blank panel with the text "Map — coming soon."
- This is intentionally deferred. It just needs to exist as a tab.

**Leveling Systen: - spike**
- scope coming soon


### Equipment rendering on battle sprite — spike
- `Battle.gd` already has a layered sprite slot system in mind (base body + armour layer + weapon layer per `docs/HANDOVER.md`).
- Implement the minimum: if a weapon is equipped in `PlayerData.equipment["weapon"]`, modify the player's battle sprite or add a visible weapon overlay.
- Does not need to be a full compositing system. A single conditional texture swap or overlay is sufficient.
- This proves the architecture before production builds it out properly.

**Verification:**
- [ ] Shaman dialogue box shows a portrait image
- [ ] Fighter and Battlemage have distinct 32×32 top-down map sprites
- [ ] Alignment label displays correctly in HUD stats tab for both Pure and Mixed paths
- [ ] Alignment shifts correctly when relevant flags are set (test with debug toggles)
- [ ] HUD equipment tab shows all six slots, correctly populated or labelled "Empty"
- [ ] Spellbook slot shows for Battlemage, Shield slot shows for Fighter
- [ ] HUD quest tab shows active objective text that updates with `mine_encounter_progress`
- [ ] HUD map tab exists and shows placeholder
- [ ] Level system shows level and exp
- [ ] Equipping a weapon in `PlayerData.equipment["weapon"]` produces a visible change in the battle sprite

**Done state:** The game has enough visual and systemic presence for a meaningful developer review in Stage 9.

---

## Stage 9 — Final feature checklist (developer sign-off)
**Status:** ⬜ Not started

**Goal:** Before polish begins, John plays through the complete loop and confirms every feature is working and directionally correct. No code changes unless something is broken or fundamentally wrong. This is a personal review, not an iteration sprint.

**Checklist:**
- [ ] Complete core loop start to finish without debug controls: Town → Leave → Cutscene → Mine → 3 encounters → Boss choice → Exit
- [ ] Fighter path feels distinct and satisfying — Shield Bash has impact
- [ ] Battlemage path feels distinct and satisfying — versatility is legible
- [ ] Recruit branch feels like a real moral choice, not a soft option
- [ ] Kill branch feels like a real moral choice, not the "easy" path
- [ ] Pure and Mixed Shaman opening lines land as intended allegory
- [ ] Kobold encounters feel appropriately challenging — not trivial, not punishing
- [ ] Boss fight is clearly harder than regular encounters
- [ ] Stat increments feel meaningful (check debug panel at end of run)
- [ ] Alignment label reflects the choices made
- [ ] All flags correct: `shaman_recruited`/`shaman_killed` and ghost flags as expected
- [ ] HUD is readable and not obstructing gameplay
- [ ] All transitions feel smooth enough for a playtester
- [ ] No progression blockers or softlocks
- [ ] Anything wrong or missing is logged as a note for Stage 10 or production

**Done state:** John is happy with the game as an unpolished experience. Stage 10 polish can begin.

---

## Stage 10 — Polish and playtester pass
**Status:** ⬜ Not started

**Goal:** Make the loop good enough to put in front of a real person.

**Tasks:**
- [ ] Remove spike dev controls (B, H, C, 1, 2)
- [ ] Remove debug panel from release build
- [ ] Audio: ambient town, ambient mine, battle music, victory sting, moral choice sting
- [ ] SFX: footstep, attack, spell cast, dialogue advance, menu sounds
- [ ] Fade to black between all major state transitions
- [ ] UI pass: dialogue box, HUD, battle menu — match art direction
- [ ] Fix known Stage 1 issues: remaining tree collision
- [ ] NPC portrait(s) — at minimum the Shaman
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
| 6 | Boss room + moral choice | 🔄 In progress |
| 7 | Mine exit + area transition | ⬜ |
| 8 | Save system | ⬜ |
| 8b | MVP feature pass | ⬜ |
| 9 | Final feature checklist (developer sign-off) | ⬜ |
| 10 | Polish + playtester pass | ⬜ |

---

## How to use this document

At the start of each Cascade/Claude session:

> "Read `docs/HANDOVER.md` and `docs/vertical_slice_plan.md`. I am on Vertical Slice Stage X — [name]. Help me complete the tasks."

After each session: tick completed tasks, update the status table.
When a stage passes all verification checks: mark ✅ and start the next.
