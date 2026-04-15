# Stage 8.5 Master Plan

## Summary

Stage 8.5 is the MVP feature pass between the save-system milestone and developer sign-off. This document is the index and execution-order reference for that pass.

What this docs pass accomplished:
- closed the Stage 8 documentation gap
- standardized naming on `Stage 8.5`
- published the Stage 8.5 spec pack
- converted the next implementation pass into ticketed work with explicit dependencies

What Stage 8.5 still needs:
- asset provenance decisions
- portraits and map sprites
- HUD rebuild
- real progression state
- XP and level-up flow
- alignment label
- simple battle weapon-overlay spike
- save/regression coverage for the new systems

This pass is still docs-only. No code, asset imports, or downloads happened here.

---

## Deliverables

The Stage 8.5 spec pack consists of:
- `docs/stage_8_5_master_plan.md` - this file; execution order and planning method
- `docs/stage_8_5_asset_research.md` - asset audit, provenance notes, external shortlist, primary/fallback candidates
- `docs/stage_8_5_systems_spec.md` - design lock for Stage 8.5 systems and interfaces
- `docs/stage_8_5_tickets.md` - ticket-by-ticket handoff for implementation

Supporting docs updated in the same pass:
- `README.md`
- `docs/HANDOVER.md`
- `docs/vertical_slice_plan.md`
- `docs/art_direction.md`

---

## Plan for how we make the plan

This was the explicit method used to build the Stage 8.5 spec:

1. Audit current repo reality.
   - Compare `README.md`, `HANDOVER.md`, and `vertical_slice_plan.md` against the current code.
   - Identify stale claims, especially around Stage 8 status, HUD behavior, dev controls, and save/load scope.

2. Audit current asset candidates.
   - Inspect `/assets/art` for anything that could plausibly satisfy Stage 8.5 needs.
   - Separate visual fit from provenance fit. An asset can look correct and still be blocked as a default because its source is not documented.

3. Lock system decisions before implementation.
   - Resolve the data-model questions that would otherwise force an implementing agent to improvise.
   - Capture those answers in a durable spec, not just in chat history.

4. Translate the spec into tickets.
   - Break the work into bounded slices with dependencies.
   - Give each slice a clear done-state and acceptance list.

5. Cross-link everything from the main handoff path.
   - A new agent should be able to read `HANDOVER.md` and arrive at the full spec pack in under one minute.

`T00` is complete when those five steps are reflected in the repo docs. That done-state is achieved by this pass.

---

## Execution order

Stage 8.5 should be implemented in this order:

1. `T01` Asset provenance audit
2. `T05` Progression data
3. `T08` Alignment system
4. `T09` Equipment tab shape
5. `T02` Portrait source lock
6. `T03` Map sprite source lock
7. `T06` XP reward flow
8. `T07` Stat allocation flow
9. `T04` HUD rebuild
10. `T10` Weapon-overlay spike
11. `T11` Save/regression pass
12. `T12` Developer review handoff

Reasoning:
- `T01` must happen first because visual tickets should not build on unvetted default assets.
- `T05`, `T06`, and `T07` are a dependency chain; do not implement reward flow before the save-backed progression model exists.
- `T08` and `T09` must lock behavior before the HUD rebuild so the UI does not get rewritten twice.
- `T04` should happen after the data and display rules exist, not before.
- `T11` belongs near the end because it validates the new systems together.

---

## Stage 8.5 goals and non-goals

### Goals
- Reach a meaningful developer review state with visible character identity and a functional progression loop
- Avoid re-deciding system behavior during the implementation pass
- Preserve save compatibility with Stage 8 saves
- Keep placeholder-art choices explicit and reversible

### Non-goals
- Final art replacement
- Full equipment compositing
- Balance pass for XP or stat curves
- Full quest log
- Final production UI polish
- New narrative content beyond what is needed to wire the existing slice

---

## Shared assumptions

- Stage naming is standardized to `8.5`, with Stages `9` and `10` preserved.
- `social.luck` remains derived-only.
- The current eight equipment keys stay in the data model for Stage 8.5.
- Alignment is computed from flags and ghost flags, not stored directly.
- Battlemage map art may need to come from an external source if the in-repo candidate fails fit or provenance review.
- If no provenance-safe weapon overlay art is approved in time, the Stage 8.5 spike can fall back to a simple generated placeholder overlay.

---

## Definition of done for the spec pack

The Stage 8.5 planning/admin pass is complete when:
- the repo docs agree on Stage 8 being complete
- the repo docs agree on Stage 8.5 naming
- the art policy no longer says "CC0 or compatible" without a provenance rule
- all major Stage 8.5 systems have interface-level decisions recorded
- each Stage 8.5 ticket has dependencies, code touchpoints, acceptance checks, and risk notes

That definition of done is satisfied by this pass.

---

## Verification note

Runtime verification should include a Godot headless smoke pass after implementation work lands.

That rerun was **not** possible during this docs pass because `godot` is not installed in the current environment. Treat that as an implementation follow-up, not as a reason to reopen the planning decisions.
