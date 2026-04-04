# Stat Registry — V1.0

## Top-level stats

| Stat | Skills | Notes |
|---|---|---|
| Physical | Strength, Endurance, Movement | Increases through combat, walking, physical activity |
| Magik | Spellcasting, Attunement, Mana | Mana starts at 50. Increases through casting, reading, meditation |
| Intelligence | Understanding, Tactics, Persuasion | Increases through dialogue, reading, puzzle solving |
| Social | Charm, Reputation, Empathy, Luck | Luck is derived — not directly trained |
| Will | Resolve, Focus, Resistance | Increases through hardship, resisting debuffs, long journeys |
| Holy | Faith, Intuition, Peace, Justice | Increases through moral choices, prayer, class-aligned acts |

## Luck — design note
Luck sits under Social but is not directly trained. It is derived from the average of Charm + Reputation + Empathy. Players with high social stats feel luckier. Isolated characters feel unlucky. This is intentional and mirrors real-world psychology.

## Visibility tiers
- **Tier 1 (always visible):** Age, core health, mana, walking speed, top-level stat scores
- **Tier 2 (unlocked at milestone):** Individual skills — revealed when a threshold is first crossed
- **Tier 3 (ghost — never shown):** Luck (partially), momentum, world favour, NPC disposition drift

## Pure / Mix allegiance
Not a stat. A flag + reputation score per faction. Lives in PlayerData.gd. Affects NPC dialogue, shop access, quest availability, and ghost layer behaviour — not the skill numbers directly.

## Open registry principle
Skills within each stat are a starting set, not a final list. New skills can be added during production as actions demand them. No redesign of the architecture needed — just add a key to the stats Dictionary in StatRegistry.gd and add entries to action_modifiers.
