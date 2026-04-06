# Update Log

## Current Phase

- Phase 2: Hex grid and board foundation

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

## Next Items

- Finish Phase 2 verification feedback from Godot editor
- Start Phase 3:
  - units
  - legal actions
  - attacks
  - buffs
  - one-action economy
  - win and draw rules

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
- Open the settings placeholder scene from the menu
- Confirm the back buttons return to the menu

## Resources Needed Soon

- No final art or audio needed yet
- For Phase 3, no external resources are required
- For Phase 4, it will help to confirm the preferred standard map layout if you want it to match the earlier docs exactly

## Known Issues

- Godot CLI is not available in this environment, so editor/runtime verification must be done manually inside Godot
- The current match scene is still a debug board, not full gameplay
- Tactical rules and unit actions are not implemented yet
