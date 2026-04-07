# Remaining Audio To Generate

These are the sounds I still need after checking:
- `kenney_ui-audio`
- `kenney_digital-audio`
- `kenney_sci-fi-sounds`

Those folders already give us good candidates for:
- UI click / hover / back / confirm / cancel
- turn change
- Qtank laser fire and laser impact
- light/heavy hit sounds
- shield trigger
- power-up pickups
- block / armor impact
- generic small explosion support
- light movement placeholders

So this file now contains only the sounds that are still worth generating as custom assets for a more polished result.

## Remaining Files

### `assets/audio/gameplay/move_heavy.wav`
- Use: Ktank movement
- Trigger: when the heavy Ktank finishes moving
- Why still needed:
  The Kenney packs have movement-like sci-fi sounds, but not a really strong short heavy tactical movement cue that feels like a durable armored siege unit.
- Feel: mechanical, weighty, compact, grounded
- Duration: `0.18s` to `0.45s`
- Keywords: `heavy mech step`, `armored weight shift`, `short siege tank movement`, `metal mass reposition`
- Avoid: long engine loops, realistic war tank rumble, huge bass tail
- AI prompt:
  Generate a short heavy tactical movement sound for a durable siege unit. It should feel mechanical, weighty, and grounded, but still short enough for turn-based play. Clean sci-fi style, polished, readable, no long silence.

### `assets/audio/weapons/laser_charge.wav`
- Use: Qtank attack wind-up
- Trigger: just before the laser fires
- Why still needed:
  We have plenty of laser fire sounds, but not a clean dedicated pre-fire charge that gives the Qtank a stronger identity.
- Feel: focused energy build-up, precise, advanced, sharp
- Duration: `0.08s` to `0.22s`
- Keywords: `laser charge`, `energy warm-up`, `focused sci-fi weapon prep`, `short precision charge`
- Avoid: long charge loops, giant cannon charging, noisy distortion
- AI prompt:
  Generate a short precision laser charge sound for a tactical sniper tank. It should feel focused, high-tech, and dangerous, with a quick energy build-up before firing. Clean sci-fi style, polished, readable, no long silence.

### `assets/audio/weapons/blast_charge.wav`
- Use: Ktank attack wind-up
- Trigger: just before the Ktank blast attack
- Why still needed:
  The Kenney packs have blast and explosion material, but not a really distinct heavy pre-detonation priming cue.
- Feel: compact heavy arming pulse, tense, mechanical
- Duration: `0.08s` to `0.24s`
- Keywords: `bomb arm`, `heavy explosive priming`, `short siege charge`, `detonation prep`
- Avoid: alarm sirens, long beeps, futuristic laser feel
- AI prompt:
  Generate a short heavy explosive charge sound for a siege tank attack. It should feel like a compact mechanical blast is being armed, with weight and tension, but stay short and readable for a turn-based tactics game.

### `assets/audio/gameplay/win_player.wav`
- Use: player victory
- Trigger: when the match ends in victory
- Why still needed:
  The Kenney packs have lots of UI tones, but not a dedicated polished victory sting tailored for this game.
- Feel: clean success, confident, tactical, rewarding
- Duration: `0.6s` to `1.5s`
- Keywords: `short sci-fi victory sting`, `clean strategic success`, `polished win cue`
- Avoid: long fanfare, cartoon celebration, arcade jackpot feel
- AI prompt:
  Generate a short victory sting for a clean sci-fi tactics game. It should feel rewarding and confident, but compact and polished rather than dramatic or cartoonish.

### `assets/audio/gameplay/lose_player.wav`
- Use: player defeat
- Trigger: when the match ends in defeat
- Why still needed:
  Existing tones can fake negative UI feedback, but not a proper defeat result cue.
- Feel: restrained downward resolution, calm failure cue
- Duration: `0.5s` to `1.3s`
- Keywords: `short defeat sting`, `tactical loss cue`, `subtle downward sci-fi tone`
- Avoid: horror sounds, comedy fail buzzer, harsh alarms
- AI prompt:
  Generate a short defeat sting for a clean sci-fi tactics game. It should feel like a controlled loss result, with a subtle downward motion and no overly dramatic sadness.

### `assets/audio/gameplay/draw.wav`
- Use: draw outcome
- Trigger: repetition draw or turn-limit draw
- Why still needed:
  This needs a neutral result cue that is clearly not win or loss.
- Feel: balanced, resolved, neutral
- Duration: `0.4s` to `1.1s`
- Keywords: `neutral result cue`, `strategic draw sting`, `balanced end tone`
- Avoid: obvious celebration or obvious defeat mood
- AI prompt:
  Generate a short neutral end-of-match sting for a sci-fi tactics game. It should communicate a draw result, sounding resolved and balanced, not happy and not sad.

### `assets/audio/music/menu_loop.wav`
- Use: main menu background music
- Trigger: menu scene
- Why still needed:
  None of the checked folders include usable music loops.
- Feel: calm tactical sci-fi atmosphere
- Duration: `20s` to `90s`, loop-friendly
- Keywords: `ambient sci-fi strategy menu`, `clean futuristic menu music`, `subtle tactical atmosphere`
- Avoid: vocals, heavy drums, busy lead melodies
- AI prompt:
  Generate a calm loopable menu track for a clean sci-fi tactics game. It should feel futuristic, polished, and subtle, with low distraction and no vocals.

### `assets/audio/music/match_loop.wav`
- Use: gameplay background music
- Trigger: during matches
- Why still needed:
  None of the checked folders include gameplay music.
- Feel: quiet tension, strategic focus, low distraction
- Duration: `30s` to `120s`, loop-friendly
- Keywords: `turn-based tactical ambient`, `subtle sci-fi strategy match music`, `low-intensity board battle atmosphere`
- Avoid: loud action music, huge percussion, heroic bombast
- AI prompt:
  Generate a subtle loopable gameplay track for a clean sci-fi tactical board battle. It should create light strategic tension without distracting from decision-making.

### `assets/audio/music/victory_sting.wav`
- Use: optional stronger win punctuation
- Trigger: match result screen or win moment
- Why still needed:
  This is useful if you want a separate musical win accent in addition to `win_player.wav`.
- Feel: brighter and slightly broader than the base victory sound
- Duration: `0.5s` to `1.4s`
- Keywords: `short victory accent`, `strategic success sting`, `clean sci-fi result flourish`
- Avoid: long anthem, overblown orchestra
- AI prompt:
  Generate a short musical victory sting for a sci-fi tactics game. It should feel polished and uplifting, but brief and restrained enough for a professional strategy title.

### `assets/audio/music/defeat_sting.wav`
- Use: optional stronger defeat punctuation
- Trigger: match result screen or defeat moment
- Why still needed:
  This is useful if you want a separate musical loss accent in addition to `lose_player.wav`.
- Feel: short downward musical cue, restrained and polished
- Duration: `0.5s` to `1.4s`
- Keywords: `short defeat accent`, `clean tactical loss sting`, `restrained sci-fi result cue`
- Avoid: horror mood, melodrama, comedy fail sound
- AI prompt:
  Generate a short musical defeat sting for a sci-fi tactics game. It should feel clean and restrained, with a downward emotional motion but no melodrama.
