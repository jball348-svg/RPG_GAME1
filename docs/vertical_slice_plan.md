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

TileMap-authored starting town. Collision, camera bounds, north exit trigger. Viewport 480x270 / 960x540 integer scaling.

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
- Headless and local-render smoke were rerun during the Stage 8.5 close-out pass

**Done state:** Progress in live vertical-slice systems is persisted and restored.

---

## Stage 8.5 - MVP feature pass
**Status:** Complete

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

- [x] `T01` Asset provenance audit  
Depends on: `T00`  
Done when: Fighter, Battlemage, generic NPC, portrait, weapon-overlay, and HUD/UI asset slots each have a documented primary and fallback source with provenance status.

- [x] `T02` Portrait ticket  
Depends on: `T01`  
Done when: one Shaman portrait candidate and one fallback are locked, with crop/path guidance and dialogue wiring notes.

- [x] `T03` Map sprite ticket  
Depends on: `T01`  
Done when: Fighter, Battlemage, and generic NPC map sprite sources and frame-selection notes are locked.

- [x] `T04` HUD rebuild ticket  
Depends on: `T05`, `T07`, `T08`, `T09`  
Done when: the tabbed HUD exists with `Stats`, `Equipment`, `Quest`, and `Map`, including the post-level-up open-to-Stats flow.

- [x] `T05` Progression data ticket  
Depends on: `T00`  
Done when: `PlayerData` owns real progression fields and save compatibility defaults for old Stage 8 saves are specified and implemented.

- [x] `T06` XP reward ticket  
Depends on: `T05`  
Done when: battle victory grants XP, loot UI shows XP, level checks occur after XP grant, and `SignalBus.level_up(level)` fires on level-up.

- [x] `T07` Stat allocation ticket  
Depends on: `T05`  
Done when: each spent point adds `+1` to every non-derived child skill in the chosen category, Luck stays derived, and HUD category values visibly move by exactly `+1`.

- [x] `T08` Alignment ticket  
Depends on: `T00`  
Done when: `AlignmentSystem` derives Law/Chaos and Good/Evil from flags/ghost flags, defaults to `True Neutral`, and exposes a HUD label without adding saved state.

- [x] `T09` Equipment tab ticket  
Depends on: `T00`  
Done when: the HUD displays the current eight equipment keys as eight slots with stable labels.

- [x] `T10` Weapon-overlay ticket  
Depends on: `T01`, `T03`  
Done when: a non-empty `PlayerData.equipment["weapon"]` produces one visible battle-sprite overlay, with a documented no-new-art fallback if provenance blocks asset use.

- [x] `T11` Save/regression ticket  
Depends on: `T05`, `T06`, `T07`, `T08`, `T09`, `T10`  
Done when: old saves load with progression defaults, new saves persist progression, alignment remains derived-only, and the manual regression list passes.

- [x] `T12` Developer review handoff  
Depends on: `T01`-`T11`  
Done when: every Stage 8.5 output maps cleanly into Stage 9 sign-off criteria.

**Done state:** The game has enough visual and systemic presence for a meaningful developer review.

---

## Stage 9 - Final feature checklist (developer sign-off)
**Status:** Complete

**Goal:** John plays through the complete loop and confirms every Stage 8.5 feature is working and directionally correct. No code changes unless something is broken or fundamentally wrong.

**Prerequisites before Stage 9 starts:**
- `T01` through `T11` complete
- Save regression rerun on a machine with Godot installed
- One approved or explicit fallback source documented for every Stage 8.5 art slot

**Checklist:**
- [x] Complete core loop without debug controls: Town -> Leave -> Cutscene -> Mine -> 3 encounters -> Boss choice -> Exit
- [x] Fighter path feels distinct
- [x] Battlemage path feels distinct
- [x] Recruit and kill branches both feel like real moral choices
- [x] Shaman dialogue and portrait presentation land as intended
- [x] Kobold encounters feel appropriately challenging
- [x] Boss fight is clearly harder than regular encounters
- [x] Level-up flow feels rewarding and legible
- [x] Alignment label reflects the choices made
- [x] HUD tabs are readable and not obstructive
- [x] Map sprites and NPC sprites read clearly at gameplay scale
- [x] Equipment tab reflects the current save model accurately
- [x] Weapon overlay spike is visible when expected
- [x] Old and new saves both resume correctly
- [x] All flags remain correct: `shaman_recruited` / `shaman_killed`, ghost flags, `mine_cleared`
- [x] No progression blockers or softlocks
- [x] Notes logged for Stage 10 or production

**Done state:** John is satisfied with the unpolished experience. Stage 10 can begin.

---

## Stage 10 - Polish and playtester pass
**Status:** Implementation complete, awaiting outside feedback

**Goal:** Make the loop good enough to put in front of a real person.

**Implementation scope completed in this pass:**
- [x] Shared `AudioManager` autoload and music/SFX routing
- [x] Shared `ActorVisuals` autoload and identity registry
- [x] Dialogue `portrait_id` support plus NPC `actor_id` support
- [x] Town collision cleanup
- [x] Mine readability/blocker data cleanup
- [x] Actor identity unification across map, battle, HUD, dialogue, cutscene, and follower states
- [x] Release-safe debug gating
- [x] Playtest packet and Stage 10 runtime harness scaffold

**Reference docs:**
- `docs/stage_10_master_plan.md`
- `docs/stage_10_identity_matrix.md`
- `docs/stage_10_audio_asset_research.md`
- `docs/stage_10_playtest_packet.md`
- `docs/stage_10_tickets.md`

**Verification:**
- [ ] Run `tools/stage_10_runtime_harness.tscn` or manual equivalent and save evidence under `tools/evidence/stage_10/`
- [ ] Put the slice in front of a non-developer playtester
- [ ] Triage and ship the post-feedback Stage 10 fix pass

**Done state:** Vertical slice complete after outside feedback is addressed.

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
| 8.5 | MVP feature pass | Complete |
| 9 | Final feature checklist | Complete |
| 10 | Polish + playtester pass | Implementation complete, awaiting outside feedback |

---

## How to use this document

At the start of each session:
> "Read `docs/HANDOVER.md`, `docs/vertical_slice_plan.md`, and the active stage handoff docs. I am handling Ticket TXX."

After each session:
- tick completed ticket or checklist items
- update the status summary
- for Stage 10 work, update the Stage 10 handoff docs and evidence outputs instead of leaving verification state only in chat history
