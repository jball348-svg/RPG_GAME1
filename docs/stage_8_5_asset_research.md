# Stage 8.5 Asset Research

## Purpose

This document is the Stage 8.5 asset audit for portraits, map sprites, HUD art, and the simple battle weapon-overlay spike.

It does **not** attempt to catalogue every file in `/assets/art`.
It focuses only on assets that are relevant to the Stage 8.5 implementation plan.

---

## Status legend

| Status | Meaning |
|---|---|
| `approved` | Safe default for implementation. Provenance and license are clear. |
| `needs attribution` | Usable, but credits or other license obligations must be carried forward explicitly. |
| `needs source trace` | The file exists in the repo, but the original source page is not documented yet. Do not treat it as a default until traced. |
| `do not use as default` | The asset may be useful as reference or fallback, but it should not anchor the implementation path. |

---

## Repo inventory relevant to Stage 8.5

| Need | Candidate | Visual fit | Provenance status | Recommendation | Notes |
|---|---|---|---|---|---|
| Fighter map sprite | `assets/art/player/universal-lpc-sprite_male_01_full.png` | Strong | `needs source trace` | Primary repo candidate once traced | Top-down LPC sheet with usable 32x32 body frames. Good fit for current Fighter placeholder. |
| Generic NPC map sprite | `assets/art/player/universal-lpc-sprite_male_01_full.png` | Strong | `needs source trace` | Primary repo candidate once traced | Cheap placeholder path: crop a different frame or recolour/retint a duplicate. |
| Battlemage map sprite | `assets/art/battle/LPC_starhat/sample.png` | Weak | `needs attribution` | `do not use as default` | Not a clean 32x32 top-down map-sprite source. Better as battle/cutscene reference than map avatar source. |
| HUD/UI panels and buttons | `assets/art/UI/kenney_ui-pack-rpg-expansion/` | Strong | `approved` | Default UI source | Repo license file is CC0 and the pack already fits current prototype UI surfaces. |
| Battle weapon overlay | `assets/art/battle/LPC_weapons_pack/` | Medium | `needs attribution` | Fallback only | Could power the overlay spike, but the license burden is heavier than Kenney-style CC0 content. |
| Shaman portrait | No direct portrait asset in repo | None | n/a | External source required | Current repo only has mood board and battle/cutscene placeholders, not a dialogue portrait. |
| Shaman battle/cutscene sprite | `assets/art/battle/goblinsword.png` | Medium | `needs source trace` | Leave as current placeholder unless traced | Already used in current cutscene/battle placeholder flow, but provenance is undocumented. |

---

## Repo license notes already recoverable from disk

### Approved
- **Kenney UI pack RPG expansion**  
  Repo path: `assets/art/UI/kenney_ui-pack-rpg-expansion/`  
  License evidence: `assets/art/UI/kenney_ui-pack-rpg-expansion/license.txt`  
  License: CC0  
  Default use: approved

### Needs attribution / special handling
- **LPC starhat pack**  
  Repo path: `assets/art/battle/LPC_starhat/`  
  Evidence: `assets/art/battle/LPC_starhat/README.txt`  
  Notes: based on a CC-BY 3.0 source  
  Default use: do not use as the default map-sprite path

- **LPC weapons pack**  
  Repo path: `assets/art/battle/LPC_weapons_pack/`  
  Evidence: `assets/art/battle/LPC_weapons_pack/README.txt`  
  Notes: mixed CC-BY-SA / GPL obligations depending on the file  
  Default use: fallback only for Stage 8.5

### Existing repo assets that still need tracing
- `assets/art/player/universal-lpc-sprite_male_01_full.png`
- `assets/art/battle/goblinsword.png`
- any other sprite file without a nearby license/readme source note

Until the source page is recovered, these stay in `needs source trace`.

---

## Primary and fallback recommendations by Stage 8.5 need

| Need | Primary | Status | Fallback | Status | Why |
|---|---|---|---|---|---|
| Fighter map sprite | Repo LPC sheet: `assets/art/player/universal-lpc-sprite_male_01_full.png` | `needs source trace` | [Universal LPC Sprite Generator](https://liberatedpixelcup.github.io/Universal-LPC-Spritesheet-Character-Generator/) | `needs attribution` | The repo sheet already looks right for a 32x32 top-down Fighter, but tracing is required before default use. |
| Generic NPC map sprite | Repo LPC sheet reuse | `needs source trace` | Universal LPC Generator export | `needs attribution` | Fastest placeholder path that still reads as a humanoid NPC at gameplay scale. |
| Battlemage map sprite | Universal LPC Generator export | `needs attribution` | [itch.io top-down fantasy character search](https://itch.io/game-assets/free/tag-characters/tag-fantasy/tag-top-down) | `needs verification` | The repo starhat sample does not fit the locked map-art requirement well enough. |
| Shaman portrait | [Character portrait kit](https://opengameart.org/content/character-portrait-kit) plus [Portrait Frame Pack](https://opengameart.org/content/portrait-frame-pack) if framing helps | `needs attribution` + `approved` frame | [Fantasy Portrait Pack by Ravenmore](https://opengameart.org/content/fantasy-portrait-pack-by-ravenmore) | `needs attribution` | The portrait kit is flexible and fast for a custom named portrait; Ravenmore is a strong grim-fantasy fallback. |
| Weapon overlay | Repo LPC weapons pack | `needs attribution` | Generated neutral-blade placeholder in code/scene | `approved once created in repo` | The spike needs only one visible conditional overlay. If license friction blocks art reuse, generate a simple overlay instead. |
| HUD/UI | Repo Kenney UI pack | `approved` | Different variants from the same Kenney pack | `approved` | Already integrated and license-clean. |

---

## Stage 8.5 implementation choices

The close-out implementation currently uses these concrete assets:

| Need | Chosen asset | Local path | Source note |
|---|---|---|---|
| Fighter animated map sheet | `baldricfrontwalksheet copy.png` | `assets/art/external/stage_8_5/fighter_walk_sheet.png` | From [Four characters: My LPC entries](https://opengameart.org/content/four-characters-my-lpc-entries) on OpenGameArt. |
| Battlemage animated map sheet | `mage walking poses sheet copy.png` | `assets/art/external/stage_8_5/battlemage_walk_sheet.png` | From [Four characters: My LPC entries](https://opengameart.org/content/four-characters-my-lpc-entries) on OpenGameArt. |
| Shaman portrait | `elf_m_256.png` | `assets/art/portraits/stage_8_5/shaman_portrait.png` | From [Fantasy Portrait Pack by Ravenmore](https://opengameart.org/content/fantasy-portrait-pack-by-ravenmore). |
| Generic town NPC sprite | repo LPC crop | `assets/art/player/universal-lpc-sprite_male_01_full.png` | Still a repo reuse; source tracing is still desirable if this remains the long-term default. |

These choices satisfy the Stage 8.5 close-out pass, but the repo LPC NPC crop still carries the original `needs source trace` caveat.

---

## External shortlist

### 1. Universal LPC Sprite Generator
- URL: [https://liberatedpixelcup.github.io/Universal-LPC-Spritesheet-Character-Generator/](https://liberatedpixelcup.github.io/Universal-LPC-Spritesheet-Character-Generator/)
- Best for:
  - Fighter map sprite fallback
  - Battlemage map sprite primary
  - generic NPC sprite fallback
  - future layered equipment experiments
- Reason:
  - It solves the exact Stage 8.5 problem: 32x32 top-down fantasy characters with compatible style and future layering potential.
- License note:
  - The site explicitly says the art is free/libre LPC content and that the authors must be credited.

### 2. LPC attribution project
- URL: [https://opengameart.org/forumtopic/lpc-spritesheetcharacter-generator-attribution-project](https://opengameart.org/forumtopic/lpc-spritesheetcharacter-generator-attribution-project)
- Best for:
  - carrying the attribution burden if LPC-derived assets are used
- Reason:
  - If the implementation chooses LPC-generated exports, this page is the fastest way to avoid losing attribution requirements in later passes.

### 3. Character portrait kit
- URL: [https://opengameart.org/content/character-portrait-kit](https://opengameart.org/content/character-portrait-kit)
- Best for:
  - constructing one quick Shaman portrait without needing a whole portrait pack
- License note:
  - CC-BY 4.0 / CC-BY 3.0 / OGA-BY 3.0
  - Credit required: "Dezra's Dragons" with a link to the creator profile
- Reason:
  - Modular, readable at small portrait sizes, and fast to adapt for one named NPC.

### 4. Portrait Frame Pack
- URL: [https://opengameart.org/content/portrait-frame-pack](https://opengameart.org/content/portrait-frame-pack)
- Best for:
  - optional frame treatment around the Shaman portrait
- License note:
  - CC0
- Reason:
  - Helps the portrait slot feel intentional without pulling the UI away from the current stone/parchment direction.

### 5. Fantasy Portrait Pack by Ravenmore
- URL: [https://opengameart.org/content/fantasy-portrait-pack-by-ravenmore](https://opengameart.org/content/fantasy-portrait-pack-by-ravenmore)
- Best for:
  - grim-fantasy portrait fallback if the modular portrait kit route proves too slow
- License note:
  - CC-BY 3.0
- Reason:
  - Strong fit for the game's tone and a good fallback if a readymade portrait is better than assembling one.

### 6. itch.io free fantasy top-down search
- URL: [https://itch.io/game-assets/free/tag-characters/tag-fantasy/tag-top-down](https://itch.io/game-assets/free/tag-characters/tag-fantasy/tag-top-down)
- Best for:
  - discovering Battlemage and NPC alternatives if LPC attribution or style fit becomes a blocker
- Use it like this:
  - filter for `32x32`
  - prefer `Royalty Free`
  - reject overly bright or cartoon packs

### 7. Admurin profile / freebies
- URL: [https://admurin.itch.io/](https://admurin.itch.io/)
- Best for:
  - battler-style experiments and optional future overlay references
- Caution:
  - The profile page is useful as a discovery surface, but the exact license must be checked on the individual asset page before use.

---

## Explicit deprioritisation

- [Tiny Pixel Fantasy - Character Generator](https://cazwolf.itch.io/tiny-pixel-fantasy-generator)  
  Deprioritise for Stage 8.5 because it is built around 16x16 directional sprites and conflicts with the locked 32x32 map-art pipeline.

---

## Implementation guidance

Use this order during asset-facing implementation:

1. Reuse the repo Kenney UI pack where possible.
2. Trace the origin of the repo LPC player sheet before using it as a default.
3. If tracing fails quickly, switch to a documented Universal LPC Generator export instead of stalling the ticket.
4. Source the Battlemage map sprite externally rather than forcing the current starhat sample into a map-avatar role.
5. For portraits, prefer the fastest route that produces one readable Shaman portrait with explicit attribution notes.
6. If the weapon overlay art is blocked on provenance, use a generated placeholder overlay and keep the spike moving.

---

## Open asset-risk notes

- There is currently no repo-wide credits ledger for art provenance. That is acceptable for the planning pass, but any non-CC0 asset chosen during implementation must carry explicit attribution notes in the docs and later in production-facing credits.
- Some current repo assets are visually strong but provenance-weak. Do not let "already in the repo" override the placeholder-art policy.
- The Battlemage map-sprite slot is the most likely place where external sourcing will be necessary.
