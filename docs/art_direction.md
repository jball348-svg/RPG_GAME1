# Art Direction - RPG_GAME1
> **Locked reference document.** Every visual decision in this project is made against this document. If an asset does not fit these rules, it does not go in the game. No exceptions without updating this document first.

---

## Visual identity - one sentence

A world of moss-covered stone, candlelit halls, fog-heavy forests, and earned darkness - archetypal high fantasy rendered with weight, texture, and grim beauty.

---

## Reference touchstones

These are not games to copy. They are mood anchors - use them to make yes/no asset decisions.

| Reference | What to take from it |
|---|---|
| **Baldur's Gate (original + BG3)** | Rich colour in shadow, environmental storytelling, worn and lived-in world, stone and wood textures, candlelight as primary light source |
| **Lord of the Rings (films)** | The green/white/grey natural world palette, scale of ancient things, fog and mist as atmosphere, cultural visual differentiation between factions |
| **Game of Thrones (series)** | Grounded armour design, political weight in costuming, desaturated realism applied to a fantasy world, nothing feels "clean" or new |
| **Elden Ring** | Environmental darkness that does not obscure, grace in decay, architectural grandeur at human scale, colour used sparingly for maximum impact |

What these four share: desaturated earth tones as the base, colour used for emphasis not decoration, nothing cartoonish, weight and age in every surface, darkness that is atmospheric not punishing.

---

## Tile resolution

**32x32 pixels per tile.** Locked.

- Map scrolls continuously - not screen-shifting. Resolution has no viewport constraint impact.
- 32x32 allows readable armour and equipment differentiation on character sprites - essential for the character personalisation system.
- Character sprites on the map will be one tile (32x32) or 1x2 tiles (32x64) for taller characters.
- Battle and HUD character art is larger - see Character Art section below.

---

## Colour palette - rules

### Tone
Desaturated earth tones as the base. Colour is used sparingly and purposefully - it earns attention by being rare.

### Primary palette (environment, architecture, world)
These are the colours that make up 80% of the visual world:

| Role | Description | Example use |
|---|---|---|
| Stone | Cool grey, slightly blue-green tint | Dungeon walls, castle floors, ruins |
| Moss / earth | Muted olive and brown-green | Outdoor ground, forest floors, aged surfaces |
| Wood | Warm mid-brown, slightly desaturated | Buildings, furniture, bridges, torches |
| Shadow | Near-black with blue or purple undertone - never pure black | Dark corners, cave interiors, night |
| Fog / mist | Off-white, cool grey | Outdoor atmosphere, forest edges, morning scenes |
| Candlelight | Warm amber-orange | Indoor lighting, torches, firelight |
| Sky | Pale grey-blue (overcast) or deep navy (night) | Outdoor scenes, never bright blue |

### Accent palette (characters, UI, important objects)
These colours are used rarely and signal importance:

| Role | Description | Example use |
|---|---|---|
| Pure faction | Muted gold / aged white | Pure knight armour, Pure NPC clothing, Pure stronghold heraldry |
| Mixed faction | Deep teal / copper | Mixed armour, Mixed NPC clothing, Mixed settlement details |
| Magic / Magik | Cool violet-blue, softly glowing | Spell effects, enchanted items, Magik UI elements |
| Holy | Warm white-gold, restrained | Holy class abilities, Faith-aligned items, shrine lighting |
| Danger / blood | Desaturated brick red - never bright red | Battle damage, dark narrative moments, warning UI |
| Loot / reward | Muted amber-gold | Item pickups, treasure, reward notifications |

### Rules
- **No pure black or pure white.** Every dark uses a tinted near-black; every light uses a warm or cool off-white.
- **No saturated primaries.** No bright red, bright blue, or bright green as fills.
- **Maximum about 32 colours in any single tileset or scene.** The constraint enforces cohesion.
- **Pure and Mixed faction colours must be immediately readable at 32x32.** If palette alone cannot distinguish them, the colour design is not doing enough work.

---

## Character art - by context

This is the key locked decision from design: character personalisation is visible in all states **except** the map.

| State | Character art | Personalisation visible? |
|---|---|---|
| Map | Generic class sprite, 32x32 or 32x64, top-down | No - class silhouette only |
| Battle | Larger character art, side-on or 3/4 view, about 64x64 or 96x96 | Yes - armour, weapons, equipment rendered |
| HUD / equipment tab | Portrait or full-body character view | Yes - full equipment loadout visible |
| Cutscene | Full character sprite, animated, equipment visible | Yes - armour and loadout rendered |

### Map sprite
- One sprite sheet per class (Knight, Mage, Rogue, etc.)
- 4-direction walking animation: 3 frames per direction minimum in production; Stage 8.5 may use a single representative frame
- Colour-coded by Pure/Mixed path - Pure characters have a subtle gold accent, Mixed have a subtle teal accent, readable at tile scale
- No equipment differentiation - this is a navigation avatar, not a character render

### Battle character art
- Larger sprites - minimum 64x64, ideally 96x96 for the player character
- Equipment layers rendered separately and composited: base body + armour layer + weapon layer
- This is the system that makes personalisation feel real - a player who equips iron armour looks different to one in leather
- Enemy sprites: 64x64, unique per enemy type, animated with at least idle + attack frames in production

### HUD portrait / full-body
- Static or lightly animated portrait: about 64x64 for the small portrait, larger optional full-body view on the equipment screen
- Equipment slots map visually to the character render - equip a helmet and it appears on the portrait
- Style: detailed for the genre - this is the player's primary relationship with their character's identity

### Cutscene sprites
- Larger than map sprites, treated as presentation sprites
- Equipment and class visually clear
- Class-specific animations for key story moments (mine entrance, boss confrontation, etc.) in production

---

## Tileset rules

- **All tilesets must be 32x32 grid-aligned.** No exceptions.
- **Maximum 2 tilesets per scene type** (for example one outdoor set, one dungeon set for the mine). Mixing more creates visual noise.
- **Autotile-friendly preferred** - tilesets that support Godot 4 terrain workflows reduce manual placement significantly.
- **Consistent light source direction per scene.** Outdoor: light from upper-left. Indoor: light from torch/candle positions. Shadow direction must remain coherent within a scene.
- **No tilesets with built-in outlines.** Outlines on individual tiles create a visible grid. Outlines on characters are fine; outlines on world tiles are not.

---

## UI / HUD art direction

- **Stone and parchment aesthetic.** UI panels feel like aged stone frames or worn parchment - not clean modern rectangles.
- **No gradients.** Flat or subtly textured fills only.
- **Font:** Serif or semi-serif for body text (lore, dialogue, NPC names). Small caps or runic for stat labels and headings. Must be pixel-native or a clean bitmap font - no anti-aliased system fonts.
- **Stat bars:** Simple filled rectangles, stone-framed. Colour-coded by stat family (Physical = warm red-brown, Magik = violet, Social = green, etc.) but desaturated versions of those colours - never bright.
- **Dialogue box:** Bottom third of screen, parchment-toned panel, speaker name in a header tab. Portrait left of text for named NPCs.
- **Pure/Mixed allegiance:** Subtly present in UI chrome - Pure players have a faint gold border detail, Mixed players have a faint teal border detail. Never intrusive, always present.

---

## Placeholder art policy

Stage 8.5 and other prototype passes may use placeholder art from **any free-compatible source**, but only after the asset has been logged in `docs/stage_8_5_asset_research.md`.

Every placeholder asset that becomes part of a default implementation path must record:
- Source page URL
- Creator / pack name
- License name and version
- Attribution requirement, if any
- Intended repo path and in-game use
- Status: `approved`, `needs attribution`, `needs source trace`, or `do not use as default`

Rules:
- **CC0 is preferred, not required.** Non-CC0 assets are allowed only when the license is compatible with the project and the obligations are small enough to manage.
- **Unknown provenance is not acceptable for default use.** An asset can remain in the repo as a reference, but it must be treated as `needs source trace` until the source page is recovered.
- **Attribution and share-alike obligations must be explicit.** If a pack requires credits, source redistribution, or special handling for derivatives, the implementation plan must call that out before the asset is wired into a default path.
- **Do not import new placeholder art blindly.** Log it first, then wire it.

---

## Asset sources - default shortlist

| Source | Best for | Notes |
|---|---|---|
| **Kenney.nl** | UI elements, icons, prototype assets | Strong default. The repo already uses the RPG UI pack and the bundled license is CC0. |
| **OpenGameArt.org** | Character bases, portraits, tilesets, music, SFX | Mixed licenses. Check each asset page and log attribution requirements before use. |
| **itch.io/game-assets** | Fantasy-specific tilesets, top-down character art, battler placeholders | Good discovery surface. Filter for `32x32`, `Royalty Free`, and `Fantasy` during sourcing. |
| **Universal LPC Sprite Generator** | Fighter, Battlemage, NPC map sprites; future layered equipment work | Useful for 32x32 top-down bodies, but requires author attribution. |

### Specific asset targets to evaluate first
When sourcing, evaluate these first before anything else:
- A 32x32 top-down Battlemage map sprite that fits the muted palette and reads clearly against the Fighter placeholder
- One Shaman portrait source that can produce a named dialogue portrait quickly
- One weapon overlay source that can support a simple battle-sprite spike without committing to a full paper-doll pipeline
- Any portrait frame treatment that improves readability without pushing the UI toward cartoon or high-saturation fantasy

---

## Mood board

John will source mood board images and save them to `/assets/art/` in the repo.
File naming convention: `mood_[category]_[descriptor].png`
Examples: `mood_environment_forest.png`, `mood_ui_parchment.png`, `mood_character_knight.png`

Agents working on art should reference these files before sourcing or evaluating any assets.

---

## What this document gates

Do not source, place, or implement any art asset without checking it against this document.

The three visual questions to ask for any asset:
1. Is it 32x32 grid-aligned, or at least directly usable within the locked 32x32 pipeline?
2. Does its palette fit - desaturated earth tones, no bright primaries?
3. Does its style weight match - worn, aged, grim beauty, not cartoon?

The three provenance questions to ask before it becomes default content:
1. Do we know exactly where it came from?
2. Do we know the license and attribution burden?
3. Is that burden written down in `docs/stage_8_5_asset_research.md`?

If all answers are yes: proceed.
If any answer is no: find a different asset or flag it for discussion.
