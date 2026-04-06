extends Control

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"

var _game_state: GameState
var _board_view: BoardDebugView
var _hover_label: Label
var _selected_label: Label
var _turn_label: Label
var _status_label: Label
var _mode_label: Label
var _selected_actor_label: Label
var _map_label: Label
var _event_log: RichTextLabel
var _move_button: Button
var _attack_button: Button
var _pass_button: Button
var _reset_button: Button
var _action_mode: String = ""
var _selected_actor_id: String = ""


func _ready() -> void:
	_reset_match()
	_build_layout()
	_refresh_view()


func _build_layout() -> void:
	var background = ColorRect.new()
	background.color = Color("0b0f16")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

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
	title.text = "Phase 4 Map Presets"
	title.add_theme_font_size_override("font_size", 32)
	layout.add_child(title)

	_turn_label = Label.new()
	layout.add_child(_turn_label)

	var content = HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 18)
	layout.add_child(content)

	var board_panel = PanelContainer.new()
	board_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(board_panel)

	var board_margin = MarginContainer.new()
	board_margin.add_theme_constant_override("margin_left", 18)
	board_margin.add_theme_constant_override("margin_top", 18)
	board_margin.add_theme_constant_override("margin_right", 18)
	board_margin.add_theme_constant_override("margin_bottom", 18)
	board_panel.add_child(board_margin)

	_board_view = BoardDebugView.new()
	_board_view.position = Vector2(460, 320)
	_board_view.set_game_state(_game_state)
	_board_view.hovered_cell_changed.connect(_on_hover_summary_changed)
	_board_view.selected_cell_changed.connect(_on_selected_summary_changed)
	_board_view.cell_clicked.connect(_on_board_cell_clicked)
	board_margin.add_child(_board_view)

	var sidebar = PanelContainer.new()
	sidebar.custom_minimum_size = Vector2(360, 0)
	content.add_child(sidebar)

	var sidebar_margin = MarginContainer.new()
	sidebar_margin.add_theme_constant_override("margin_left", 20)
	sidebar_margin.add_theme_constant_override("margin_top", 20)
	sidebar_margin.add_theme_constant_override("margin_right", 20)
	sidebar_margin.add_theme_constant_override("margin_bottom", 20)
	sidebar.add_child(sidebar_margin)

	var sidebar_layout = VBoxContainer.new()
	sidebar_layout.add_theme_constant_override("separation", 12)
	sidebar_margin.add_child(sidebar_layout)

	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar_layout.add_child(_status_label)

	_map_label = Label.new()
	_map_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar_layout.add_child(_map_label)

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
	action_row.add_child(_move_button)

	_attack_button = Button.new()
	_attack_button.text = "Attack"
	_attack_button.custom_minimum_size = Vector2(96, 44)
	_attack_button.pressed.connect(_on_attack_mode_pressed)
	action_row.add_child(_attack_button)

	_pass_button = Button.new()
	_pass_button.text = "Pass"
	_pass_button.custom_minimum_size = Vector2(96, 44)
	_pass_button.pressed.connect(_on_pass_pressed)
	action_row.add_child(_pass_button)

	_reset_button = Button.new()
	_reset_button.text = "Reset"
	_reset_button.custom_minimum_size = Vector2(96, 44)
	_reset_button.pressed.connect(_on_reset_pressed)
	action_row.add_child(_reset_button)

	var legend = Label.new()
	legend.text = "Testing flow:\n1. Click your tank\n2. Choose Move or Attack\n3. Click a highlighted target\n4. Use Reset to restart the current map\n\nQtank = triangle marker\nKtank = circle marker\nBlue = Player 1\nRed = Player 2"
	legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar_layout.add_child(legend)

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
	sidebar_layout.add_child(back_button)


func _refresh_view() -> void:
	_turn_label.text = "Turn %d | Current Player: P%d | Actions Left: %d" % [
		_game_state.turn_count,
		_game_state.current_player,
		_game_state.actions_remaining_in_turn,
	]
	_map_label.text = "Map: %s\n%s" % [_game_state.board.map_display_name, _game_state.board.map_description]

	if _game_state.game_over:
		_status_label.text = "Game Over: %s" % (_winner_label())
	else:
		_status_label.text = "Current Status: %s" % ("Select a tank to act." if _selected_actor_id == "" else "Choose an action for %s." % _actor_label(_selected_actor_id))

	_mode_label.text = "Action Mode: %s" % (_action_mode.capitalize() if _action_mode != "" else "None")
	_selected_actor_label.text = "Selected Tank: %s" % (_actor_label(_selected_actor_id) if _selected_actor_id != "" else "None")

	_board_view.set_game_state(_game_state)
	_board_view.set_selected_actor(_selected_actor_id)
	_board_view.set_highlighted_cells(_build_highlight_map())
	_refresh_event_log()
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
	var can_act: bool = not _game_state.game_over and _selected_actor_id != ""
	_move_button.disabled = not can_act
	_attack_button.disabled = not can_act
	_pass_button.disabled = _game_state.game_over
	_reset_button.disabled = false


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
			_game_state.apply_action(ActionData.new(GameTypes.ActionType.MOVE, _selected_actor_id, coord.clone()))
			_after_action()
			return


func _try_execute_attack(coord: HexCoord) -> void:
	var action: ActionData = _game_state.build_attack_action(_selected_actor_id, coord)
	if action == null:
		return
	_game_state.apply_action(action)
	_after_action()


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
	_game_state.apply_action(ActionData.new(GameTypes.ActionType.PASS))
	_action_mode = ""
	_selected_actor_id = ""
	_refresh_view()


func _on_reset_pressed() -> void:
	_reset_match()
	_refresh_view()


func _reset_match() -> void:
	_game_state = GameState.new(AppState.current_match_config.clone())
	_action_mode = ""
	_selected_actor_id = ""


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
	get_tree().change_scene_to_file(MENU_SCENE)


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
