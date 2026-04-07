Music — Themes and Generation Prompts
You need 6 pieces for the vertical slice. All prompts are written for Suno or Udio — paste as-is, both handle them well. Gemini's music generation (MusicFX / Lyria) uses shorter prompts so I've included a condensed version for each.

1. Town Theme — Frontier Hamlet
Use: Looping ambient track for the starting town. Should feel lived-in, slightly weary, not triumphant.
Suno/Udio prompt:

Chiptune, 8bit, video game, Medieval fantasy town theme, melancholic folk, acoustic instruments only, lute and soft woodwind lead, slow tempo, 80 BPM, minor key with occasional lift, world-weary but not hopeless, loopable, no percussion except subtle hand drum, no choir, no epic swell, sparse and intimate, reminiscent of early Baldur's Gate ambient music

Gemini/MusicFX prompt:

Slow melancholic medieval folk, lute and flute, minor key, ambient RPG town, no drums


2. Mine/Dungeon Ambient — Into the Dark
Use: Looping tension piece for the mine map. Not full action — unease and dread, not combat.
Suno/Udio prompt:

Chiptune, 8bit, video game, Dark dungeon ambient music, low droning strings, sparse plucked notes, tension without action, no melody just atmosphere, distant echoing percussive hits like dripping water or creaking wood, minor key, very slow tempo, 50–60 BPM, medieval dark fantasy, cave atmosphere, loopable, reminiscent of Diablo 1 dungeon music, no choir, no brass

Gemini/MusicFX prompt:

Dark dungeon atmosphere, low drone, sparse strings, tension, no melody, cave ambience, slow


3. Battle Theme — Blood and Iron
Use: Looping combat track for all regular Kobold encounters. Energetic but not heroic — gritty, urgent.
Suno/Udio prompt:

Chiptune, 8bit, video game, Turn-based RPG battle music, medieval fantasy combat, driving rhythm, urgent but not heroic, minor key, strings and drums lead, 120–130 BPM, short loop 60–90 seconds, gritty and grounded, no electric guitar, no choir, no triumphant brass, reminiscent of classic JRPG battle themes but grittier and more European medieval, tense and focused

Gemini/MusicFX prompt:

Medieval fantasy battle, driving drums and strings, minor key, urgent, 120 BPM, RPG combat loop


4. Boss Theme — The Shaman's Chamber
Use: Boss battle against the Half-Kobold Orc Shaman. Needs weight and moral ambiguity — this is not a villain theme, it's a confrontation theme.
Suno/Udio prompt:

Chiptune, 8bit, video game, RPG boss battle theme, morally ambiguous, heavy and deliberate, not triumphant or villainous, low brass and taiko drums, slow tempo 90–100 BPM, world music influence with African or tribal percussion, building intensity, minor key with unusual harmonic intervals to suggest wrongness or tragedy, no choir, no electric instruments, tension and sadness in equal measure, this is a fight that should not have to happen

Gemini/MusicFX prompt:

RPG boss battle, tribal drums, low brass, slow and heavy, minor key, tragic and intense, world music influence


5. Moral Choice Sting — The Weight
Use: A short piece (15–30 seconds, does not need to loop) that plays when the recruit/fight choice panel appears. It should stop the player in their tracks.
Suno/Udio prompt:

Chiptune, 8bit, video game, Short cinematic sting for a moral choice moment, solo piano, 15–20 seconds, single held chord that resolves ambiguously, neither hopeful nor despairing, just weight and stillness, no percussion, no strings, no build, just a single piano statement, like the game is waiting for you to decide

Gemini/MusicFX prompt:

Solo piano, single chord, 15 seconds, ambiguous, still, no resolution, cinematic moment


6. Victory / Main Theme Seed — The Road Ahead
Use: Plays on the exit cutscene when the core loop completes (Stage 7). Also seeds the main theme you'll develop for production. Should feel earned, not euphoric.
Suno/Udio prompt:

Chiptune, 8bit, video game, Medieval fantasy RPG main theme, bittersweet and earned, orchestral, strings lead with lute countermelody, starts quiet and builds to a restrained swell, minor key that shifts to major at the peak but without full resolution, 90 BPM, cinematic, no electric instruments, no choir until the very final bar if at all, reminiscent of a journey beginning rather than ending, like leaving something behind to face something harder

Gemini/MusicFX prompt:

Bittersweet medieval RPG main theme, strings and lute, minor to major shift, earned and restrained, orchestral build


A few practical notes
Format: Export everything as OGG Vorbis before importing into Godot — it's the native format, smaller than WAV, and Godot handles the looping markers natively. Audacity (free) converts anything in two clicks.
Looping: For the three ambient/battle loops, Suno/Udio sometimes generates a track with a natural loop point and sometimes doesn't. Listen for where it repeats cleanly and trim to that point in Audacity. Aim for loops of 60–90 seconds minimum so the repetition isn't jarring.
Layering the Mine: Consider generating a second, slightly different variant of the Mine Ambient and crossfading between them over time in Godot using AudioStreamPlayer volume tweening — it keeps a 60-second loop feeling fresh for the ~5 minutes a player spends in there.
The Moral Choice Sting is the most important piece. Get that right before the others — it's 20 seconds that carries the entire allegory of the game.