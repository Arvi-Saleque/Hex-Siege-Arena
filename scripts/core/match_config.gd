class_name MatchConfig
extends Resource

var board_rings: int = 5
var player_one_ai: AIConfig = AIConfig.new()
var player_two_ai: AIConfig = AIConfig.new()
var map_id: String = "standard"
var max_turns: int = 80
var ai_vs_ai_mode: bool = true


func _init() -> void:
	player_one_ai.controller_type = GameTypes.ControllerType.MINIMAX
	player_one_ai.search_depth = 3
	player_one_ai.time_budget_ms = 1500

	player_two_ai.controller_type = GameTypes.ControllerType.MCTS
	player_two_ai.rollout_limit = 500
	player_two_ai.time_budget_ms = 1500


func clone() -> MatchConfig:
	var duplicate := MatchConfig.new()
	duplicate.board_rings = board_rings
	duplicate.player_one_ai = player_one_ai.clone()
	duplicate.player_two_ai = player_two_ai.clone()
	duplicate.map_id = map_id
	duplicate.max_turns = max_turns
	duplicate.ai_vs_ai_mode = ai_vs_ai_mode
	return duplicate
