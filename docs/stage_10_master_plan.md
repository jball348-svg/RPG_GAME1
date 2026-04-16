# Stage 10 Master Plan

## Status

Stage 10 implementation is complete for `T01` through `T11`.
This pass stops at playtest-ready handoff.

Explicitly deferred:
- `T12` outside-feedback fixes and final sign-off after a real external playtest

---

## What Landed

### Shared systems

- `autoloads/AudioManager.gd`
  - shared music layer with crossfade
  - pooled SFX playback
  - runtime cue lock for `town`, `mine`, `battle`, `boss`, `moral_choice`, `victory_exit`
  - lightweight SFX history helpers for harness smoke checks
- `autoloads/ActorVisuals.gd`
  - shared actor registry for map, battle, portrait, cutscene, follower, and accent/tint data

### Scene integration

- map, battle, HUD, dialogue, and cutscene now consume `ActorVisuals`
- map, battle, HUD, dialogue, prompt, and cutscene now call `AudioManager` directly
- dialogue nodes support `portrait_id` while preserving the raw `portrait` fallback path
- `NPC.gd` and town NPC instances now expose `actor_id`

### Audio

- six music beats locked from `assets/Music/`
- first-pass runtime SFX committed in `assets/SFX/`
- town/crossroads ambience, mine ambience, battle/boss routing, moral-choice sting, victory/exit cue, footsteps, UI, combat, spell, gate, and loot beats wired

### Collision and readability

- town collision changed from five broad blockers to smaller authored shapes
- mine walkable sections and progression blockers rewritten into named data groups
- west branch, east branch, top shaft, boss gate, and exit gate now surface clearer route messaging

### Release hygiene

- debug panel creation gated behind `OS.is_debug_build()`
- debug-only map loader hidden in non-debug builds
- normal hint text no longer hardcodes debug controls
- remaining debug actions on the map are gated behind debug build checks

### Handoff materials

- `docs/stage_10_identity_matrix.md`
- `docs/stage_10_audio_asset_research.md`
- `docs/stage_10_playtest_packet.md`
- `tools/stage_10_runtime_harness.gd/.tscn`
- `tools/evidence/stage_10/README.md`

---

## Current Verification State

What was completed in this implementation pass:
- code integration for Stage 10 systems and scene wiring
- Stage 10 runtime harness scaffold for screenshots plus JSON results
- docs updated to reflect actual repo state

What was not completed in this shell session:
- Godot CLI execution of the Stage 10 runtime harness
- release-build smoke in a non-debug executable
- outside playtest and feedback-driven fixes

Reason:
- Godot CLI was not available on `PATH` in the implementation shell

---

## Active References

- `docs/HANDOVER.md`
- `docs/vertical_slice_plan.md`
- `docs/stage_10_tickets.md`
- `docs/stage_10_identity_matrix.md`
- `docs/stage_10_audio_asset_research.md`
- `docs/stage_10_playtest_packet.md`

---

## Next Pass

The next pass should do exactly three things:

1. Run the Stage 10 harness or equivalent manual capture flow in Godot.
2. Put the slice in front of an outside playtester.
3. Triage and fix only the issues that come back from that playtest.

Do not reopen Stage 10 scope before real outside feedback exists.
