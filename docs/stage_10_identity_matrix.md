# Stage 10 Identity Matrix

This document is the written mirror of `autoloads/ActorVisuals.gd`.

Goal:
- every critical actor has one explicit source-of-truth presentation mapping
- map, battle, portrait, cutscene, and follower states should read as the same character
- tint/accent is a support signal, not the only identity signal

---

## Actor Registry

| Actor id | Map | Battle | HUD / dialogue portrait | Cutscene | Follower | Accent / tint note |
|---|---|---|---|---|---|---|
| `player_fighter` | `fighter_walk_sheet.png` directional frames | fighter sheet idle combat frame | `fighter_presentation_card.png` | fighter sheet directional idle frame | n/a | path tint still communicates Pure / Mixed state on map |
| `player_battlemage` | `battlemage_walk_sheet.png` directional frames | battlemage sheet idle combat frame | `battlemage_presentation_card.png` | battlemage sheet directional idle frame | n/a | path tint still communicates Pure / Mixed state on map |
| `shaman` | cropped `goblinsword.png` figure | cropped `goblinsword.png` figure | cropped `goblinsword.png` figure | cropped `goblinsword.png` figure | single-frame directional set built from the same crop | green accent comes from the source art, not a battlemage recolor fallback |
| `village_guard` | fighter sheet down-frame | n/a | fighter sheet down-frame | fighter sheet directional frame | n/a | cool blue modulate to support guard readability |
| `traveling_merchant` | battlemage sheet down-frame | n/a | battlemage sheet down-frame | n/a | n/a | warm sand modulate to support merchant readability |
| `bookstore_keeper` | LPC atlas crop | n/a | LPC atlas crop | n/a | n/a | soft green modulate to support bookstore readability |
| `kobold` | n/a | cropped kobold combat sprite | `kobold_presentation_card.png` | n/a | n/a | red-brown combat accent |

---

## Identity Rules

### Player

- Fighter and Battlemage each stay inside one source family across map, battle, HUD, and cutscene.
- Path tint is allowed to affect the map actor, but it should not change which actor the player appears to be.
- HUD portrait choice should always match the current player class resolved by `PlayerData.resolve_vertical_slice_class_id()`.

### Shaman

- The Shaman now uses one visual family across boss, dialogue, cutscene, and follower states.
- The old green-tinted battlemage follower fallback is no longer the source of truth.
- If the Shaman gets a future portrait upgrade, it should still preserve the same silhouette and palette cues established here.

### Town story NPCs

- Guard, merchant, and bookstore keeper must remain distinguishable by silhouette or crop before tint.
- Tint supports recognition, but no story NPC should rely on tint alone to be legible.

---

## Runtime Consumers

Current Stage 10 consumers of this matrix:
- `scenes/map/Map.gd`
- `scenes/battle/Battle.gd`
- `scenes/hud/HUD.gd`
- `scenes/ui/DialogueBox.gd`
- `scenes/cutscene/Cutscene.gd`
- `scenes/npc/ShamanFollower.gd`

If one of those scenes changes its actor lookups, update both:
- `autoloads/ActorVisuals.gd`
- this document
