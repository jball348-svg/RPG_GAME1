# Vertical Slice Plan - RPG_GAME1
> Same structure as the technical spike: define the goal, build the minimum to prove it, verify, lock, move on.
> Do not start the next implementation ticket until the current one passes its verification check.

---

## What the vertical slice must deliver

A complete, polished, playable run of the core loop:
**Load -> Town -> Leave -> Cutscene -> Mine -> Battles -> Boss (moral choice) -> Exit**

When a playtester can complete that loop without guidance and find it fun, the vertical slice is done.
Everything else is production.

---

## Stage 1 - Real town map
**Status:** Complete

TileMap-authored starting town. Collision, camera bounds, north exit trigger. Viewport 480x270 / 1280x720.

---

## Stage 2 - NPC dialogue system
**Status:** Complete

Reusable `DialogueManager` autoload. Condition types: `stat_gte`, `gold_gte`, `flag_set`, `pure_path`, `mixed_path`. Three wired core-loop NPCs: intel, moral choice, bookstore.

---

## Stage 3 - Town exit and mine entrance cutscene
**Status:** Complete

Point-of-no-return prompt -> path/class-tinted cutscene -> mine spawn. One-time stat ticks on confirm.

---

## Stage 4 - Mine dungeon map
**Status:** Complete

Mine layout, ordered encounter zones, boss-room gate, exit lock. Progression flags: `mine_encounter_progress`, `mine_boss_ready`, `mine_boss_resolved`, `mine_exit_unlocked`, `mine_cleared`.

---

## Stage 5 - Battle system
**Status:** Complete

Full turn-based `Battle.gd`. Actions: Attack, Spell, Item, Flee, Ability. Fighter and Battlemage feel distinct. Kobold enemy. HP bars, battle log, screen shake, hit flash shader, sprite bob, loot and game-over resolution, responsive layout.

---

## Stage 6 - Boss room and moral choice
**Status:** Complete

Half-Kobold Orc Shaman. Cutscene-driven intro via `cutscene_id = "shaman_intro"`. Two branches: recruit (stat boosts, no combat) or fight (`BATTLE_KIND_BOSS_SHAMAN`, HP 60). Ghost flags set for the major path/choice permutations. Exit gate unlocks after either branch.

**Done state:** Moral choice works with real mechanical and flag consequences.

---

## Stage 6.5 - Dev skip / scene-load cheat
**Status:** Complete

Debug-only battle skip on `P` and map location loader on `L` to accelerate testing.

**Done state:** Developer can reach any point in the loop in under 30 seconds.

---

## Stage 7 - Mine exit and area transition
**Status:** Complete

Mine exit trigger, `mine_exit` cutscene, runtime-built crossroads stub, quest flag updates, optional Shaman companion appearance, return to new-region map spawn.

**Done state:** The core loop completes end to end.

---

## Stage 8 - Save system
**Status:** Complete

**Goal:** Persist the live vertical-slice state and resume cleanly into the map state.

**Implemented scope:**
- `SaveManager` autoload with `has_save()`, `save_game()`, and `load_game()`
- Save file at `user://save_game.json`
- Save payload includes:
  - `StatRegistry` stats
  - `PlayerData` identity, path, flags, ghost flags, gold, inventory, equipment, age, and current HP
  - `GameClock` time
  - world return context for map reload
- Autosave hooks on:
  - map entry
  - dialogue completion while on map
  - battle victory
  - Shaman recruit resolution
- Launch behavior:
  - if save exists, load into map
  - otherwise boot into new map defaults

**Important note:**
- Real progression persistence is not part of Stage 8. Placeholder progression keys exist in the save payload today, but Stage 8.5 owns real leveling data and compatibility backfill.

**Verification state:**
- Repo implementation exists in `SaveManager.gd`, `Main.gd`, `Battle.gd`, and `Cutscene.gd`
- Manual runtime revalidation is still recommended on a machine with Godot installed

**Done state:** Progress in live vertical-slice systems is persisted and restored.

---

## Stage 8.5 - MVP feature pass
**Status:** In progress (`T00` complete, `T01`-`T12` pending)

**Goal:** Ship the feature pass required for meaningful developer review without inventing behavior mid-implementation.

**Reference docs:**
- `docs/stage_8_5_master_plan.md`
- `docs/stage_8_5_asset_research.md`
- `docs/stage_8_5_systems_spec.md`
- `docs/stage_8_5_tickets.md`

### Ticket order

- [x] `T00` Plan-the-plan  
Depends on: none  
Done when: repo docs no longer contradict Stage 8 status, Stage 8.5 naming, current controls, or current feature state.

- [ ] `T01` Asset provenance audit  
Depends on: `T00`  
Done when: Fighter, Battlemage, generic NPC, portrait, weapon-overlay, and HUD/UI asset slots each have a documented primary and fallback source with provenance status.

- [ ] `T02` Portrait ticket  
Depends on: `T01`  
Done when: one Shaman portrait candidate and one fallback are locked, with crop/path guidance and dialogue wiring notes.

- [ ] `T03` Map sprite ticket  
Depends on: `T01`  
Done when: Fighter, Battlemage, and generic NPC map sprite sources and frame-selection notes are locked.

- [ ] `T04` HUD rebuild ticket  
Depends on: `T05`, `T07`, `T08`, `T09`  
Done when: the tabbed HUD exists with `Stats`, `Equipment`, `Quest`, and `Map`, including the post-level-up open-to-Stats flow.

- [ ] `T05` Progression data ticket  
Depends on: `T00`  
Done when: `PlayerData` owns real progression fields and save compatibility defaults for old Stage 8 saves are specified and implemented.

- [ ] `T06` XP reward ticket  
Depends on: `T05`  
Done when: battle victory grants XP, loot UI shows XP, level checks occur after XP grant, and `SignalBus.level_up(level)` fires on level-up.

- [ ] `T07` Stat allocation ticket  
Depends on: `T05`  
Done when: each spent point adds `+1` to every non-derived child skill in the chosen category, Luck stays derived, and HUD category values visibly move by exactly `+1`.

- [ ] `T08` Alignment ticket  
Depends on: `T00`  
Done when: `AlignmentSystem` derives Law/Chaos and Good/Evil from flags/ghost flags, defaults to `True Neutral`, and exposes a HUD label without adding saved state.

- [ ] `T09` Equipment tab ticket  
Depends on: `T00`  
Done when: the HUD displays the current eight equipment keys as eight slots with stable labels.

- [ ] `T10` Weapon-overlay ticket  
Depends on: `T01`, `T03`  
Done when: a non-empty `PlayerData.equipment["weapon"]` produces one visible battle-sprite overlay, with a documented no-new-art fallback if provenance blocks asset use.

- [ ] `T11` Save/regression ticket  
Depends on: `T05`, `T06`, `T07`, `T08`, `T09`, `T10`  
Done when: old saves load with progression defaults, new saves persist progression, alignment remains derived-only, and the manual regression list passes.

- [ ] `T12` Developer review handoff  
Depends on: `T01`-`T11`  
Done when: every Stage 8.5 output maps cleanly into Stage 9 sign-off criteria.

**Done state:** The game has enough visual and systemic presence for a meaningful developer review.

---

## Stage 9 - Final feature checklist (developer sign-off)
**Status:** Planned

**Goal:** John plays through the complete loop and confirms every Stage 8.5 feature is working and directionally correct. No code changes unless something is broken or fundamentally wrong.

**Prerequisites before Stage 9 starts:**
- `T01` through `T11` complete
- Save regression rerun on a machine with Godot installed
- One approved or explicit fallback source documented for every Stage 8.5 art slot

**Checklist:**
- [ ] Complete core loop without debug controls: Town -> Leave -> Cutscene -> Mine -> 3 encounters -> Boss choice -> Exit
- [ ] Fighter path feels distinct
- [ ] Battlemage path feels distinct
- [ ] Recruit and kill branches both feel like real moral choices
- [ ] Shaman dialogue and portrait presentation land as intended
- [ ] Kobold encounters feel appropriately challenging
- [ ] Boss fight is clearly harder than regular encounters
- [ ] Level-up flow feels rewarding and legible
- [ ] Alignment label reflects the choices made
- [ ] HUD tabs are readable and not obstructive
- [ ] Map sprites and NPC sprites read clearly at gameplay scale
- [ ] Equipment tab reflects the current save model accurately
- [ ] Weapon overlay spike is visible when expected
- [ ] Old and new saves both resume correctly
- [ ] All flags remain correct: `shaman_recruited` / `shaman_killed`, ghost flags, `mine_cleared`
- [ ] No progression blockers or softlocks
- [ ] Notes logged for Stage 10 or production

**Done state:** John is satisfied with the unpolished experience. Stage 10 can begin.

---

## Stage 10 - Polish and playtester pass
**Status:** Planned

**Goal:** Make the loop good enough to put in front of a real person.

**Prerequisites before Stage 10 starts:**
- Stage 9 sign-off complete
- Any required attribution/provenance notes for retained placeholder art are written down

**Tasks:**
- [ ] Remove or confirm debug-only gating for dev controls in release behavior
- [ ] Remove debug overlay panel from release build
- [ ] Audio: ambient town, ambient mine, battle music, victory sting, moral choice sting
- [ ] SFX: footstep, attack, spell cast, dialogue advance, menu sounds
- [ ] UI pass: dialogue box, HUD tabs, battle menu - match art direction
- [ ] Fix known tree collision issues from Stage 1
- [ ] Final portrait pass - Shaman at minimum
- [ ] Game over screen polish
- [ ] First external playtester pass

**Verification:**
- [ ] Unknown player completes the loop without help
- [ ] No debug text or controls visible in normal play
- [ ] Audio throughout
- [ ] Smooth transitions

**Done state:** Vertical slice complete.

---

## Current status summary

| Stage | Task | Status |
|---|---|---|
| 1 | Real town map | Complete |
| 2 | NPC dialogue system | Complete |
| 3 | Town exit + mine entrance cutscene | Complete |
| 4 | Mine dungeon map | Complete |
| 5 | Battle system | Complete |
| 6 | Boss room + moral choice | Complete |
| 6.5 | Dev skip / scene-load cheat | Complete |
| 7 | Mine exit + area transition | Complete |
| 8 | Save system | Complete |
| 8.5 | MVP feature pass | In progress (`T00` done, feature tickets pending) |
| 9 | Final feature checklist | Planned |
| 10 | Polish + playtester pass | Planned |

---

## How to use this document

At the start of each session:
> "Read `docs/HANDOVER.md`, `docs/vertical_slice_plan.md`, and the Stage 8.5 spec pack. I am implementing Ticket TXX from Stage 8.5."

After each session:
- tick completed ticket or checklist items
- update the status summary
- mark Stage 8.5 complete only when all ticket done-states and verification checks pass
