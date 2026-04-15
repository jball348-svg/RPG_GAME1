# Stage 8.5 Systems Spec

## Summary

This document is the design lock for the Stage 8.5 feature pass.
If an implementation choice is described here, the implementing agent should follow it rather than improvise.

Stage 8.5 covers:
- one Shaman dialogue portrait
- Fighter, Battlemage, and generic NPC map sprites
- tabbed HUD rebuild
- progression data
- XP reward flow
- level-up stat allocation
- alignment label
- simple battle weapon-overlay spike
- save compatibility for the new progression state

---

## Planned interfaces

### `PlayerData`
`PlayerData` becomes the source of truth for:
- `level: int = 1`
- `xp: int = 0`
- `xp_to_next_level: int = 100`
- `unspent_stat_points: int = 0`

Keep the current eight equipment keys:
- `head`
- `chest`
- `legs`
- `feet`
- `weapon`
- `offhand`
- `ring`
- `amulet`

### `SignalBus`
Add:
- `signal level_up(level: int)`

### `StatRegistry`
Add one public helper for Stage 8.5 category allocation.

Required behavior:
- accept a top-level family key such as `physical` or `holy`
- add `+1.0` to every non-derived child skill in that family
- recalculate Luck after Social allocation
- clamp as needed using existing stat rules

### `AlignmentSystem`
Add `autoloads/AlignmentSystem.gd` as a derived-only autoload.

Required behavior:
- read flags and ghost flags from `PlayerData`
- compute alignment on demand
- expose both axis labels and full label strings for the HUD
- do not store separate save data

### `HUD`
Replace the current summary overlay with a tabbed HUD contract:
- `Stats`
- `Equipment`
- `Quest`
- `Map`

HUD must support:
- normal manual open from map
- direct open to `Stats` after a level-up return flow

### `DialogueManager`
Keep the current portrait-path string field.

Stage 8.5 only needs:
- a real portrait path on the Shaman dialogue nodes
- no dialogue data-model rewrite

---

## Portrait spec

### Scope
- One named portrait only: the Shaman
- Use the existing `DialogueBox` portrait slot
- Portrait is temporary placeholder art, not final production art

### Visual rules
- Square image preferred
- Any size from 64x64 to 256x256 is acceptable
- Readability matters more than exact resolution
- Optional frame treatment is allowed if it improves legibility and stays within the stone/parchment UI language

### Wiring rules
- Populate the `portrait` field on:
  - `shaman_intro_cutscene`
  - `shaman_recruit_resolution`
- `DialogueBox.gd` already resolves the path and falls back if the texture is missing
- No changes to dialogue-tree structure are required

---

## Map sprite spec

### Goal
Replace square placeholders with readable 32x32 top-down sprites for:
- Fighter player
- Battlemage player
- generic town NPCs

### Rules
- Stage 8.5 may use one representative frame per sprite rather than full walking animation
- Keep Pure/Mixed tinting through runtime modulate, not duplicated art files
- Do not bake faction tint into the source asset

### Source rules
- Fighter and generic NPCs may use the repo LPC sheet if provenance is traced in `T01`
- Battlemage should default to an external 32x32 top-down source unless a better in-repo candidate is recovered
- Do not use `assets/art/battle/LPC_starhat/sample.png` as the default Battlemage map sprite source

### Expected implementation shape
- `Map.tscn` / `Map.gd`: replace the player square texture with an atlas crop
- `NPC.tscn`: replace the square texture with a sprite crop or approved placeholder texture
- Keep sprite nodes simple; Stage 8.5 does not need an animation controller

---

## HUD spec

### General behavior
- HUD remains an overlay, not a standalone state
- Stage 8.5 keeps the current map-only interaction model for manual HUD opening
- After a level-up, the battle flow may request the HUD to open to `Stats` after the return to map

### Tabs

#### `Stats`
Show:
- `Level`
- `XP: current / xp_to_next_level`
- unspent points indicator when `unspent_stat_points > 0`
- alignment label
- current gold
- the six top-level stat-family rows

Display top-level stat-family values as averages of non-derived child skills:
- `Physical = avg(strength, endurance, movement)`
- `Magik = avg(spellcasting, attunement, mana)`
- `Intelligence = avg(understanding, tactics, persuasion)`
- `Social = avg(charm, reputation, empathy)` - exclude Luck from the average because it is derived
- `Will = avg(resolve, focus, resistance)`
- `Holy = avg(faith, intuition, peace, justice)`

When `unspent_stat_points > 0`:
- show one `+1` button next to each top-level family row
- pressing a button spends exactly one point
- spent point effect: `+1` to every non-derived child skill in that family
- disable all buttons when `unspent_stat_points == 0`

#### `Equipment`
Show eight labelled slots:
- Head
- Armour
- Legs
- Boots
- Weapon
- Offhand
- Ring
- Amulet

Display rule:
- show equipped item name if non-empty
- otherwise show `Empty`

Stage 8.5 does not add equip/unequip interaction.

#### `Quest`
Show one active quest block only.

Quest title:
- `Into the Mine` while the mine loop is active
- `Beyond the Mine` after `mine_cleared` and `main_quest_path_open`

Objective line rules:
- if `mine_encounter_progress == 0`: `Enter the mine and clear the first chamber.`
- if `mine_encounter_progress` is `1` or `2` and `mine_boss_resolved` is false: `Clear the remaining Kobold chambers.`
- if `mine_encounter_progress >= 3` and `mine_boss_resolved` is false: `Confront the Shaman in the boss chamber.`
- if `mine_boss_resolved` is true and `mine_cleared` is false: `Leave the mine.`
- if `mine_cleared` and `main_quest_path_open`: `Travel onward from the crossroads.`

#### `Map`
Show placeholder text only:
- `Map - coming soon`

---

## XP and level-up spec

### XP rewards
- Kobold victory: `+30 XP`
- Shaman victory: `+80 XP`

### Battle flow order
1. Resolve victory as normal.
2. Award gold and other existing rewards.
3. Award XP based on enemy type.
4. Update the loot panel text to include an XP line.
5. After the loot panel phase, evaluate level-up.
6. If one or more levels are gained:
   - increment `level`
   - subtract threshold from `xp`
   - add `3` to `unspent_stat_points`
   - emit `SignalBus.level_up(level)` once per level gained
   - show `Level Up!` in the existing center banner for `1.5s`
7. Return to map.
8. Open HUD directly to `Stats` if any level-up occurred.

### Overflow rule
Use a `while xp >= xp_to_next_level` loop so overflow XP is not lost.

### Threshold rule
Stage 8.5 keeps a flat `xp_to_next_level = 100`.
Curve work belongs to later production balancing.

---

## Stat allocation spec

### Spending rule
One point spent on a top-level family applies `+1` to every non-derived child skill in that family.

Examples:
- Spending on `Physical` raises `strength`, `endurance`, and `movement`
- Spending on `Social` raises `charm`, `reputation`, and `empathy`, then recalculates `luck`
- Spending on `Holy` raises `faith`, `intuition`, `peace`, and `justice`

### Why this is locked
- It matches the agreed Stage 8.5 decision
- It avoids inventing new parent stat storage
- It lets the visible HUD family value move cleanly because the displayed family number is the average of its children

### Non-goal
Stage 8.5 does not need to rebalance combat numbers around these gains.
Architecture and legibility matter more than tuning in this pass.

---

## Alignment spec

### Model
Use a 3x3 DnD-style label:
- Lawful / Neutral / Chaotic
- Good / Neutral / Evil

### Inputs
Read from `PlayerData.flags` and `PlayerData.ghost_flags`.

### Rule table

| Condition | Axis effect |
|---|---|
| `pure_rep_shaman_mercy == true` | `+1 Good` |
| `mixed_betrayed_own == true` | `+1 Evil` |
| `shaman_recruited == true` | `+1 Chaotic` |
| `shaman_killed == true` and player is on Pure path | `+1 Lawful` |

### Tie/default behavior
- If Lawful score equals Chaotic score, use `Neutral` on the law/chaos axis
- If Good score equals Evil score, use `Neutral` on the good/evil axis
- If both axes are neutral, display `True Neutral`

### Output examples
- `Lawful Good`
- `Chaotic Neutral`
- `Neutral Evil`
- `True Neutral`

### Persistence rule
Do not save alignment as its own field.
Always recompute from current flags and ghost flags.

---

## Weapon-overlay spike spec

### Goal
Prove the architecture for battle equipment visibility without building a full paper-doll system.

### Rule
- If `PlayerData.equipment["weapon"]` is empty, no overlay is shown.
- If `PlayerData.equipment["weapon"]` is non-empty, show one visible weapon overlay on the player battle sprite.

### Asset rule
- One placeholder overlay is enough.
- The overlay does not need to vary by item ID in Stage 8.5.

### Fallback if art is blocked
If no suitable provenance-safe art is approved in `T01`, generate a simple neutral weapon overlay in-repo and use that for the spike.

### Non-goal
No full compositing, animation syncing, or per-weapon asset matrix.

---

## Save compatibility spec

### Old save behavior
If a Stage 8 save is missing the new progression fields or contains null placeholders:
- `level = 1`
- `xp = 0`
- `xp_to_next_level = 100`
- `unspent_stat_points = 0`

### New save behavior
Stage 8.5 saves must persist the real progression fields above.

### Alignment behavior
Alignment remains derived-only and is never saved directly.

### Regression expectation
After Stage 8.5 implementation:
- old save files must still load
- new save files must preserve progression
- branch outcomes for recruit/kill must remain intact

---

## Out of scope

- final portrait art
- full map sprite animation system
- full equipment paper-doll rendering
- quest log expansion beyond one active objective
- combat rebalance
- release-build polish
