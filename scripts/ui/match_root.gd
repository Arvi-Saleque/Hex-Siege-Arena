extends Control

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"

var _board_view: BoardDebugView
var _hover_label: Label
var _selected_label: Label


func _ready() -> void:
	_build_layout()


func _build_layout() -> void:
	var background := ColorRect.new()
	background.color = Color("0b0f16")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root_margin := MarginContainer.new()
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 24)
	root_margin.add_theme_constant_override("margin_top", 24)
	root_margin.add_theme_constant_override("margin_right", 24)
	root_margin.add_theme_constant_override("margin_bottom", 24)
	add_child(root_margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	root_margin.add_child(layout)

	var title := Label.new()
	title.text = "Phase 2 Board Foundation"
	title.add_theme_font_size_override("font_size", 32)
	layout.add_child(title)

	var top_info := Label.new()
	top_info.text = "P1: %s | P2: %s | Map: %s | Board: 91 flat-top hexes" % [
		_controller_label(AppState.current_match_config.player_one_ai.controller_type),
		_controller_label(AppState.current_match_config.player_two_ai.controller_type),
		AppState.current_match_config.map_id,
	]
	layout.add_child(top_info)

	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 18)
	layout.add_child(content)

	var board_panel := PanelContainer.new()
	board_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(board_panel)

	var board_margin := MarginContainer.new()
	board_margin.add_theme_constant_override("margin_left", 18)
	board_margin.add_theme_constant_override("margin_top", 18)
	board_margin.add_theme_constant_override("margin_right", 18)
	board_margin.add_theme_constant_override("margin_bottom", 18)
	board_panel.add_child(board_margin)

	_board_view = BoardDebugView.new()
	_board_view.position = Vector2(460, 320)
	_board_view.hovered_cell_changed.connect(_on_hover_summary_changed)
	_board_view.selected_cell_changed.connect(_on_selected_summary_changed)
	board_margin.add_child(_board_view)

	var sidebar := PanelContainer.new()
	sidebar.custom_minimum_size = Vector2(320, 0)
	content.add_child(sidebar)

	var sidebar_margin := MarginContainer.new()
	sidebar_margin.add_theme_constant_override("margin_left", 20)
	sidebar_margin.add_theme_constant_override("margin_top", 20)
	sidebar_margin.add_theme_constant_override("margin_right", 20)
	sidebar_margin.add_theme_constant_override("margin_bottom", 20)
	sidebar.add_child(sidebar_margin)

	var sidebar_layout := VBoxContainer.new()
	sidebar_layout.add_theme_constant_override("separation", 14)
	sidebar_margin.add_child(sidebar_layout)

	var phase_info := RichTextLabel.new()
	phase_info.fit_content = true
	phase_info.scroll_active = false
	phase_info.text = "This scene now includes a clickable debug board.\n\nPhase 2 goals covered here:\n- flat-top hex math\n- board generation\n- terrain placeholders\n- hover and selection summaries"
	sidebar_layout.add_child(phase_info)

	_hover_label = Label.new()
	_hover_label.text = "Hover: move the mouse over the board"
	_hover_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar_layout.add_child(_hover_label)

	_selected_label = Label.new()
	_selected_label.text = "Selected: click a tile to inspect it"
	_selected_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar_layout.add_child(_selected_label)

	var legend := Label.new()
	legend.text = "Legend:\nYellow = center\nGray = wall\nBrown = block\nSilver = armor\nPurple = power block\nRed = attack power\nBlue = shield\nGreen = bonus move"
	legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar_layout.add_child(legend)

	var back_button := Button.new()
	back_button.text = "Back To Menu"
	back_button.custom_minimum_size = Vector2(220, 48)
	back_button.pressed.connect(_on_back_pressed)
	sidebar_layout.add_child(back_button)


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


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)


func _on_hover_summary_changed(summary: String) -> void:
	_hover_label.text = "Hover: %s" % summary


func _on_selected_summary_changed(summary: String) -> void:
	_selected_label.text = "Selected: %s" % summary
