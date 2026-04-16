# Stage 8.5 Master Plan

## Status

Stage 8.5 is complete and archived.

This file records the MVP feature pass that bridged Stage 8 save support and Stage 9 developer sign-off.
It is no longer an active implementation plan.

---

## What Stage 8.5 Delivered

- Shaman portrait support for dialogue presentation
- Fighter, Battlemage, and NPC map-sprite improvements
- tabbed HUD rebuild
- real progression fields in `PlayerData`
- XP rewards and level-up flow
- stat-family allocation flow
- derived-only alignment label
- eight-slot equipment tab
- battle weapon-overlay spike
- save compatibility and regression coverage for the new systems

These outputs were later carried forward into the finished vertical slice.

---

## Historical Deliverables

The Stage 8.5 pack consists of:
- `docs/stage_8_5_master_plan.md`
- `docs/stage_8_5_asset_research.md`
- `docs/stage_8_5_systems_spec.md`
- `docs/stage_8_5_tickets.md`

Supporting docs that were updated alongside the pass:
- `README.md`
- `docs/HANDOVER.md`
- `docs/vertical_slice_plan.md`
- `docs/art_direction.md`

---

## Historical Execution Order

Stage 8.5 was implemented in the ticket order captured in `docs/stage_8_5_tickets.md`.

That order mattered because it locked:
- asset provenance first
- progression state before reward flow
- alignment and equipment display rules before the HUD rebuild
- save/regression verification near the end

Treat that ordering as historical context, not as an active checklist.

---

## Goals Achieved

- reach a meaningful developer-review state with visible class and NPC identity
- add real progression without breaking Stage 8 saves
- lock the HUD, alignment, and equipment-display behavior before wider polish
- validate the weapon-overlay architecture without building a full paper-doll system

---

## Archive Note

If you need to understand why Stage 8.5 behaves the way it does:
1. read `docs/stage_8_5_systems_spec.md`
2. read `docs/stage_8_5_tickets.md`
3. compare that design lock with the current runtime files named in `docs/HANDOVER.md`

Do not reopen Stage 8.5 as an active milestone in this repo.
