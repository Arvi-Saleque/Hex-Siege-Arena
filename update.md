# Update Log

## Current Phase

- Phase 5: Minimax AI

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
- Added the first AI module:
  - `MinimaxAI`
  - alpha-beta pruning
  - iterative deepening
  - move ordering
  - heuristic evaluation
  - explanation output
- Added simulation-friendly helpers on `GameState`:
  - `simulate_action`
  - `get_state_hash`
  - current-player AI config lookup
- Added `AI Move` support in the match scene for Minimax-configured turns
- Added AI explanation text in the match sidebar with:
  - summary
  - score
  - depth
  - nodes searched
  - elapsed time
- Updated the main menu copy so the current build phase is no longer stale

## Next Items

- Verify Phase 5 Minimax behavior inside Godot
- Start Phase 6:
  - MCTS search core
  - rollout policy
  - iteration/time controls
  - MCTS explanation output

## User Check List

- Open the project in Godot 4
- Confirm it imports without parse errors
- Run the project
- Confirm it opens into the menu screen
- Confirm the menu subtitle/summary reflects the current prototype phase
- Open the match scene from the menu
- Confirm the sidebar shows:
  - map info
  - controller info
  - AI explanation text
- On Player 1's turn, click `AI Move` and confirm:
  - a legal action is chosen
  - the event log updates
  - the explanation text updates with score/depth/nodes
- Reset the match and try `AI Move` several times to confirm Minimax behaves consistently
- Create an obvious center-rush or obvious attack opportunity and confirm Minimax prefers the strong move
- Confirm the `AI Move` button is disabled on Player 2's turn because P2 is still configured for MCTS
- Confirm manual move/attack/pass still work alongside the new AI button
- Open the settings placeholder scene from the menu and confirm the back button still returns to the menu

## Resources Needed Soon

- No final art or audio needed yet
- For Phase 6, no art is required, but a preferred AI debug wording style would be useful later for the spectator panel
- For future map polish, exact approved layouts for `standard`, `open`, and `fortress` would help replace the current implementation-ready presets

## Known Issues

- Godot CLI is not available in this environment, so editor/runtime verification must be done manually inside Godot
- The match scene is still a debug gameplay scene, not the final polished interface
- Only Minimax is implemented so far; Player 2 remains configured for MCTS until Phase 6
- The `open` and `fortress` presets are defined for future use, but the current UI still launches the configured default map only
