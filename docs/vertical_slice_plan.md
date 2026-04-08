# Vertical Slice Plan — RPG_GAME1
> Same structure as the technical spike: define the goal, build the minimum to prove it, verify, lock, move on.
> Do not start the next stage until the current one passes its verification check.

---

## What the vertical slice must deliver

A complete, polished, playable run of the core loop:
**Load → Town → Leave → Cutscene → Mine → Battles → Boss (moral choice) → Exit**

When a playtester can complete that loop without guidance and find it fun, the vertical slice is done.
Everything else is production.

---

## Stage 1 — Real town map
**Status:** ✅ Complete

TileMap-authored starting town. Collision, camera bounds, north exit trigger. Viewport 480×270 / 1280×720.

---

## Stage 2 — NPC dialogue system
**Status:** ✅ Complete

Reusable `DialogueManager` autoload. Condition types: `stat_gte`, `gold_gte`, `flag_set`, `pure_path`, `mixed_path`. Three wired core-loop NPCs: intel, moral choice, bookstore.

---

## Stage 3 — Town exit and mine entrance cutscene
**Status:** ✅ Complete

Point-of-no-return prompt → path/class-tinted cutscene → mine spawn. One-time stat ticks on confirm.

---

## Stage 4 — Mine dungeon map
**Status:** ✅ Complete

Editor-authored cave map. Ordered encounter zones (4), boss-room gate, exit lock. Progression flags: `mine_encounter_progress`, `mine_boss_ready`, `mine_boss_resolved`, `mine_exit_unlocked`, `mine_cleared`.

---

## Stage 5 — Battle system
**Status:** ✅ Complete

Full turn-based `Battle.gd`. Actions: Attack, Spell, Item, Flee, Ability. Fighter (Shield Bash) and Battlemage (Arcane Strike/Flamebolt) feel distinct. Kobold enemy. HP bars, battle log, screen shake, hit flash shader, sprite bob. Loot and game-over resolution. Responsive layout. Suppressed-trigger return to map.

---

## Stage 6 — Boss room and moral choice
**Status:** 🔄 In progress (2 checks outstanding)

Half-Kobold Orc Shaman. Cutscene-driven intro via `cutscene_id = "shaman_intro"`. Two branches: recruit (stat boosts, no combat) or fight (`BATTLE_KIND_BOSS_SHAMAN`, HP 60). Ghost flags set for all 4 path/choice permutations. Exit gate unlocks after either branch.

**Remaining:**
- [ ] `shaman_warning_given` flag → Shaman references the warning
- [ ] Boss victory → kill flags + ghost flags set, 25 gold + `shaman_talisman` awarded, mine exit unlocks

**Done state:** Moral choice works with real mechanical and flag consequences.

---

## Stage 6.5 — Dev skip / scene-load cheat
**Status:** ⬜ Not started

**Goal:** Make playtesting and development faster. Two tools: a battle skip key, and a scene-load shortcut to spawn the player at any map location without replaying the full loop.

### Battle skip (key: P)
- During battle, on the player's turn, pressing `P` immediately triggers the victory sequence as if the enemy was killed by a normal attack.
- Runs the full `_run_victory_sequence()` path — loot rolls, flag increments, stat events, return to map — so it stress-tests the resolution flow, not just exits the scene.
- Only active when `OS.is_debug_build()` is true. Invisible in release builds.
- Log line on use: `"[DEV] Battle skipped."`

### Scene/location loader (key: L)
- Pressing `L` on the map opens a small dev overlay panel (same pattern as existing debug overlay).
- Panel shows a list of named spawn points — at minimum:
  - `town_start` — player spawns at town entrance
  - `mine_entry` — player spawns at mine entrance with `mine_entry_commit_applied` set
  - `mine_mid` — player spawns past encounter zones 1–2 with `mine_encounter_progress = 2`
  - `mine_boss_ready` — player spawns in antechamber with all encounters cleared and `mine_boss_ready = true`
  - `post_boss` — player spawns in post-boss corridor with `mine_boss_resolved = true` and `mine_exit_unlocked = true`
- Selecting a spawn point sets the relevant flags, moves the player to that position, and closes the panel.
- Only active when `OS.is_debug_build()` is true.
- Add a note in `HANDOVER.md` dev controls section listing `P` and `L`.

**Verification:**
- [ ] Press `P` during battle → victory sequence runs in full, returns to map with loot
- [ ] Press `P` during boss fight → Shaman victory resolution runs (flags set, loot awarded)
- [ ] Press `L` on map → spawn panel opens
- [ ] Each spawn point lands player at correct location with correct flags pre-set
- [ ] Neither `P` nor `L` is accessible in a non-debug build

**Done state:** Developer can reach any point in the loop in under 30 seconds.

---

## Stage 7 — Mine exit and area transition
**Status:** ⬜ Not started

**Goal:** Leaving the mine reveals a new area. The core loop completes.

**Tasks:**
- [ ] Mine exit trigger → cutscene: player emerges into daylight / new region
- [ ] New region map stub: road, distant mountains, signpost — TileMap-authored, minimum viable
- [ ] Quest flags: `mine_cleared = true`, `main_quest_path_open = true`
- [ ] Shaman companion sprite appears alongside player in exit cutscene if `shaman_recruited = true`
- [ ] Cutscene returns player to new region map stub at a defined spawn point

**Verification:**
- [ ] Walk to exit trigger → cutscene fires
- [ ] Shaman appears in cutscene if recruited, absent if killed
- [ ] New region map loads at correct spawn
- [ ] `mine_cleared` and `main_quest_path_open` flags set
- [ ] New area reads as outside — daylight, open space, different tileset to mine
- [ ] Headless smoke run passes

**Done state:** The core loop completes end to end.

---

## Stage 8 — Save system
**Status:** ⬜ Not started

**Goal:** Full save and load. Every state that matters is persisted.

**Tasks:**
- [ ] `SaveManager` autoload: `save_game()`, `load_game()`, `has_save()`
- [ ] Saves: full `StatRegistry.stats`, `PlayerData` (all flags + ghost flags + inventory + equipment + level/XP), `GameClock` time, location, quest flags
- [ ] Save file: `user://save_game.json`
- [ ] Auto-save triggers: map entry, dialogue complete, battle victory, moral choice resolved
- [ ] On launch: load if save exists, else boot to new game defaults

**Verification:**
- [ ] Play 5 mins, quit, relaunch — all state restored
- [ ] Clock resumes from saved time
- [ ] Ghost flags persist
- [ ] Shaman branch outcome persists correctly
- [ ] Level and XP persist

**Done state:** Progress is never lost.

---

## Stage 8b — MVP feature pass
**Status:** ⬜ Not started

**Goal:** Implement a set of spike-quality features that must exist in the game before the developer review. Nothing needs to be polished — just present and functional enough to evaluate.

---

### Dialogue portraits
- Portrait slot in `DialogueBox` exists but is empty.
- Source or generate one portrait image — priority is the Shaman (most dramatically important character).
- Wire it into the dialogue box portrait slot for the Shaman's `shaman_intro` cutscene.
- Any resolution is fine; it will be replaced in production.

### Class-specific map sprites
- Player is currently a coloured square.
- Replace with a class-specific 32×32 top-down sprite: Fighter (Pure), Battlemage (Mixed).
- Use LPC spritesheet assets already in the project. Crop a top-down walking frame.
- Keep Pure/Mixed path tint accent (gold/teal) on top.

### NPC map sprites
- NPCs are currently coloured squares.
- Replace with a 32×32 NPC sprite from LPC assets already in the project.
- Does not need to be unique per NPC — one generic humanoid sprite for all town NPCs is fine.

### Alignment system — spike
- D&D-style 3×3 alignment matrix: Law–Neutral–Chaos (x-axis) × Good–Neutral–Evil (y-axis).
- Player position is derived from existing flags and ghost flags. No new player input.
- Flag-to-alignment derivation rules (establish in a new `AlignmentSystem.gd` or inline in `PlayerData.gd`):
  - `pure_rep_shaman_mercy = true` → +Good
  - `mixed_betrayed_own = true` → +Evil
  - `shaman_recruited = true` → +Chaotic
  - `shaman_killed = true` on Pure path → +Lawful
  - Default starting position: True Neutral
- Display: alignment label only in HUD Stats tab (e.g. "Lawful Good"). No grid visualisation needed for spike.
- Reference mood board: `assets/art/Mood Board/bg3-alignment-chart-v0-lb31w8gqv26c1.webp`
- Derivation logic will be expanded in production.

### Levelling system — spike
The game needs a levelling loop. This spike establishes the mechanic and architecture; values and balance are placeholders.

**Data (add to `PlayerData.gd`):**
- `level: int = 1`
- `xp: int = 0`
- `xp_to_next_level: int = 100` (flat threshold for spike — proper curve in production)
- `unspent_stat_points: int = 0`

**XP gain:**
- On battle victory, award XP based on enemy type: Kobold = 30 XP, Shaman = 80 XP.
- Show XP gain in the loot panel: e.g. `"Victory!\nGold: 12\nXP: +30"`.
- After loot panel, check if `xp >= xp_to_next_level`.

**Level-up flow:**
- If threshold met: set `level += 1`, `xp -= xp_to_next_level`, `unspent_stat_points += 3`, emit `SignalBus.level_up.emit(level)`.
- Show a `"Level Up!"` banner (same centre-screen banner used for `"Victory!"`), hold 1.5s.
- After banner: transition to HUD Stats tab directly (use existing `SceneManager` HUD open pattern).
- On the Stats tab, if `unspent_stat_points > 0`, show a `"+ 1"` button next to each of the 6 top-level stats. Pressing it increments that stat by 1 (via `StatRegistry`), decrements `unspent_stat_points` by 1, and disables all `+` buttons when `unspent_stat_points` reaches 0.
- No animation, no confirm screen — just the buttons. Player presses 3 times total and closes HUD.
- Stats allocated here do not need to materially affect combat in the spike. The architecture matters, not the balance.

**HUD Stats tab additions:**
- Add `Level: X` and `XP: X / 100` to the top of the Stats tab.
- Show `"X points to spend"` indicator when `unspent_stat_points > 0`.

### HUD — MVP pass

**Stats tab:**
- All 6 top-level stats with current values
- `Level`, `XP / XP_to_next`, unspent points indicator (if any)
- Alignment label
- Current gold

**Equipment tab:**
- Seven labelled slots: Helm, Armour, Weapon, Boots, Offhand, Accessory, and one class slot ("Spellbook" for Battlemage, "Shield" for Fighter)
- Show item name if equipped, "Empty" if not
- Display only — no equip/unequip interaction in this stage

**Quest tab:**
- Show active quest name ("Into the Mine") and one objective line derived from `mine_encounter_progress` and `mine_boss_resolved`
- No full quest log — just the current objective

**Map tab:**
- Blank panel, text: "Map — coming soon"
- Must exist as a tab; content is deferred

### Equipment rendering on battle sprite — spike
- If `PlayerData.equipment["weapon"]` is non-empty, apply a visible change to the player's battle sprite (conditional texture swap or overlay layer).
- Does not need to be a full compositing system. One conditional is enough.
- Proves the architecture before production builds it out.

**Verification:**
- [ ] Shaman dialogue/cutscene shows a portrait image
- [ ] Fighter and Battlemage have distinct 32×32 top-down map sprites
- [ ] Town NPCs have a sprite instead of a coloured square
- [ ] Alignment label displays correctly in HUD Stats tab
- [ ] Alignment shifts with relevant flags (test with debug path toggle)
- [ ] Battle victory shows XP gain in loot panel
- [ ] Level-up banner fires when XP threshold is met
- [ ] HUD Stats tab opens after level-up with `+` buttons visible
- [ ] Pressing `+` three times spends all points; buttons disable
- [ ] `Level` and `XP` display correctly in HUD Stats tab
- [ ] HUD Equipment tab shows all slots, populated or "Empty"
- [ ] HUD Quest tab shows current objective
- [ ] HUD Map tab exists with placeholder text
- [ ] Equipping a weapon produces a visible change in the battle sprite

**Done state:** The game has enough visual and systemic presence for a meaningful developer review.

---

## Stage 9 — Final feature checklist (developer sign-off)
**Status:** ⬜ Not started

**Goal:** John plays through the complete loop and confirms every feature is working and directionally correct. No code changes unless something is broken or fundamentally wrong.

**Checklist:**
- [ ] Complete core loop without debug controls: Town → Leave → Cutscene → Mine → 3 encounters → Boss choice → Exit
- [ ] Fighter path feels distinct — Shield Bash has impact
- [ ] Battlemage path feels distinct — versatility is legible
- [ ] Recruit and kill branches both feel like real moral choices
- [ ] Shaman dialogue lands as intended allegory for both Pure and Mixed
- [ ] Kobold encounters feel appropriately challenging
- [ ] Boss fight is clearly harder than regular encounters
- [ ] Level-up flow feels rewarding — stat allocation is legible
- [ ] Alignment label reflects the choices made
- [ ] All flags correct: `shaman_recruited`/`shaman_killed`, ghost flags, `mine_cleared`
- [ ] HUD is readable and not obstructing gameplay
- [ ] All transitions feel smooth enough for a playtester
- [ ] No progression blockers or softlocks
- [ ] Notes logged for Stage 10 or production

**Done state:** John is satisfied with the unpolished experience. Stage 10 can begin.

---

## Stage 10 — Polish and playtester pass
**Status:** ⬜ Not started

**Goal:** Make the loop good enough to put in front of a real person.

**Tasks:**
- [ ] Remove dev controls (`P`, `L`, `B`, `H`, `C`, `1`, `2`) from non-debug builds (already gated by `OS.is_debug_build()` — verify)
- [ ] Remove debug overlay panel from release build
- [ ] Audio: ambient town, ambient mine, battle music, victory sting, moral choice sting
- [ ] SFX: footstep, attack, spell cast, dialogue advance, menu sounds
- [ ] UI pass: dialogue box, HUD tabs, battle menu — match art direction
- [ ] Fix known tree collision issues from Stage 1
- [ ] Final portrait pass — Shaman at minimum
- [ ] Game over screen
- [ ] First external playtester pass

**Verification:**
- [ ] Unknown player completes loop without help
- [ ] No debug text or controls visible in normal play
- [ ] Audio throughout
- [ ] Smooth transitions

**Done state:** Vertical slice complete.

---

## Current status summary

| Stage | Task | Status |
|---|---|---|
| 1 | Real town map | ✅ Complete |
| 2 | NPC dialogue system | ✅ Complete |
| 3 | Town exit + mine entrance cutscene | ✅ Complete |
| 4 | Mine dungeon map | ✅ Complete |
| 5 | Battle system | ✅ Complete |
| 6 | Boss room + moral choice | 🔄 In progress |
| 6.5 | Dev skip / scene-load cheat | ⬜ |
| 7 | Mine exit + area transition | ⬜ |
| 8 | Save system | ⬜ |
| 8b | MVP feature pass | ⬜ |
| 9 | Final feature checklist | ⬜ |
| 10 | Polish + playtester pass | ⬜ |

---

## How to use this document

At the start of each session:
> "Read `docs/HANDOVER.md` and `docs/vertical_slice_plan.md`. I am on Vertical Slice Stage X — [name]. Help me complete the tasks."

After each session: tick completed tasks, update the status table, mark stage ✅ when all verification passes.
