extends Control

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"
const AUTOPLAY_SPEED_LABELS := ["Slow", "Normal", "Fast"]
const AUTOPLAY_SPEED_SECONDS := [0.9, 0.45, 0.15]

var _game_state: GameState
var _board_view: BoardDebugView
var _board_holder: Control
var _hover_label: Label
var _selected_label: Label
var _turn_label: Label
var _objective_label: Label
var _status_label: Label
var _mode_label: Label
var _selected_actor_label: Label
var _map_label: Label
var _ai_label: Label
var _explanation_label: Label
var _preview_label: Label
var _stats_label: Label
var _player_one_label: Label
var _player_two_label: Label
var _event_log: RichTextLabel
var _move_button: Button
var _attack_button: Button
var _pass_button: Button
var _reset_button: Button
var _ai_move_button: Button
var _autoplay_button: Button
var _speed_button: Button
var _history_list: ItemList
var _history_detail_label: Label
var _autoplay_timer: Timer
var _action_mode: String = ""
var _selected_actor_id: String = ""
var _autoplay_enabled: bool = false
var _autoplay_speed_index: int = 1


func _ready() -> void:
	_reset_match()
	AudioManager.play_match_music()
	_build_layout()
	_refresh_view()


func _build_layout() -> void:
	var background = ColorRect.new()
	background.color = Color("0b0f16")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var glow_left = ColorRect.new()
	glow_left.color = Color(0.16, 0.26, 0.36, 0.17)
	glow_left.position = Vector2(-120, 120)
	glow_left.size = Vector2(340, 640)
	add_child(glow_left)

	var glow_right = ColorRect.new()
	glow_right.color = Color(0.42, 0.22, 0.16, 0.12)
	glow_right.position = Vector2(1240, 80)
	glow_right.size = Vector2(360, 700)
	add_child(glow_right)

	var horizon_band = ColorRect.new()
	horizon_band.color = Color(0.22, 0.28, 0.36, 0.08)
	horizon_band.position = Vector2(0, 210)
	horizon_band.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	horizon_band.custom_minimum_size = Vector2(0, 220)
	horizon_band.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	add_child(horizon_band)

	var root_margin = MarginContainer.new()
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 24)
	root_margin.add_theme_constant_override("margin_top", 24)
	root_margin.add_theme_constant_override("margin_right", 24)
	root_margin.add_theme_constant_override("margin_bottom", 24)
	add_child(root_margin)

	var layout = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	root_margin.add_child(layout)

	var title = Label.new()
	title.text = "Phase 12 Audio Routing And Live Music"
	title.add_theme_font_size_override("font_size", 32)
	layout.add_child(title)

	var header_row = HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 16)
	layout.add_child(header_row)

	_turn_label = Label.new()
	_turn_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(_turn_label)

	_objective_label = Label.new()
	_objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_objective_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(_objective_label)

	var player_row = HBoxContainer.new()
	player_row.add_theme_constant_override("separation", 14)
	layout.add_child(player_row)

	var p1_panel = PanelContainer.new()
	p1_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p1_panel.self_modulate = Color(0.9, 0.96, 1.0, 1.0)
	player_row.add_child(p1_panel)

	var p1_margin = MarginContainer.new()
	p1_margin.add_theme_constant_override("margin_left", 14)
	p1_margin.add_theme_constant_override("margin_top", 10)
	p1_margin.add_theme_constant_override("margin_right", 14)
	p1_margin.add_theme_constant_override("margin_bottom", 10)
	p1_panel.add_child(p1_margin)

	_player_one_label = Label.new()
	_player_one_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	p1_margin.add_child(_player_one_label)

	var p2_panel = PanelContainer.new()
	p2_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p2_panel.self_modulate = Color(1.0, 0.94, 0.92, 1.0)
	player_row.add_child(p2_panel)

	var p2_margin = MarginContainer.new()
	p2_margin.add_theme_constant_override("margin_left", 14)
	p2_margin.add_theme_constant_override("margin_top", 10)
	p2_margin.add_theme_constant_override("margin_right", 14)
	p2_margin.add_theme_constant_override("margin_bottom", 10)
	p2_panel.add_child(p2_margin)

	_player_two_label = Label.new()
	_player_two_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	p2_margin.add_child(_player_two_label)

	var content = HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 18)
	layout.add_child(content)

	var board_panel = PanelContainer.new()
	board_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_panel.self_modulate = Color(0.94, 0.98, 1.0, 1.0)
	board_panel.clip_contents = true
	content.add_child(board_panel)

	var board_margin = MarginContainer.new()
	board_margin.add_theme_constant_override("margin_left", 18)
	board_margin.add_theme_constant_override("margin_top", 18)
	board_margin.add_theme_constant_override("margin_right", 18)
	board_margin.add_theme_constant_override("margin_bottom", 18)
	board_panel.add_child(board_margin)

	_board_holder = Control.new()
	_board_holder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_board_holder.clip_contents = true
	_board_holder.custom_minimum_size = Vector2(700, 560)
	_board_holder.resized.connect(_on_board_holder_resized)
	board_margin.add_child(_board_holder)

	_board_view = BoardDebugView.new()
	_board_view.set_game_state(_game_state)
	_board_view.hovered_cell_changed.connect(_on_hover_summary_changed)
	_board_view.selected_cell_changed.connect(_on_selected_summary_changed)
	_board_view.cell_clicked.connect(_on_board_cell_clicked)
	_board_holder.add_child(_board_view)

	var sidebar = PanelContainer.new()
	sidebar.custom_minimum_size = Vector2(360, 0)
	sidebar.self_modulate = Color(0.98, 0.96, 0.93, 1.0)
	sidebar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(sidebar)

	var sidebar_margin = MarginContainer.new()
	sidebar_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sidebar_margin.add_theme_constant_override("margin_left", 20)
	sidebar_margin.add_theme_constant_override("margin_top", 20)
	sidebar_margin.add_theme_constant_override("margin_right", 20)
	sidebar_margin.add_theme_constant_override("margin_bottom", 20)
	sidebar.add_child(sidebar_margin)

	var sidebar_scroll = ScrollContainer.new()
	sidebar_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sidebar_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sidebar_margin.add_child(sidebar_scroll)

	var sidebar_layout = VBoxContainer.new()
	sidebar_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar_layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sidebar_layout.add_theme_constant_override("separation", 12)
	sidebar_scroll.add_child(sidebar_layout)

	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar_layout.add_child(_status_label)

	_map_label = Label.new()
	_map_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar_layout.add_child(_map_label)

	_ai_label = Label.new()
	_ai_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar_layout.add_child(_ai_label)

	_preview_label = Label.new()
	_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar_layout.add_child(_preview_label)

	_mode_label = Label.new()
	sidebar_layout.add_child(_mode_label)

	_selected_actor_label = Label.new()
	_selected_actor_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar_layout.add_child(_selected_actor_label)

	_hover_label = Label.new()
	_hover_label.text = "Hover: move the mouse over the board"
	_hover_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar_layout.add_child(_hover_label)

	_selected_label = Label.new()
	_selected_label.text = "Selected Tile: click a tile to inspect it"
	_selected_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar_layout.add_child(_selected_label)

	var action_row = HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	sidebar_layout.add_child(action_row)

	_move_button = Button.new()
	_move_button.text = "Move"
	_move_button.custom_minimum_size = Vector2(96, 44)
	_move_button.pressed.connect(_on_move_mode_pressed)
	_wire_button_audio(_move_button)
	action_row.add_child(_move_button)

	_attack_button = Button.new()
	_attack_button.text = "Attack"
	_attack_button.custom_minimum_size = Vector2(96, 44)
	_attack_button.pressed.connect(_on_attack_mode_pressed)
	_wire_button_audio(_attack_button)
	action_row.add_child(_attack_button)

	_pass_button = Button.new()
	_pass_button.text = "Pass"
	_pass_button.custom_minimum_size = Vector2(96, 44)
	_pass_button.pressed.connect(_on_pass_pressed)
	_wire_button_audio(_pass_button)
	action_row.add_child(_pass_button)

	var utility_row = HBoxContainer.new()
	utility_row.add_theme_constant_override("separation", 8)
	sidebar_layout.add_child(utility_row)

	_ai_move_button = Button.new()
	_ai_move_button.text = "Step AI"
	_ai_move_button.custom_minimum_size = Vector2(120, 44)
	_ai_move_button.pressed.connect(_on_ai_move_pressed)
	_wire_button_audio(_ai_move_button)
	utility_row.add_child(_ai_move_button)

	_autoplay_button = Button.new()
	_autoplay_button.text = "Auto: Off"
	_autoplay_button.custom_minimum_size = Vector2(108, 44)
	_autoplay_button.pressed.connect(_on_autoplay_pressed)
	_wire_button_audio(_autoplay_button)
	utility_row.add_child(_autoplay_button)

	_speed_button = Button.new()
	_speed_button.text = "Speed: Normal"
	_speed_button.custom_minimum_size = Vector2(118, 44)
	_speed_button.pressed.connect(_on_speed_pressed)
	_wire_button_audio(_speed_button)
	utility_row.add_child(_speed_button)

	_reset_button = Button.new()
	_reset_button.text = "Reset"
	_reset_button.custom_minimum_size = Vector2(96, 44)
	_reset_button.pressed.connect(_on_reset_pressed)
	_wire_button_audio(_reset_button)
	utility_row.add_child(_reset_button)

	var legend = Label.new()
	legend.text = "Testing flow:\n1. Click your tank for manual play\n2. Choose Move or Attack\n3. Click a highlighted target\n4. Use Step AI for one AI turn\n5. Use Auto to watch AI-vs-AI continuously\n6. Use Reset to restart the current map\n\nQtank = slim laser chassis\nKtank = heavy siege hull\nBlue = Player 1\nRed = Player 2\nMusic should swap between menu and match scenes.\nLaser, blast, hit flash, and damage audio should now play during actions."
	legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar_layout.add_child(legend)

	_explanation_label = Label.new()
	_explanation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar_layout.add_child(_explanation_label)

	_stats_label = Label.new()
	_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar_layout.add_child(_stats_label)

	var history_title = Label.new()
	history_title.text = "Turn History"
	sidebar_layout.add_child(history_title)

	_history_list = ItemList.new()
	_history_list.custom_minimum_size = Vector2(0, 150)
	_history_list.item_selected.connect(_on_history_item_selected)
	sidebar_layout.add_child(_history_list)

	_history_detail_label = Label.new()
	_history_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar_layout.add_child(_history_detail_label)

	_event_log = RichTextLabel.new()
	_event_log.custom_minimum_size = Vector2(0, 220)
	_event_log.fit_content = false
	_event_log.scroll_following = true
	_event_log.bbcode_enabled = false
	sidebar_layout.add_child(_event_log)

	var back_button = Button.new()
	back_button.text = "Back To Menu"
	back_button.custom_minimum_size = Vector2(220, 48)
	back_button.pressed.connect(_on_back_pressed)
	_wire_button_audio(back_button, true)
	sidebar_layout.add_child(back_button)

	_autoplay_timer = Timer.new()
	_autoplay_timer.one_shot = true
	_autoplay_timer.timeout.connect(_on_autoplay_timer_timeout)
	add_child(_autoplay_timer)

	call_deferred("_recenter_board_view")


func _refresh_view() -> void:
	_turn_label.text = "Turn %d | Current Player: P%d | Actions Left: %d" % [
		_game_state.turn_count,
		_game_state.current_player,
		_game_state.actions_remaining_in_turn,
	]
	_objective_label.text = _objective_text()
	_map_label.text = "Map: %s\n%s" % [_game_state.board.map_display_name, _game_state.board.map_description]
	_player_one_label.text = _player_summary_text(1)
	_player_two_label.text = _player_summary_text(2)
	_ai_label.text = _ai_status_text()
	_explanation_label.text = _explanation_text()
	_preview_label.text = _preview_text()
	_stats_label.text = _stats_text()
	_autoplay_button.text = "Auto: %s" % ("On" if _autoplay_enabled else "Off")
	_speed_button.text = "Speed: %s" % AUTOPLAY_SPEED_LABELS[_autoplay_speed_index]

	if _game_state.game_over:
		_status_label.text = "Game Over: %s" % (_winner_label())
	elif _autoplay_enabled:
		_status_label.text = "Current Status: Autoplay running at %s speed." % AUTOPLAY_SPEED_LABELS[_autoplay_speed_index]
	else:
		_status_label.text = "Current Status: %s" % ("Select a tank to act." if _selected_actor_id == "" else "Choose an action for %s." % _actor_label(_selected_actor_id))

	_mode_label.text = "Action Mode: %s" % (_action_mode.capitalize() if _action_mode != "" else "None")
	_selected_actor_label.text = "Selected Tank: %s" % (_actor_label(_selected_actor_id) if _selected_actor_id != "" else "None")

	_board_view.set_game_state(_game_state)
	_board_view.set_selected_actor(_selected_actor_id)
	_board_view.set_action_mode(_action_mode)
	_board_view.set_highlighted_cells(_build_highlight_map())
	_recenter_board_view()
	_refresh_event_log()
	_refresh_history_panel()
	_update_button_state()


func _build_highlight_map() -> Dictionary:
	var highlights: Dictionary = {}
	if _selected_actor_id == "":
		for tank: TankData in _game_state.get_player_tanks(_game_state.current_player):
			highlights[tank.position.key()] = Color("69d2ff")
		return highlights

	var selected_tank: TankData = _game_state.get_tank(_selected_actor_id)
	if selected_tank != null:
		highlights[selected_tank.position.key()] = Color("69d2ff")

	match _action_mode:
		"move":
			for coord: HexCoord in _game_state.get_legal_move_targets(_selected_actor_id):
				highlights[coord.key()] = Color("57d477")
		"attack":
			for coord: HexCoord in _game_state.get_legal_attack_targets(_selected_actor_id):
				highlights[coord.key()] = Color("ff6978")

	return highlights


func _refresh_event_log() -> void:
	var lines: Array[String] = []
	for event_item: GameEvent in _game_state.last_events:
		lines.append(_format_event(event_item))
	_event_log.text = "\n".join(lines) if not lines.is_empty() else "Event Log: no actions taken yet."


func _format_event(event_item: GameEvent) -> String:
	match event_item.event_name:
		"move":
			return "Move: %s %s -> %s" % [event_item.payload.get("actor_id", ""), event_item.payload.get("from", ""), event_item.payload.get("to", "")]
		"attack":
			return "Attack: %s used %s (%s dmg)" % [event_item.payload.get("actor_id", ""), event_item.payload.get("mode", ""), event_item.payload.get("damage", 0)]
		"hit_tank":
			return "Hit Tank: %s took %s at %s" % [event_item.payload.get("target", ""), event_item.payload.get("damage", 0), event_item.payload.get("coord", "")]
		"hit_cell":
			var reveal_text: String = ""
			var revealed_type: int = event_item.payload.get("revealed_type", -1)
			if revealed_type != -1:
				reveal_text = " reveal=%s" % _cell_type_label(revealed_type)
			return "Hit Cell: %s dmg=%s destroyed=%s%s" % [event_item.payload.get("coord", ""), event_item.payload.get("damage", 0), event_item.payload.get("destroyed", false), reveal_text]
		"power_up":
			return "Power-Up: %s gained %s" % [event_item.payload.get("actor_id", ""), event_item.payload.get("buff", "")]
		"extra_action_granted":
			return "Extra Action: Player %s now has %s action(s)" % [event_item.payload.get("player", 0), event_item.payload.get("remaining", 0)]
		"tank_destroyed":
			return "Destroyed: %s" % event_item.payload.get("target", "")
		"win_center":
			return "Win: Player %s captured the center" % event_item.payload.get("winner", 0)
		"win_ktank_destroyed":
			return "Win: Player %s destroyed the enemy Ktank" % event_item.payload.get("winner", 0)
		"draw_turn_limit":
			return "Draw: turn limit reached"
		"draw_repetition":
			return "Draw: repeated state detected"
		"pass":
			return "Pass: Player %s ended the turn" % event_item.payload.get("player", 0)
		"invalid_action":
			return "Invalid Action: %s" % event_item.payload.get("reason", "unknown")
		_:
			return "%s %s" % [event_item.event_name, event_item.payload]


func _update_button_state() -> void:
	var can_act: bool = not _game_state.game_over and not _autoplay_enabled and _selected_actor_id != ""
	_move_button.disabled = not can_act
	_attack_button.disabled = not can_act
	_pass_button.disabled = _game_state.game_over or _autoplay_enabled
	_reset_button.disabled = false
	_ai_move_button.disabled = _game_state.game_over or _autoplay_enabled or _current_player_controller_type() == GameTypes.ControllerType.HUMAN
	_autoplay_button.disabled = _game_state.game_over or not _both_players_are_ai()


func _on_board_cell_clicked(coord_key: String) -> void:
	var coord: HexCoord = HexCoord.from_key(coord_key)
	var clicked_tank: TankData = _game_state.get_tank_at(coord)

	if clicked_tank != null and clicked_tank.owner_id == _game_state.current_player:
		_selected_actor_id = clicked_tank.actor_id()
		_action_mode = ""
		_refresh_view()
		return

	if _selected_actor_id == "" or _action_mode == "" or _game_state.game_over:
		return

	match _action_mode:
		"move":
			_try_execute_move(coord)
		"attack":
			_try_execute_attack(coord)


func _try_execute_move(coord: HexCoord) -> void:
	for target: HexCoord in _game_state.get_legal_move_targets(_selected_actor_id):
		if target.equals(coord):
			var action: ActionData = ActionData.new(GameTypes.ActionType.MOVE, _selected_actor_id, coord.clone())
			_execute_action(action, "Human", _manual_explanation(action))
			return


func _try_execute_attack(coord: HexCoord) -> void:
	var action: ActionData = _game_state.build_attack_action(_selected_actor_id, coord)
	if action == null:
		return
	_execute_action(action, "Human", _manual_explanation(action))


func _after_action() -> void:
	_action_mode = ""
	if _selected_actor_id != "":
		var selected_tank: TankData = _game_state.get_tank(_selected_actor_id)
		if selected_tank == null or not selected_tank.is_alive() or selected_tank.owner_id != _game_state.current_player:
			_selected_actor_id = ""
	_refresh_view()


func _on_move_mode_pressed() -> void:
	if _selected_actor_id == "":
		return
	_action_mode = "move"
	_refresh_view()


func _on_attack_mode_pressed() -> void:
	if _selected_actor_id == "":
		return
	_action_mode = "attack"
	_refresh_view()


func _on_pass_pressed() -> void:
	var action: ActionData = ActionData.new(GameTypes.ActionType.PASS)
	_execute_action(action, "Human", _manual_explanation(action))


func _on_reset_pressed() -> void:
	_disable_autoplay()
	_reset_match()
	_refresh_view()


func _on_ai_move_pressed() -> void:
	_step_current_ai_turn()


func _on_autoplay_pressed() -> void:
	if _autoplay_enabled:
		_disable_autoplay()
	else:
		_enable_autoplay()
	_refresh_view()


func _on_speed_pressed() -> void:
	_autoplay_speed_index = (_autoplay_speed_index + 1) % AUTOPLAY_SPEED_LABELS.size()
	if _autoplay_enabled:
		_schedule_autoplay()
	_refresh_view()


func _on_autoplay_timer_timeout() -> void:
	if not _autoplay_enabled or _game_state.game_over:
		return
	if _current_player_controller_type() == GameTypes.ControllerType.HUMAN:
		_disable_autoplay()
		_refresh_view()
		return
	_step_current_ai_turn()
	if _autoplay_enabled and not _game_state.game_over:
		_schedule_autoplay()


func _step_current_ai_turn() -> void:
	var controller_type: int = _current_player_controller_type()
	if controller_type == GameTypes.ControllerType.HUMAN:
		return

	var config: AIConfig = _game_state.get_ai_config_for_player(_game_state.current_player).clone()
	var result: Dictionary = _choose_ai_action(controller_type, config)
	var action: ActionData = result.get("action", ActionData.new(GameTypes.ActionType.PASS))
	var explanation: ActionExplanation = result.get("explanation", ActionExplanation.new())
	_execute_action(action, _controller_label(controller_type), explanation)


func _reset_match() -> void:
	_game_state = GameState.new(AppState.current_match_config.clone())
	_action_mode = ""
	_selected_actor_id = ""
	if _board_view != null:
		_board_view.clear_transient_effects()
	AppState.last_action_explanation = ActionExplanation.new()
	AppState.current_replay.clear()
	AppState.current_replay.metadata = {
		"map_id": _game_state.board.map_id,
		"map_name": _game_state.board.map_display_name,
		"player_one_controller": _controller_label(AppState.current_match_config.player_one_ai.controller_type),
		"player_two_controller": _controller_label(AppState.current_match_config.player_two_ai.controller_type),
	}
	call_deferred("_recenter_board_view")


func _winner_label() -> String:
	if _game_state.winner == 0:
		return "Draw"
	return "Player %d" % _game_state.winner


func _actor_label(actor_id: String) -> String:
	if actor_id == "":
		return "None"
	var tank: TankData = _game_state.get_tank(actor_id)
	if tank == null:
		return actor_id
	var tank_name: String = "Qtank" if tank.tank_type == GameTypes.TankType.QTANK else "Ktank"
	return "P%d %s (%s HP)" % [tank.owner_id, tank_name, tank.hp]


func _on_back_pressed() -> void:
	_disable_autoplay()
	get_tree().change_scene_to_file(MENU_SCENE)


func _on_board_holder_resized() -> void:
	_recenter_board_view()


func _on_hover_summary_changed(summary: String) -> void:
	_hover_label.text = "Hover: %s" % summary


func _on_selected_summary_changed(summary: String) -> void:
	_selected_label.text = "Selected Tile: %s" % summary


func _cell_type_label(cell_type: int) -> String:
	match cell_type:
		GameTypes.CellType.EMPTY:
			return "Empty"
		GameTypes.CellType.CENTER:
			return "Center"
		GameTypes.CellType.WALL:
			return "Wall"
		GameTypes.CellType.BLOCK:
			return "Block"
		GameTypes.CellType.ARMOR_BLOCK:
			return "Armor Block"
		GameTypes.CellType.POWER_BLOCK:
			return "Power Block"
		GameTypes.CellType.POWER_ATTACK:
			return "Power Attack"
		GameTypes.CellType.POWER_SHIELD:
			return "Power Shield"
		GameTypes.CellType.POWER_BONUS_MOVE:
			return "Power Bonus Move"
		_:
			return "Unknown"


func _current_player_controller_type() -> int:
	return _game_state.get_ai_config_for_player(_game_state.current_player).controller_type


func _choose_ai_action(controller_type: int, config: AIConfig) -> Dictionary:
	match controller_type:
		GameTypes.ControllerType.MINIMAX:
			var minimax: MinimaxAI = MinimaxAI.new()
			return minimax.choose_action(_game_state, config)
		GameTypes.ControllerType.MCTS:
			var mcts: MctsAI = MctsAI.new()
			return mcts.choose_action(_game_state, config)
		_:
			return {
				"action": ActionData.new(GameTypes.ActionType.PASS),
				"explanation": ActionExplanation.new("", "No AI controller available for this player.", 0.0),
			}


func _execute_action(action: ActionData, source_label: String, explanation: ActionExplanation) -> void:
	var acting_turn: int = _game_state.turn_count
	var acting_player: int = _game_state.current_player
	var previous_state: GameState = _game_state.clone()
	_game_state.apply_action(action)
	AudioManager.play_action_feedback(previous_state, _game_state, action, _game_state.last_events)
	_board_view.play_action_feedback(previous_state, _game_state, action, _game_state.last_events)
	if _game_state.game_over:
		_disable_autoplay()
	AppState.last_action_explanation = explanation
	EventBus.action_explanation_updated.emit(explanation)
	_record_turn_snapshot(acting_turn, acting_player, source_label, action, explanation)
	_after_action()


func _record_turn_snapshot(acting_turn: int, acting_player: int, source_label: String, action: ActionData, explanation: ActionExplanation) -> void:
	var event_lines: Array[String] = []
	for event_item: GameEvent in _game_state.last_events:
		event_lines.append(_format_event(event_item))

	var snapshot: Dictionary = {
		"turn": acting_turn,
		"player": acting_player,
		"source": source_label,
		"action_type": action.action_type,
		"actor_id": action.actor_id,
		"target": action.target_coord.key(),
		"summary": explanation.summary if explanation.summary != "" else _manual_summary(action),
		"score": explanation.score,
		"metrics": explanation.metrics.duplicate(true),
		"events": event_lines,
		"state_hash": _game_state.get_state_hash(),
	}
	AppState.current_replay.add_turn(snapshot)


func _refresh_history_panel() -> void:
	if _history_list == null:
		return

	var selected_items: PackedInt32Array = _history_list.get_selected_items()
	var previous_selected: int = selected_items[0] if selected_items.size() > 0 else -1
	_history_list.clear()
	for index in range(AppState.current_replay.turns.size()):
		var turn_data: Dictionary = AppState.current_replay.turns[index]
		var label: String = "T%d P%d %s" % [turn_data.get("turn", 0), turn_data.get("player", 0), turn_data.get("source", "Unknown")]
		_history_list.add_item(label)

	if AppState.current_replay.turns.is_empty():
		_history_detail_label.text = "History Detail: no turns recorded yet."
		return

	var selected_index: int = previous_selected
	if selected_index < 0 or selected_index >= AppState.current_replay.turns.size():
		selected_index = AppState.current_replay.turns.size() - 1
	_history_list.select(selected_index)
	_history_detail_label.text = _history_detail_text(selected_index)


func _on_history_item_selected(index: int) -> void:
	_history_detail_label.text = _history_detail_text(index)


func _history_detail_text(index: int) -> String:
	if index < 0 or index >= AppState.current_replay.turns.size():
		return "History Detail: no turn selected."

	var turn_data: Dictionary = AppState.current_replay.turns[index]
	var metrics: Dictionary = turn_data.get("metrics", {})
	var event_lines: Array[String] = []
	for event_line: Variant in turn_data.get("events", []):
		event_lines.append(str(event_line))
	var metrics_summary: String = "Score %.2f" % float(turn_data.get("score", 0.0))
	if turn_data.get("source", "") == "Minimax":
		metrics_summary += " | Depth %s | Nodes %s" % [metrics.get("depth_completed", 0), metrics.get("nodes_searched", 0)]
	elif turn_data.get("source", "") == "MCTS":
		metrics_summary += " | Iter %s | Rollouts %s" % [metrics.get("iterations", 0), metrics.get("rollouts", 0)]

	var events_text: String = "\n".join(event_lines)
	return "History Detail:\n%s\n%s\n%s" % [turn_data.get("summary", ""), metrics_summary, events_text]


func _manual_explanation(action: ActionData) -> ActionExplanation:
	return ActionExplanation.new(_actor_label(action.actor_id), _manual_summary(action), 0.0, {"source": "manual"})


func _manual_summary(action: ActionData) -> String:
	match action.action_type:
		GameTypes.ActionType.MOVE:
			return "Human moved %s to %s." % [_actor_label(action.actor_id), action.target_coord.key()]
		GameTypes.ActionType.ATTACK:
			return "Human attacked with %s." % _actor_label(action.actor_id)
		GameTypes.ActionType.PASS:
			return "Human passed the turn."
		_:
			return "Human action resolved."


func _enable_autoplay() -> void:
	if not _both_players_are_ai():
		return
	_autoplay_enabled = true
	_schedule_autoplay()


func _disable_autoplay() -> void:
	_autoplay_enabled = false
	if _autoplay_timer != null:
		_autoplay_timer.stop()


func _schedule_autoplay() -> void:
	if _autoplay_timer == null:
		return
	_autoplay_timer.stop()
	_autoplay_timer.wait_time = AUTOPLAY_SPEED_SECONDS[_autoplay_speed_index]
	_autoplay_timer.start()


func _both_players_are_ai() -> bool:
	return AppState.current_match_config.player_one_ai.controller_type != GameTypes.ControllerType.HUMAN and AppState.current_match_config.player_two_ai.controller_type != GameTypes.ControllerType.HUMAN


func _ai_status_text() -> String:
	var p1_type: String = _controller_label(AppState.current_match_config.player_one_ai.controller_type)
	var p2_type: String = _controller_label(AppState.current_match_config.player_two_ai.controller_type)
	var current_type: String = _controller_label(_game_state.get_ai_config_for_player(_game_state.current_player).controller_type)
	return "Controllers: P1 %s | P2 %s\nCurrent Turn AI: %s\nAutoplay: %s" % [p1_type, p2_type, current_type, "Enabled" if _autoplay_enabled else "Disabled"]


func _explanation_text() -> String:
	if AppState.last_action_explanation.summary == "":
		match _current_player_controller_type():
			GameTypes.ControllerType.MINIMAX:
				return "AI Explanation: Minimax is ready for the current player."
			GameTypes.ControllerType.MCTS:
				return "AI Explanation: MCTS is ready for the current player."
			_:
				return "AI Explanation: Current player is human-controlled."

	var metrics: Dictionary = AppState.last_action_explanation.metrics
	if str(AppState.last_action_explanation.summary).begins_with("MCTS"):
		return "AI Explanation: %s\nScore %.2f | Iterations %s | Rollouts %s | %.0f ms" % [
			AppState.last_action_explanation.summary,
			AppState.last_action_explanation.score,
			metrics.get("iterations", 0),
			metrics.get("rollouts", 0),
			metrics.get("elapsed_ms", 0.0),
		]

	return "AI Explanation: %s\nScore %.2f | Depth %s | Nodes %s | %.0f ms" % [
		AppState.last_action_explanation.summary,
		AppState.last_action_explanation.score,
		metrics.get("depth_completed", 0),
		metrics.get("nodes_searched", 0),
		metrics.get("elapsed_ms", 0.0),
	]


func _stats_text() -> String:
	var total_turns: int = AppState.current_replay.turns.size()
	if total_turns == 0:
		return "Arena Stats: no recorded turns yet.\nUse Step AI or Auto to begin."

	var latest: Dictionary = AppState.current_replay.turns[total_turns - 1]
	return "Arena Stats: %d recorded turns\nLatest: T%d P%d via %s\nState Hash: %s" % [
		total_turns,
		latest.get("turn", 0),
		latest.get("player", 0),
		latest.get("source", "Unknown"),
		latest.get("state_hash", ""),
	]


func _objective_text() -> String:
	return "Objective: Destroy enemy Ktank or move your Ktank to the center hex."


func _player_summary_text(player_id: int) -> String:
	var controller_type: int = _game_state.get_ai_config_for_player(player_id).controller_type
	var summary_lines: Array[String] = []
	summary_lines.append("Player %d | %s" % [player_id, _controller_label(controller_type)])

	var ktank: TankData = _find_tank(player_id, GameTypes.TankType.KTANK)
	var qtank: TankData = _find_tank(player_id, GameTypes.TankType.QTANK)
	if ktank != null:
		summary_lines.append("Ktank: %s HP | Dist %d | %s" % [ktank.hp, ktank.position.distance_to(HexCoord.new()), _buff_label(ktank.active_buff)])
	if qtank != null:
		summary_lines.append("Qtank: %s HP | %s" % [qtank.hp, _buff_label(qtank.active_buff)])

	var total_hp: int = 0
	for tank: TankData in _game_state.get_player_tanks(player_id):
		total_hp += tank.hp
	summary_lines.append("Total Team HP: %d%s" % [total_hp, " | Active" if _game_state.current_player == player_id else ""])
	return "\n".join(summary_lines)


func _preview_text() -> String:
	if _autoplay_enabled:
		return "Preview: Spectator mode active. Use the history list to inspect earlier turns while autoplay runs."

	if _selected_actor_id == "":
		return "Preview: Select a tank to inspect its move and attack options. Qtank fires a line laser. Ktank blasts adjacent hexes and wins instantly if it reaches center."

	var tank: TankData = _game_state.get_tank(_selected_actor_id)
	if tank == null:
		return "Preview: Selected tank is no longer available."

	var tank_name: String = "Qtank" if tank.tank_type == GameTypes.TankType.QTANK else "Ktank"
	var move_count: int = _game_state.get_legal_move_targets(_selected_actor_id).size()
	var attack_count: int = _game_state.get_legal_attack_targets(_selected_actor_id).size()
	var base_text: String = "Preview: %s | %s HP | %s | %d moves | %d attack targets." % [tank_name, tank.hp, _buff_label(tank.active_buff), move_count, attack_count]

	match _action_mode:
		"move":
			var can_reach_center: bool = false
			for coord: HexCoord in _game_state.get_legal_move_targets(_selected_actor_id):
				if coord.q == 0 and coord.r == 0:
					can_reach_center = true
					break
			return "%s Move mode is active.%s" % [base_text, " Center is reachable now." if can_reach_center else ""]
		"attack":
			return "%s Attack mode is active. Highlighted hexes show the current threat area." % base_text
		_:
			return "%s Choose Move, Attack, or Pass." % base_text


func _find_tank(player_id: int, tank_type: int) -> TankData:
	for tank: TankData in _game_state.get_all_tanks():
		if tank.owner_id == player_id and tank.tank_type == tank_type and tank.is_alive():
			return tank
	return null


func _buff_label(buff_type: int) -> String:
	match buff_type:
		GameTypes.BuffType.ATTACK_MULTIPLIER:
			return "Attack Buff"
		GameTypes.BuffType.SHIELD_BUFFER:
			return "Shield Buff"
		GameTypes.BuffType.BONUS_MOVE:
			return "Bonus Move"
		_:
			return "No Buff"


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


func _recenter_board_view() -> void:
	if _board_view == null or _board_holder == null:
		return

	var holder_size: Vector2 = _board_holder.size
	if holder_size.x <= 0.0 or holder_size.y <= 0.0:
		return

	var visual_size: Vector2 = _board_view.get_board_visual_size()
	var width_scale: float = holder_size.x / maxf(visual_size.x, 1.0)
	var height_scale: float = holder_size.y / maxf(visual_size.y, 1.0)
	var scale_factor: float = clampf(minf(width_scale, height_scale), 0.72, 1.0)
	_board_view.scale = Vector2.ONE * scale_factor
	_board_view.position = Vector2(holder_size.x * 0.5, holder_size.y * 0.53)


func _wire_button_audio(button: Button, use_back_sound: bool = false) -> void:
	if button == null:
		return
	button.mouse_entered.connect(AudioManager.play_ui_hover)
	if use_back_sound:
		button.pressed.connect(AudioManager.play_ui_back)
	else:
		button.pressed.connect(AudioManager.play_ui_click)
