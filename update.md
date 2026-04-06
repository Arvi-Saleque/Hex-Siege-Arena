# Update Log

## Current Phase

- Phase 4: Map presets and gameplay content

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
- Added data-driven map content support:
  - `MapPreset`
  - `MapLibrary`
- Replaced the hardcoded Phase 2 terrain bootstrap with preset loading from `MatchConfig.map_id`
- Added map metadata on `BoardState`:
  - map id
  - display name
  - description
  - hidden reveal mapping for power blocks
- Added three preset definitions:
  - `standard`
  - `open`
  - `fortress`
- Added Reset support in the match scene so the current configured map can be reloaded quickly during testing
- Improved hit-cell event text so revealed power tiles are visible in the log

## Next Items

- Verify Phase 4 preset loading and reset flow inside Godot
- Start Phase 5:
  - Minimax search core
  - heuristic evaluation
  - move ordering and pruning
  - AI explanation output

## User Check List

- Open the project in Godot 4
- Confirm it imports without parse errors
- Run the project
- Confirm it opens into the menu screen
- Open the match scene from the menu
- Confirm the sidebar now shows the map name and map description
- Confirm the standard map still loads with the expected terrain around the center
- Click `Reset` and confirm the whole match returns to its starting positions and starting terrain
- Destroy the purple power block and confirm the event log shows which power tile was revealed
- Confirm move/attack/pass behavior still works after one or more resets
- Open the settings placeholder scene from the menu and confirm the back button still returns to the menu

## Resources Needed Soon

- No final art or audio needed yet
- For Phase 5, no art is required, but a preferred AI debug wording style would be useful later for the spectator panel
- For future map polish, exact approved layouts for `standard`, `open`, and `fortress` would help replace the current implementation-ready presets

## Known Issues

- Godot CLI is not available in this environment, so editor/runtime verification must be done manually inside Godot
- The match scene is still a debug gameplay scene, not the final polished interface
- AI is not implemented yet, so current gameplay testing is still manual
- The `open` and `fortress` presets are defined for future use, but the current UI still launches the configured default map only
