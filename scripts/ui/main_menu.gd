extends Control

const MATCH_SCENE := "res://scenes/match/match_root.tscn"
const REPLAY_SCENE := "res://scenes/replay/replay_shell.tscn"
const SETTINGS_SCENE := "res://scenes/settings/settings_root.tscn"

var _p1_controller: OptionButton
var _p2_controller: OptionButton
var _map_select: OptionButton
var _max_turns_spin: SpinBox
var _p1_depth_spin: SpinBox
var _p2_rollout_spin: SpinBox
var _replay_button: Button
var _summary_label: RichTextLabel


func _ready() -> void:
	AudioManager.play_menu_music()
	_build_layout()
	_refresh_summary()


func _build_layout() -> void:
	var background := ColorRect.new()
	background.color = Color("10141c")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root_margin := MarginContainer.new()
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 24)
	root_margin.add_theme_constant_override("margin_top", 24)
	root_margin.add_theme_constant_override("margin_right", 24)
	root_margin.add_theme_constant_override("margin_bottom", 24)
	add_child(root_margin)

	var layout := HBoxContainer.new()
	layout.add_theme_constant_override("separation", 20)
	root_margin.add_child(layout)

	var hero_panel := PanelContainer.new()
	hero_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(hero_panel)

	var hero_margin := MarginContainer.new()
	hero_margin.add_theme_constant_override("margin_left", 28)
	hero_margin.add_theme_constant_override("margin_top", 28)
	hero_margin.add_theme_constant_override("margin_right", 28)
	hero_margin.add_theme_constant_override("margin_bottom", 28)
	hero_panel.add_child(hero_margin)

	var hero_layout := VBoxContainer.new()
	hero_layout.add_theme_constant_override("separation", 18)
	hero_margin.add_child(hero_layout)

	var title := Label.new()
	title.text = "Hex Siege Arena"
	title.add_theme_font_size_override("font_size", 40)
	hero_layout.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Phase %d prototype build" % AppState.project_phase
	subtitle.modulate = Color(0.74, 0.82, 0.92, 1.0)
	hero_layout.add_child(subtitle)

	_summary_label = RichTextLabel.new()
	_summary_label.bbcode_enabled = true
	_summary_label.fit_content = true
	_summary_label.scroll_active = false
	hero_layout.add_child(_summary_label)

	var setup_title := Label.new()
	setup_title.text = "Match Setup"
	setup_title.add_theme_font_size_override("font_size", 24)
	hero_layout.add_child(setup_title)

	var setup_grid := GridContainer.new()
	setup_grid.columns = 2
	setup_grid.add_theme_constant_override("h_separation", 12)
	setup_grid.add_theme_constant_override("v_separation", 10)
	hero_layout.add_child(setup_grid)

	setup_grid.add_child(_field_label("Player 1"))
	_p1_controller = _controller_option()
	setup_grid.add_child(_p1_controller)

	setup_grid.add_child(_field_label("Player 2"))
	_p2_controller = _controller_option()
	setup_grid.add_child(_p2_controller)

	setup_grid.add_child(_field_label("Map"))
	_map_select = OptionButton.new()
	for map_id: String in ["standard", "open", "fortress", "labyrinth"]:
		_map_select.add_item(map_id.capitalize())
		_map_select.set_item_metadata(_map_select.item_count - 1, map_id)
	_map_select.item_selected.connect(_on_setup_changed)
	setup_grid.add_child(_map_select)

	setup_grid.add_child(_field_label("Max Turns"))
	_max_turns_spin = SpinBox.new()
	_max_turns_spin.min_value = 20
	_max_turns_spin.max_value = 200
	_max_turns_spin.step = 5
	_max_turns_spin.value_changed.connect(_on_setup_changed)
	setup_grid.add_child(_max_turns_spin)

	setup_grid.add_child(_field_label("Minimax Depth"))
	_p1_depth_spin = SpinBox.new()
	_p1_depth_spin.min_value = 1
	_p1_depth_spin.max_value = 6
	_p1_depth_spin.step = 1
	_p1_depth_spin.value_changed.connect(_on_setup_changed)
	setup_grid.add_child(_p1_depth_spin)

	setup_grid.add_child(_field_label("MCTS Rollouts"))
	_p2_rollout_spin = SpinBox.new()
	_p2_rollout_spin.min_value = 50
	_p2_rollout_spin.max_value = 2000
	_p2_rollout_spin.step = 50
	_p2_rollout_spin.value_changed.connect(_on_setup_changed)
	setup_grid.add_child(_p2_rollout_spin)

	var button_column := VBoxContainer.new()
	button_column.add_theme_constant_override("separation", 12)
	hero_layout.add_child(button_column)

	button_column.add_child(_make_button("Start Configured Match", _on_open_match_pressed))

	_replay_button = _make_button("Open Replay Viewer", _on_open_replay_pressed)
	button_column.add_child(_replay_button)

	button_column.add_child(_make_button("Open Settings", _on_open_settings_pressed))
	button_column.add_child(_make_button("Reset Runtime State", _on_reset_state_pressed))

	var side_panel := PanelContainer.new()
	side_panel.custom_minimum_size = Vector2(360, 0)
	layout.add_child(side_panel)

	var side_margin := MarginContainer.new()
	side_margin.add_theme_constant_override("margin_left", 24)
	side_margin.add_theme_constant_override("margin_top", 24)
	side_margin.add_theme_constant_override("margin_right", 24)
	side_margin.add_theme_constant_override("margin_bottom", 24)
	side_panel.add_child(side_margin)

	var side_layout := VBoxContainer.new()
	side_layout.add_theme_constant_override("separation", 14)
	side_margin.add_child(side_layout)

	var side_title := Label.new()
	side_title.text = "Shell Notes"
	side_title.add_theme_font_size_override("font_size", 24)
	side_layout.add_child(side_title)

	var notes := Label.new()
	notes.text = "This phase adds a proper outer shell around the arena prototype:\n\n- match setup before entering the board\n- replay browser shell backed by recorded turns\n- settings with live audio sliders\n- cleaner launch flow for testing different AI combinations"
	notes.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side_layout.add_child(notes)

	_apply_config_to_controls()


func _field_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	return label


func _controller_option() -> OptionButton:
	var option := OptionButton.new()
	option.add_item("Human")
	option.set_item_metadata(0, GameTypes.ControllerType.HUMAN)
	option.add_item("Minimax")
	option.set_item_metadata(1, GameTypes.ControllerType.MINIMAX)
	option.add_item("MCTS")
	option.set_item_metadata(2, GameTypes.ControllerType.MCTS)
	option.item_selected.connect(_on_setup_changed)
	return option


func _make_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(280, 52)
	button.mouse_entered.connect(AudioManager.play_ui_hover)
	button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		callback.call()
	)
	return button


func _apply_config_to_controls() -> void:
	var config: MatchConfig = AppState.current_match_config
	_select_controller(_p1_controller, config.player_one_ai.controller_type)
	_select_controller(_p2_controller, config.player_two_ai.controller_type)
	_select_map(config.map_id)
	_max_turns_spin.value = config.max_turns
	_p1_depth_spin.value = config.player_one_ai.search_depth
	_p2_rollout_spin.value = config.player_two_ai.rollout_limit


func _select_controller(option: OptionButton, controller_type: int) -> void:
	for index in range(option.item_count):
		if int(option.get_item_metadata(index)) == controller_type:
			option.select(index)
			return


func _select_map(map_id: String) -> void:
	for index in range(_map_select.item_count):
		if str(_map_select.get_item_metadata(index)) == map_id:
			_map_select.select(index)
			return


func _on_setup_changed(_value: Variant = null) -> void:
	var config: MatchConfig = AppState.current_match_config
	config.player_one_ai.controller_type = int(_p1_controller.get_item_metadata(_p1_controller.selected))
	config.player_two_ai.controller_type = int(_p2_controller.get_item_metadata(_p2_controller.selected))
	config.map_id = str(_map_select.get_item_metadata(_map_select.selected))
	config.max_turns = int(_max_turns_spin.value)
	config.player_one_ai.search_depth = int(_p1_depth_spin.value)
	config.player_two_ai.rollout_limit = int(_p2_rollout_spin.value)
	config.ai_vs_ai_mode = config.player_one_ai.controller_type != GameTypes.ControllerType.HUMAN and config.player_two_ai.controller_type != GameTypes.ControllerType.HUMAN
	_refresh_summary()


func _refresh_summary() -> void:
	var config: MatchConfig = AppState.current_match_config
	var replay_ready: String = "Ready" if not AppState.current_replay.turns.is_empty() else "Empty"
	if _replay_button != null:
		_replay_button.disabled = AppState.current_replay.turns.is_empty()
	_summary_label.text = "[center]AI-vs-AI is the flagship mode.[/center]\n[center]Current build: %s[/center]\n\n[center]P1: %s | P2: %s | Map: %s | Replay: %s[/center]" % [
		AppState.build_label.replace("-", " "),
		_controller_label(config.player_one_ai.controller_type),
		_controller_label(config.player_two_ai.controller_type),
		config.map_id.capitalize(),
		replay_ready,
	]


func _controller_label(controller_type: int) -> String:
	match controller_type:
		GameTypes.ControllerType.HUMAN:
			return "Human"
		GameTypes.ControllerType.MINIMAX:
			return "Minimax"
		GameTypes.ControllerType.MCTS:
			return "MCTS"
		_:
			return "Unknown"


func _on_open_match_pressed() -> void:
	get_tree().change_scene_to_file(MATCH_SCENE)


func _on_open_replay_pressed() -> void:
	get_tree().change_scene_to_file(REPLAY_SCENE)


func _on_open_settings_pressed() -> void:
	get_tree().change_scene_to_file(SETTINGS_SCENE)


func _on_reset_state_pressed() -> void:
	AppState.reset_runtime_state()
	_apply_config_to_controls()
	_refresh_summary()
