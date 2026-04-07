# Audio Asset Specification

This file defines the sound assets needed for `Hex Siege Arena` so they can be generated consistently with AI tools.

The goal is not just to name files, but to describe:
- what each file is for
- exactly when it plays
- how it should feel
- how long it should be
- what to avoid

Use these notes when generating or sourcing audio so the whole game sounds cohesive.

## Global Audio Direction

The game should sound like:
- clean sci-fi tactics
- readable and responsive
- not noisy or chaotic
- polished rather than cinematic overload

Overall style:
- `Qtank` sounds should feel precise, focused, advanced, and sharp
- `Ktank` sounds should feel heavier, mechanical, blunt, and powerful
- `UI` sounds should be soft, short, and refined
- `Power-up` sounds should feel rewarding and easy to distinguish
- `Victory/defeat` sounds should be short stings, not long dramatic compositions

General rules:
- most UI sounds should be `0.05s` to `0.25s`
- most gameplay action sounds should be `0.15s` to `0.9s`
- music loops should be subtle and not distract from turn-based play
- avoid heavy reverb unless the sound is meant to feel dramatic
- avoid muddy bass that harms clarity
- avoid harsh clipping, distortion, or long tails
- every sound should start quickly with minimal silence

Preferred format:
- `.wav`
- `44.1kHz` or `48kHz`
- mono is fine for most SFX
- stereo is fine for music and bigger weapon effects

## Folder Layout

```text
assets/
  audio/
    ui/
    gameplay/
    weapons/
    powerups/
    music/
```

## UI Sounds

### `assets/audio/ui/ui_click.wav`
- Use: default UI button press
- Trigger: clicking menu buttons, match buttons, toggle buttons
- Feel: soft, crisp, modern digital click
- Duration: `0.05s` to `0.18s`
- Keywords: `soft UI click`, `clean tap`, `minimal digital button`
- Avoid: loud arcade coin sounds, chunky keyboard sounds, cartoon pops

### `assets/audio/ui/ui_back.wav`
- Use: back or return actions
- Trigger: `Back To Menu`, leaving settings, stepping back in UI flow
- Feel: gentle reversed or downward confirmation, subtle retreat cue
- Duration: `0.08s` to `0.22s`
- Keywords: `soft back button`, `descending digital blip`, `subtle retreat tone`
- Avoid: harsh buzzes, error-like sounds

### `assets/audio/ui/ui_hover.wav`
- Use: hover feedback for important buttons or interactive UI
- Trigger: moving over main menu buttons or future important controls
- Feel: very light tick or shimmer
- Duration: `0.03s` to `0.12s`
- Keywords: `tiny UI hover tick`, `light shimmer`, `subtle menu hover`
- Avoid: anything louder than click sounds

### `assets/audio/ui/ui_confirm.wav`
- Use: positive UI confirmation
- Trigger: accepting a setting, starting a match, successful selection
- Feel: slightly brighter and more confident than `ui_click.wav`
- Duration: `0.08s` to `0.22s`
- Keywords: `short confirm chirp`, `clean positive UI tone`
- Avoid: long fanfares

### `assets/audio/ui/ui_cancel.wav`
- Use: canceled selection or unavailable action feedback
- Trigger: cancel button, optional future invalid selection UX
- Feel: quiet muted downward blip
- Duration: `0.06s` to `0.18s`
- Keywords: `soft cancel blip`, `gentle negative UI tone`
- Avoid: aggressive error alarms

## Gameplay Sounds

### `assets/audio/gameplay/turn_change.wav`
- Use: turn handoff feedback
- Trigger: whenever the active player changes
- Feel: short neutral tactical pulse, not celebratory
- Duration: `0.12s` to `0.3s`
- Keywords: `turn start pulse`, `clean tactical transition`, `light command tone`
- Avoid: huge sweeps, long chimes

### `assets/audio/gameplay/move_light.wav`
- Use: Qtank movement
- Trigger: when a `Qtank` completes a move
- Feel: light hover-skid or agile mech slide, precise and fast
- Duration: `0.12s` to `0.35s`
- Keywords: `light sci-fi glide`, `small mech reposition`, `clean tactical movement`
- Avoid: heavy tank tread rumble, large explosions
- AI generation note:
  Generate a short clean sci-fi movement sound for a light tactical unit. It should feel quick, precise, and agile, like a hovering sniper platform repositioning on a hex board.

### `assets/audio/gameplay/move_heavy.wav`
- Use: Ktank movement
- Trigger: when a `Ktank` completes a move
- Feel: heavier armored movement, short servo-thump or metal weight shift
- Duration: `0.18s` to `0.45s`
- Keywords: `heavy mech step`, `armored weight shift`, `short tank reposition`
- Avoid: long real-world tank engine loops
- AI generation note:
  Generate a short heavy tactical movement sound for a durable siege unit. It should feel mechanical, weighty, and grounded, but still short enough for turn-based play.

### `assets/audio/gameplay/hit_light.wav`
- Use: lighter hit confirmation
- Trigger: low-intensity tank impact, especially cleaner laser contact
- Feel: tight metallic or energy hit tick
- Duration: `0.06s` to `0.2s`
- Keywords: `light impact`, `energy hit`, `clean tactical damage cue`
- Avoid: giant explosion tails

### `assets/audio/gameplay/hit_heavy.wav`
- Use: stronger impact confirmation
- Trigger: big hits, especially Ktank blast impact or more dramatic damage moments
- Feel: heavier thud with sharp attack
- Duration: `0.12s` to `0.32s`
- Keywords: `heavy impact`, `armored strike`, `short blast hit`
- Avoid: long cinematic booms

### `assets/audio/gameplay/tank_destroyed.wav`
- Use: unit destruction
- Trigger: when either tank dies
- Feel: short but satisfying destruction burst with debris/energy collapse feel
- Duration: `0.35s` to `0.9s`
- Keywords: `small mech destruction`, `robot explosion`, `compact unit death`
- Avoid: giant battlefield nuke sound
- AI generation note:
  Generate a short tactical unit destruction sound. It should feel impactful and final, with a compact explosion and mechanical breakup, but not as large as a building collapse.

### `assets/audio/gameplay/block_destroyed.wav`
- Use: destructible normal block destroyed
- Trigger: when a standard block breaks
- Feel: small debris crack, stone/metal shard break depending on art direction
- Duration: `0.15s` to `0.35s`
- Keywords: `small obstacle break`, `tactical cover destroyed`, `compact debris`
- Avoid: overpowered explosion

### `assets/audio/gameplay/armor_block_hit.wav`
- Use: armored block being hit but not necessarily destroyed
- Trigger: damage on armor blocks
- Feel: denser metallic impact with resistance
- Duration: `0.08s` to `0.25s`
- Keywords: `armored impact`, `metal shielded hit`, `reinforced obstacle strike`
- Avoid: glass-like sounds

### `assets/audio/gameplay/win_player.wav`
- Use: player victory
- Trigger: match win screen or immediate win event
- Feel: short satisfying victory sting, confident and clean
- Duration: `0.6s` to `1.8s`
- Keywords: `short sci-fi victory sting`, `clean success theme`, `strategic win cue`
- Avoid: long orchestral anthem

### `assets/audio/gameplay/lose_player.wav`
- Use: player defeat
- Trigger: defeat state
- Feel: restrained downward sting, not depressing or overly dramatic
- Duration: `0.5s` to `1.5s`
- Keywords: `short defeat sting`, `subtle tactical loss cue`
- Avoid: horror tones, comedy sounds

### `assets/audio/gameplay/draw.wav`
- Use: draw outcome
- Trigger: repetition draw or turn-limit draw
- Feel: neutral resolved ending tone, neither win nor loss
- Duration: `0.4s` to `1.2s`
- Keywords: `neutral match result`, `balanced end cue`, `tactical draw sting`
- Avoid: strong emotional direction

### `assets/audio/gameplay/extra_action.wav`
- Use: bonus move granted
- Trigger: player gets an extra action from `Bonus Move`
- Feel: energetic but short reward pulse
- Duration: `0.1s` to `0.28s`
- Keywords: `extra turn cue`, `bonus action reward`, `quick positive pulse`
- Avoid: sounds that resemble victory stings

## Weapon Sounds

### `assets/audio/weapons/laser_charge.wav`
- Use: Qtank attack wind-up
- Trigger: immediately before or at the start of laser fire
- Feel: quick energy build-up, focused and high-tech
- Duration: `0.08s` to `0.25s`
- Keywords: `short laser charge`, `energy build`, `sci-fi weapon warm-up`
- Avoid: long charging loops

### `assets/audio/weapons/laser_fire.wav`
- Use: Qtank main firing sound
- Trigger: when Qtank performs its laser attack
- Feel: sharp, precise, high-energy beam discharge
- Duration: `0.12s` to `0.35s`
- Keywords: `precise sci-fi laser`, `clean beam shot`, `sniper energy blast`
- Avoid: blaster spam, cartoony pew-pew
- AI generation note:
  Generate a short precision laser firing sound for a tactical sniper tank. It should feel clean, advanced, and dangerous, with a fast energy discharge and no comedic tone.

### `assets/audio/weapons/laser_hit_tank.wav`
- Use: laser striking a tank
- Trigger: Qtank beam hits a unit
- Feel: hot energy impact with armored contact
- Duration: `0.08s` to `0.22s`
- Keywords: `energy armor hit`, `laser impact on mech`, `sharp tech hit`
- Avoid: explosion-heavy sounds

### `assets/audio/weapons/laser_hit_wall.wav`
- Use: laser striking wall/block
- Trigger: Qtank beam stops on terrain
- Feel: sparking ricochet or energized obstacle hit
- Duration: `0.08s` to `0.22s`
- Keywords: `laser impact on wall`, `energy ricochet`, `heated metal strike`
- Avoid: fleshy impact sounds

### `assets/audio/weapons/blast_charge.wav`
- Use: Ktank attack wind-up
- Trigger: just before blast detonation
- Feel: short heavy priming cue
- Duration: `0.08s` to `0.25s`
- Keywords: `bomb arm sound`, `heavy charge pulse`, `short detonation prep`
- Avoid: long alarm beeps

### `assets/audio/weapons/blast_fire.wav`
- Use: Ktank main attack trigger
- Trigger: when Ktank launches or triggers its blast
- Feel: compact explosive release with weight
- Duration: `0.15s` to `0.4s`
- Keywords: `compact explosive blast`, `short siege cannon`, `heavy tactical explosion`
- Avoid: giant cinematic missile launch
- AI generation note:
  Generate a short heavy explosive attack sound for a siege tank. It should feel weighty and forceful, like a compact tactical blast on a small arena board.

### `assets/audio/weapons/blast_hit.wav`
- Use: blast impact detail layer
- Trigger: when Ktank blast damages tanks or blocks
- Feel: chunky impact layer that supports `blast_fire.wav`
- Duration: `0.12s` to `0.3s`
- Keywords: `explosive impact`, `armored blast hit`, `close-range detonation hit`
- Avoid: overly long booms

### `assets/audio/weapons/explosion_small.wav`
- Use: generic small explosion support
- Trigger: block destruction, clustered blast feedback, optional destruction layering
- Feel: compact arena-safe explosion
- Duration: `0.18s` to `0.5s`
- Keywords: `small tactical explosion`, `compact arena blast`
- Avoid: massive warzone explosions

## Power-Up Sounds

### `assets/audio/powerups/pickup_attack.wav`
- Use: attack buff pickup
- Trigger: collecting red attack power tile
- Feel: assertive upward power pulse
- Duration: `0.1s` to `0.25s`
- Keywords: `attack boost pickup`, `power gain`, `red buff reward`
- Avoid: shield-like soft tones

### `assets/audio/powerups/pickup_shield.wav`
- Use: shield buff pickup
- Trigger: collecting blue shield tile
- Feel: glossy protective shimmer
- Duration: `0.12s` to `0.28s`
- Keywords: `shield pickup`, `protective energy shimmer`, `defense buff cue`
- Avoid: explosive or aggressive tones

### `assets/audio/powerups/pickup_bonus_move.wav`
- Use: bonus move pickup
- Trigger: collecting green extra-action tile
- Feel: bright quick reward with motion/tempo feel
- Duration: `0.1s` to `0.25s`
- Keywords: `bonus move pickup`, `extra action reward`, `quick energetic buff cue`
- Avoid: identical feel to attack buff

### `assets/audio/powerups/shield_trigger.wav`
- Use: shield actually absorbing damage
- Trigger: when a shielded tank takes a hit and the shield buffer matters
- Feel: defensive energy block or impact absorb
- Duration: `0.08s` to `0.22s`
- Keywords: `shield absorb`, `energy barrier hit`, `protective impact`
- Avoid: raw damage sounds without the shield feel

## Music

### `assets/audio/music/menu_loop.wav`
- Use: main menu background music
- Trigger: main menu scene
- Feel: calm tactical sci-fi atmosphere
- Duration: `20s` to `90s` loopable
- Keywords: `ambient sci-fi strategy menu`, `clean futuristic tactical menu`
- Avoid: loud drums, vocals, busy melodies

### `assets/audio/music/match_loop.wav`
- Use: match background music
- Trigger: gameplay scene
- Feel: subtle strategic tension, low distraction
- Duration: `30s` to `120s` loopable
- Keywords: `turn-based tactical ambient`, `low-intensity strategy soundtrack`, `clean sci-fi board battle`
- Avoid: overpowering combat music

### `assets/audio/music/victory_sting.wav`
- Use: stronger win punctuation
- Trigger: end-of-match victory if a separate sting is desired from `win_player.wav`
- Feel: short clean success burst
- Duration: `0.5s` to `1.5s`
- Keywords: `short victory sting`, `strategic success fanfare`
- Avoid: long anthem

### `assets/audio/music/defeat_sting.wav`
- Use: stronger defeat punctuation
- Trigger: end-of-match defeat if a separate sting is desired from `lose_player.wav`
- Feel: short downward resolved tone
- Duration: `0.5s` to `1.5s`
- Keywords: `short defeat sting`, `tactical failure cue`
- Avoid: horror mood or excessive sadness

## Minimum Phase 12 Starter Set

If you want to generate only the most important sounds first, start with these:

- `assets/audio/ui/ui_click.wav`
- `assets/audio/gameplay/turn_change.wav`
- `assets/audio/gameplay/move_light.wav`
- `assets/audio/gameplay/move_heavy.wav`
- `assets/audio/weapons/laser_fire.wav`
- `assets/audio/weapons/laser_hit_tank.wav`
- `assets/audio/weapons/blast_fire.wav`
- `assets/audio/weapons/blast_hit.wav`
- `assets/audio/gameplay/hit_light.wav`
- `assets/audio/gameplay/tank_destroyed.wav`
- `assets/audio/powerups/pickup_attack.wav`
- `assets/audio/powerups/pickup_shield.wav`
- `assets/audio/powerups/pickup_bonus_move.wav`
- `assets/audio/gameplay/win_player.wav`
- `assets/audio/gameplay/draw.wav`

## AI Prompt Pattern

Use this simple structure when generating a sound:

```text
Generate a [duration] sound effect for [exact gameplay purpose].
Style: clean sci-fi tactical game, polished, readable, not cartoonish.
Emotion: [precise / heavy / rewarding / defensive / neutral].
Sound character: [keywords].
Avoid: [keywords].
Must start quickly with no long silence and fit a turn-based strategy game UI/UX.
```

Example:

```text
Generate a 0.2 second sound effect for a light unit moving on a hex-grid tactics board.
Style: clean sci-fi tactical game, polished, readable, not cartoonish.
Emotion: precise and agile.
Sound character: soft hover-skid, light mech reposition, futuristic movement cue.
Avoid: heavy tank rumble, long tails, loud bass, comedy sounds.
Must start quickly with no long silence and fit a turn-based strategy game UI/UX.
```
