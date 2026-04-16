Stage 10 SFX inventory

Status:
- Stage 10 runtime SFX are now present in this folder as first-pass placeholder assets.
- These clips were generated locally on 2026-04-15 with Python standard-library audio synthesis and converted in-repo to stable `OGG` runtime files.
- Provenance: repo-local generated assets, no third-party pack import in this pass.
- Format: `OGG` runtime files authored from repo-local generated source material. A later polish pass may replace them with curated sourced assets once auditioned and licensed.

Runtime files:
- `ui_confirm_01.ogg`
  - Use: HUD open/tab confirm, prompt confirm, choice confirm
  - Provenance: repo-local generated placeholder
- `ui_cancel_01.ogg`
  - Use: HUD close, prompt cancel, submenu cancel
  - Provenance: repo-local generated placeholder
- `dialogue_advance_01.ogg`
  - Use: dialogue advance
  - Provenance: repo-local generated placeholder
- `step_town_01.ogg`
  - Use: town and crossroads footstep loop
  - Provenance: repo-local generated placeholder
- `step_mine_01.ogg`
  - Use: mine footstep loop
  - Provenance: repo-local generated placeholder
- `attack_swing_01.ogg`
  - Use: melee swing, shield bash wind-up
  - Provenance: repo-local generated placeholder
- `attack_hit_01.ogg`
  - Use: melee hit, enemy strike impact
  - Provenance: repo-local generated placeholder
- `spell_cast_01.ogg`
  - Use: Flamebolt, Arcane Strike, Shaman magic
  - Provenance: repo-local generated placeholder
- `gate_open_01.ogg`
  - Use: gate/ward open beats in map and cutscene flows
  - Provenance: repo-local generated placeholder
- `loot_pickup_01.ogg`
  - Use: victory / loot panel pickup feedback
  - Provenance: repo-local generated placeholder

Follow-up rules:
- Replace only if the replacement improves readability and provenance remains logged here at import time.
- Keep stable boring runtime names even if sourced files use different original names.
