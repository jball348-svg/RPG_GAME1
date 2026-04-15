# Stage 8.5 Tickets

This file is the executable handoff for the next implementation pass.
Each ticket is intended to be decision-complete.

---

## T00 - Plan-the-plan

**Status:** Complete in this docs pass

**Goal**
- Audit current docs and code
- Capture the mismatches
- Publish the Stage 8.5 spec pack

**Primary files**
- `README.md`
- `docs/HANDOVER.md`
- `docs/vertical_slice_plan.md`
- `docs/art_direction.md`
- `docs/stage_8_5_*`

**Acceptance**
- Stage 8 is documented as complete
- `Stage 8.5` replaces `Stage 8b`
- current controls, HUD state, and save-system description match the repo
- the Stage 8.5 spec pack exists and is cross-linked

**Risk note**
- Do not let stale docs survive into the implementation pass. That is how future agents re-open solved decisions.

---

## T01 - Asset provenance audit

**Prerequisites**
- `T00`

**Goal**
- Classify every Stage 8.5-relevant art candidate as `approved`, `needs attribution`, `needs source trace`, or `do not use as default`

**Primary files**
- `docs/stage_8_5_asset_research.md`
- `docs/art_direction.md`
- `assets/art/**`

**Implementation steps**
- Recover or confirm source pages for any repo asset intended as a default
- Record license and attribution burden next to each candidate
- Lock one primary and one fallback source per need:
  - Fighter map sprite
  - Battlemage map sprite
  - generic NPC map sprite
  - Shaman portrait
  - weapon overlay
  - HUD/UI

**Acceptance**
- No Stage 8.5 visual ticket depends on an unclassified asset
- Repo LPC player sheet is either traced or deliberately replaced by a documented fallback
- Battlemage map-sprite source is explicitly chosen

**Risk note**
- "Already in the repo" is not enough. Unknown provenance must remain blocked as a default.

---

## T02 - Portrait ticket

**Prerequisites**
- `T01`

**Goal**
- Add one temporary Shaman portrait to the existing dialogue portrait slot

**Primary files**
- `autoloads/DialogueManager.gd`
- `scenes/ui/DialogueBox.gd`
- `docs/stage_8_5_asset_research.md`

**Implementation steps**
- Choose the approved portrait source from `T01`
- Save the portrait under a stable path inside `assets/art/`
- Populate the `portrait` field on:
  - `shaman_intro_cutscene`
  - `shaman_recruit_resolution`
- Keep `DialogueBox.gd` fallback behavior unchanged

**Acceptance**
- Shaman dialogue shows a portrait in the existing portrait slot
- Missing-resource fallback still works
- Portrait source and attribution requirement are documented

**Risk note**
- Do not add a portrait pipeline. Stage 8.5 needs one named portrait only.

---

## T03 - Map sprite ticket

**Prerequisites**
- `T01`

**Goal**
- Replace the player and town NPC square placeholders with readable 32x32 top-down sprites

**Primary files**
- `scenes/map/Map.tscn`
- `scenes/map/Map.gd`
- `scenes/npc/NPC.tscn`
- `docs/stage_8_5_asset_research.md`

**Implementation steps**
- Choose the Fighter sprite source
- Choose the Battlemage sprite source
- Choose the generic NPC sprite source
- Replace the current gradient-square texture assignments with atlas crops or approved textures
- Preserve Pure/Mixed tint through `modulate`

**Acceptance**
- Fighter and Battlemage look distinct at map scale
- Generic NPCs use a sprite instead of a square
- Pure/Mixed tint still reads correctly

**Risk note**
- Do not spend this ticket building animation state machines. One representative frame is enough for Stage 8.5.

---

## T04 - HUD rebuild ticket

**Prerequisites**
- `T05`
- `T07`
- `T08`
- `T09`

**Goal**
- Replace the current summary overlay with the Stage 8.5 tabbed HUD

**Primary files**
- `scenes/hud/HUD.gd`
- `scenes/main/Main.gd`
- `scenes/map/Map.gd`
- optionally `autoloads/SceneManager.gd` if a payload helper is needed

**Implementation steps**
- Build the four-tab structure: `Stats`, `Equipment`, `Quest`, `Map`
- Implement the `Stats` display contract from `docs/stage_8_5_systems_spec.md`
- Add `+1` controls for top-level family allocation
- Implement `Equipment` as eight display-only slots
- Implement `Quest` as one active quest block
- Implement `Map` as placeholder text
- Add direct-open-to-Stats behavior for the post-level-up return flow

**Acceptance**
- Manual HUD open still works on map
- Post-level-up HUD opens to `Stats`
- All fields described in the systems spec appear
- Allocation buttons disable when points are exhausted

**Risk note**
- Do not build a general-purpose UI framework here. Ship the required HUD behavior only.

---

## T05 - Progression data ticket

**Prerequisites**
- `T00`

**Goal**
- Make `PlayerData` the real home for Stage 8.5 progression state

**Primary files**
- `autoloads/PlayerData.gd`
- `autoloads/SaveManager.gd`
- `docs/stage_8_5_systems_spec.md`

**Implementation steps**
- Add concrete defaults for:
  - `level`
  - `xp`
  - `xp_to_next_level`
  - `unspent_stat_points`
- Update `get_save_data()` to save real values instead of placeholders
- Update `apply_save_data()` to backfill old/null saves with the Stage 8.5 defaults

**Acceptance**
- Fresh boot initializes progression state correctly
- Old Stage 8 saves load with safe defaults
- New saves write real progression values

**Risk note**
- Do not break existing inventory/equipment/current HP initialization while adding progression.

---

## T06 - XP reward ticket

**Prerequisites**
- `T05`

**Goal**
- Add XP rewards and level-up detection to battle victory flow

**Primary files**
- `scenes/battle/Battle.gd`
- `autoloads/SignalBus.gd`
- `docs/stage_8_5_systems_spec.md`

**Implementation steps**
- Add `SignalBus.level_up(level)`
- Award XP on victory:
  - Kobold: `30`
  - Shaman: `80`
- Include XP in the loot panel text
- Evaluate level-up after XP is granted
- Emit `level_up(level)` once per level gained
- Show `Level Up!` banner when applicable
- Return to map with a payload requesting the HUD `Stats` tab

**Acceptance**
- Victory text includes XP
- Level-up triggers at the right threshold
- Overflow XP is preserved
- Level-up banner appears before the return flow completes

**Risk note**
- Do not open the HUD directly from the battle scene. Return to map first, then open the HUD there.

---

## T07 - Stat allocation ticket

**Prerequisites**
- `T05`

**Goal**
- Implement the agreed Stage 8.5 stat-spending rule

**Primary files**
- `autoloads/StatRegistry.gd`
- `scenes/hud/HUD.gd`
- `docs/stage_8_5_systems_spec.md`

**Implementation steps**
- Add a public category-allocation helper in `StatRegistry`
- Increment every non-derived child skill in the selected family by `+1`
- Recalculate Luck after Social allocation
- Wire the HUD buttons to that helper
- Decrement `unspent_stat_points` per spend
- Display top-level family values as child-skill averages

**Acceptance**
- One click spends one point
- `Social` spend updates `charm`, `reputation`, `empathy`, and derived `luck`
- HUD family rows visibly move by exactly `+1`
- Buttons disable at zero remaining points

**Risk note**
- Do not accidentally add `luck` as a directly editable child.

---

## T08 - Alignment ticket

**Prerequisites**
- `T00`

**Goal**
- Add a derived-only alignment system and surface its label in the HUD

**Primary files**
- `autoloads/AlignmentSystem.gd`
- `project.godot`
- `scenes/hud/HUD.gd`
- optionally `autoloads/PlayerData.gd` only if small helper accessors are useful

**Implementation steps**
- Create `AlignmentSystem.gd` as an autoload
- Implement the rule table from `docs/stage_8_5_systems_spec.md`
- Expose:
  - full label
  - axis labels if useful
- Read current flags/ghost flags directly from `PlayerData`
- Surface the label in the HUD `Stats` tab

**Acceptance**
- Default label is `True Neutral`
- Recruit/kill branch and ghost-flag changes shift the label as expected
- No alignment data is saved

**Risk note**
- Keep this derived-only. Do not turn alignment into a second flag system.

---

## T09 - Equipment tab ticket

**Prerequisites**
- `T00`

**Goal**
- Lock HUD equipment display to the current eight-slot model

**Primary files**
- `scenes/hud/HUD.gd`
- `autoloads/PlayerData.gd`

**Implementation steps**
- Use the current keys directly:
  - `head`
  - `chest`
  - `legs`
  - `feet`
  - `weapon`
  - `offhand`
  - `ring`
  - `amulet`
- Map them to display labels:
  - Head
  - Armour
  - Legs
  - Boots
  - Weapon
  - Offhand
  - Ring
  - Amulet
- Show `Empty` when the value is blank

**Acceptance**
- HUD shows eight slots, not seven
- Save model and HUD model stay aligned

**Risk note**
- Do not start a data migration here. That would add risk for no Stage 8.5 value.

---

## T10 - Weapon-overlay ticket

**Prerequisites**
- `T01`
- `T03`

**Goal**
- Add one simple visible battle weapon overlay when a weapon is equipped

**Primary files**
- `scenes/battle/Battle.gd`
- any newly approved overlay asset path from `T01`

**Implementation steps**
- Add one extra overlay node or sprite aligned with the player battle sprite
- Show it only when `PlayerData.equipment["weapon"]` is non-empty
- Use one placeholder texture for all non-empty weapons in Stage 8.5
- If approved art is blocked, use an in-repo generated placeholder overlay

**Acceptance**
- Empty weapon slot -> no overlay
- Non-empty weapon slot -> visible overlay
- Overlay remains positioned correctly on the player sprite

**Risk note**
- This is an architecture spike, not a full rendering system.

---

## T11 - Save/regression ticket

**Prerequisites**
- `T05`
- `T06`
- `T07`
- `T08`
- `T09`
- `T10`

**Goal**
- Protect Stage 8 save behavior while extending it for Stage 8.5 systems

**Primary files**
- `autoloads/PlayerData.gd`
- `autoloads/SaveManager.gd`
- `scenes/main/Main.gd`
- `docs/vertical_slice_plan.md`
- `docs/HANDOVER.md`

**Implementation steps**
- Verify old-save compatibility defaults for progression
- Verify new-save writes real progression values
- Confirm alignment remains derived-only
- Update any save-related docs if implementation details shift
- Run the manual regression list below

**Manual regression list**
- Boot with no save -> defaults load correctly
- Boot with old Stage 8 save -> defaults backfill correctly
- Win a Kobold battle -> XP persists after reload
- Win the Shaman battle -> XP and loot persist after reload
- Recruit the Shaman -> flags and alignment survive reload
- Spend stat points -> new values survive reload
- Return from level-up -> HUD state does not strand the player

**Acceptance**
- Old saves load
- New saves persist progression
- Recruit/kill branches remain correct
- No save corruption from HUD or alignment additions

**Risk note**
- Save regressions are the highest-risk part of Stage 8.5 because Stage 8 is already live in the repo.

---

## T12 - Developer review handoff

**Prerequisites**
- `T01` through `T11`

**Goal**
- Convert Stage 8.5 completion into a clean Stage 9 sign-off pass

**Primary files**
- `docs/vertical_slice_plan.md`
- `docs/HANDOVER.md`
- any short review checklist or notes file created during implementation

**Implementation steps**
- Mark completed Stage 8.5 tickets
- Update Stage 9 checklist wording if implementation surfaces new review concerns
- Record any conscious cuts or known rough edges for Stage 10

**Acceptance**
- Every Stage 8.5 feature maps to a Stage 9 review item
- Remaining risks are documented instead of being hidden in chat history

**Risk note**
- Do not end Stage 8.5 with an implicit handoff. The review checklist must reflect the actual work that landed.
