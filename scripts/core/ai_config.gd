class_name AIConfig
extends Resource

var controller_type: int = GameTypes.ControllerType.HUMAN
var time_budget_ms: int = 1000
var search_depth: int = 2
var rollout_limit: int = 250
var debug_enabled: bool = true


func clone() -> AIConfig:
	var duplicate := AIConfig.new()
	duplicate.controller_type = controller_type
	duplicate.time_budget_ms = time_budget_ms
	duplicate.search_depth = search_depth
	duplicate.rollout_limit = rollout_limit
	duplicate.debug_enabled = debug_enabled
	return duplicate
