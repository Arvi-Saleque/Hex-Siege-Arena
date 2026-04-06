# Update Log

## Current Phase

- Phase 3: Rules engine and turn economy

## Completed Items

- Created the initial Godot 4 project skeleton
- Added root scene flow:
  - Boot
  - Main Menu
  - Match placeholder
  - Settings placeholder
- Added autoload foundation:
  - `AppState`
  - `EventBus`
- Added core data classes:
  - `HexCoord`
  - `CellData`
  - `BoardState`
  - `TankData`
  - `ActionData`
  - `GameEvent`
  - `MatchConfig`
  - `AIConfig`
  - `ActionExplanation`
  - `ReplayRecord`
- Added shared enum container `GameTypes`
- Added a simple UI-driven placeholder flow so the project is easy to open and inspect in Godot
- Expanded `HexCoord` with:
  - flat-topped world conversion
  - world-to-hex conversion
  - raycast
  - board coordinate generation
- Expanded `BoardState` with:
  - empty board generation
  - terrain mutation helpers
  - Phase 2 debug terrain
- Added clickable board debug rendering inside the match scene
- Added hover and selected tile summaries in the match sidebar
- Added `GameState` as the first headless gameplay simulation layer
- Added default unit setup:
  - P1 Qtank
  - P1 Ktank
  - P2 Qtank
  - P2 Ktank
- Added movement and attack rules for Qtank and Ktank
- Added buff handling:
  - attack multiplier
  - shield buffer
  - bonus move
- Added turn logic:
  - one action per turn
  - pass action
  - bonus extra action
- Added win and draw protection:
  - instant center win
  - Ktank destruction win
  - turn cap
  - repetition tracking
- Upgraded the match scene into a manual gameplay test scene with:
  - tank rendering
  - current player state
  - selected tank info
  - Move / Attack / Pass buttons
  - action highlights
  - event log

## Next Items

- Finish Phase 3 verification feedback from Godot editor
- Start Phase 4:
  - standard map preset
  - content-driven map setup
  - power block reveal behavior
  - map metadata for later UI and AI use

## User Check List

- Open the project in Godot 4
- Confirm it imports without parse errors
- Run the project
- Confirm it opens into the menu screen
- Open the match placeholder scene from the menu
- Confirm the hex board appears in the match scene
- Move the mouse across the board and confirm hover text changes
- Click several tiles and confirm the selected tile summary updates
- Confirm the different placeholder terrain colors appear
- Click a blue tank on Player 1's turn and confirm it becomes the selected tank
- Press `Move` and confirm legal move targets turn green
- Move a tank and confirm:
  - the turn changes
  - the event log updates
- Select a tank and press `Attack` and confirm:
  - attack targets turn red
  - Qtank fires in a straight line
  - Ktank hits adjacent cells
- Move onto a power tile and confirm the event log reports the pickup
- Confirm `Pass` ends the turn
- Confirm center capture by Ktank ends the match immediately
- Open the settings placeholder scene from the menu
- Confirm the back buttons return to the menu

## Resources Needed Soon

- No final art or audio needed yet
- For Phase 4, it will help to confirm the preferred standard map layout if you want it to match the earlier docs exactly
- For Phase 5, no art is required, but a preferred AI debug wording style would be useful later for the spectator panel

## Known Issues

- Godot CLI is not available in this environment, so editor/runtime verification must be done manually inside Godot
- The match scene is still a debug gameplay scene, not the final polished interface
- AI is not implemented yet, so Phase 3 is manual testing only
- Power blocks currently reveal a placeholder attack power when destroyed; Phase 4 will refine this into map/content-driven behavior
