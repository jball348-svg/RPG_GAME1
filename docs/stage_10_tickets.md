# Stage 10 Tickets

This file is now the Stage 10 completion ledger.

Scope rule for this pass:
- implement `T01` through `T11`
- stop at playtest-ready handoff
- defer outside-feedback fixes to `T12`

---

## Ticket Status

| Ticket | Status | Notes |
|---|---|---|
| `T00` Plan-the-plan | Complete | Planning pack and repo reality reconciled. |
| `T01` Music cue lock | Complete | Six cue IDs locked from `assets/Music/`, including victory/exit. |
| `T02` SFX sourcing/import | Complete for first pass | Repo-local generated placeholder `OGG` SFX committed and wired. |
| `T03` Town passability audit | Complete | Broad blockers replaced by smaller authored collision shapes. |
| `T04` Mine passability audit | Complete | Walkable sections and blockers moved into named data; route messaging tightened. |
| `T05` Map readability pass | Complete | Registry-driven player/NPC/follower visuals, step audio, hint cleanup. |
| `T06` Character identity matrix | Complete | `docs/stage_10_identity_matrix.md` mirrors `ActorVisuals.gd`. |
| `T07` Player identity unification | Complete | Fighter and Battlemage now route through `ActorVisuals` across map/battle/HUD/cutscene. |
| `T08` Shaman and story-NPC identity | Complete | Shaman unified around one source family; town NPCs get explicit actor IDs and portraits. |
| `T09` Presentation polish | Complete for Stage 10 scope | Audio cohesion, prompt/HUD/dialogue cues, portrait routing, and cutscene cue beats landed. |
| `T10` Release/debug cleanup | Complete | Debug panel and debug map flow gated to debug builds; normal hint text cleaned. |
| `T11` External playtest prep | Complete | Playtest packet, runtime harness, evidence folder, and handoff docs added. |
| `T12` External playtest follow-up | Deferred | Not part of this implementation pass. |

---

## Done State For This Pass

Stage 10 is implementation-complete when:
- shared audio and actor-visual systems are in place
- town and mine readability cleanup is landed
- debug leakage is removed from normal play behavior
- playtest materials and harness scaffolding are present
- docs describe the repo as it actually exists

That done state is satisfied, with one verification caveat:
- the harness was added but not executed here because Godot CLI was unavailable in the shell session

---

## Follow-up Guardrails

- Run the harness before making speculative polish edits.
- Use outside feedback to drive the next change list.
- Keep `T12` narrow. It should be a fix pass, not a new feature pass.
