# Stage 10 Playtest Packet

This packet is now an archived Stage 10 verification artifact.
It was created for the slice closeout pass and is retained as the reference checklist for how Stage 10 was evaluated.

If the next-phase cloned repo wants fresh user testing, adapt this packet there rather than treating it as pending work in `RPG_GAME1`.

---

## Playtest Brief

Ask the playtester to:
- start the game fresh or from a clean Stage 10 save
- play naturally without debug controls or developer commentary
- complete the slice from town start through mine exit and arrival at the crossroads
- call out any moment that feels confusing, unfair, visually inconsistent, or too quiet / too noisy

What we want to learn:
- can someone complete the loop without guidance
- do collision and blockers feel fair
- do the major characters read clearly across map, battle, dialogue, cutscene, and follower states
- does the audio coverage support the beats without becoming distracting
- does anything still feel obviously “debuggy” or placeholder in a way that breaks trust

---

## Controls

- `WASD` or arrow keys: move
- `E` / `Space`: interact, confirm, advance dialogue
- `H`: open / close HUD

Do not brief the playtester on debug controls.

---

## Observation Checklist

- Town start
  - player understands movement and interaction without coaching
  - guard, merchant, and bookstore keeper are readable as distinct NPCs
  - bookstore approach and town roads feel fair to navigate
- Town exit
  - point-of-no-return prompt is clear
  - town-to-mine transition lands cleanly
- Mine entry and exploration
  - mine music and footsteps feel appropriate
  - west branch, east branch, top shaft, boss gate, and exit gate read clearly
  - player can tell why a blocked route is blocked
- Battles
  - fighter and battlemage presentations feel coherent with their map/HUD identities
  - UI confirm/cancel, hit, swing, and spell cues read clearly
- Shaman sequence
  - intro and choice feel emotionally distinct
  - Shaman reads as the same character across cutscene, dialogue, battle, and follower contexts
- Mine exit
  - victory/exit cue lands
  - recruit and non-recruit variants both read cleanly
- Crossroads
  - follower presence and spacing feel intentional
  - no debug overlay/help text leaks into normal play

---

## Issue Log Template

Copy this block for each issue:

```text
Title:
Severity: blocker / major / minor / cosmetic
Area: town / mine / battle / cutscene / hud / audio / release-behavior
Location or step:
What the player expected:
What actually happened:
Repro steps:
Screenshot or clip:
Notes:
```

---

## Handoff Notes

- Runtime harness entry point: `tools/stage_10_runtime_harness.tscn`
- Expected evidence output directory: `tools/evidence/stage_10/`
- If this packet is reused in the future, keep any manual evidence filenames close to the harness naming pattern
