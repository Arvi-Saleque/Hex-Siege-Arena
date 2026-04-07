extends Node

const DEFAULT_MATCH_SCENE := "res://scenes/match/match_root.tscn"
const DEFAULT_MENU_SCENE := "res://scenes/menu/main_menu.tscn"
const DEFAULT_REPLAY_SCENE := "res://scenes/replay/replay_shell.tscn"
const DEFAULT_SETTINGS_SCENE := "res://scenes/settings/settings_root.tscn"

var project_phase: int = 14
var build_label: String = "phase14-replay-analytics-and-post-match"
var current_match_config: MatchConfig = MatchConfig.new()
var current_replay: ReplayRecord = ReplayRecord.new()
var last_action_explanation: ActionExplanation = ActionExplanation.new()


func reset_runtime_state() -> void:
	current_match_config = MatchConfig.new()
	current_replay = ReplayRecord.new()
	last_action_explanation = ActionExplanation.new()
