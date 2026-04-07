extends Node

const DEFAULT_MATCH_SCENE := "res://scenes/match/match_root.tscn"
const DEFAULT_MENU_SCENE := "res://scenes/menu/main_menu.tscn"
const DEFAULT_SETTINGS_SCENE := "res://scenes/settings/settings_root.tscn"

var project_phase: int = 11
var build_label: String = "phase11-combat-vfx-and-feedback"
var current_match_config: MatchConfig = MatchConfig.new()
var current_replay: ReplayRecord = ReplayRecord.new()
var last_action_explanation: ActionExplanation = ActionExplanation.new()


func reset_runtime_state() -> void:
	current_match_config = MatchConfig.new()
	current_replay = ReplayRecord.new()
	last_action_explanation = ActionExplanation.new()
