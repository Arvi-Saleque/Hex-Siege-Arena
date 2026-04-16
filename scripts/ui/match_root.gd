extends Control

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"
const AUTOPLAY_SPEED_LABELS := ["Slow", "Normal", "Fast"]
const AUTOPLAY_SPEED_SECONDS := [0.9, 0.45, 0.15]
const FONT_REGULAR := preload("res://assets/ui/fonts/inter-regular.ttf")
const FONT_MEDIUM := preload("res://assets/ui/fonts/inter-medium.ttf")
const FONT_SEMIBOLD := preload("res://assets/ui/fonts/rajdhani-semibold.ttf")
const FONT_BOLD := preload("res://assets/ui/fonts/rajdhani-bold.ttf")
const TEXTURE_PANEL_MAIN := preload("res://assets/ui/exported/panel_main.png")
const TEXTURE_BUTTON_PRIMARY := preload("res://assets/ui/exported/button_primary.png")
const TEXTURE_BUTTON_PRIMARY_HOVER := preload("res://assets/ui/exported/button_primary_hover.png")
const TEXTURE_BUTTON_PRIMARY_PRESSED := preload("res://assets/ui/exported/button_primary_pressed.png")
const TEXTURE_BUTTON_EMPHASIS := preload("res://assets/ui/exported/button_emphasis.png")
const TEXTURE_BUTTON_DISABLED := preload("res://assets/ui/exported/button_disabled.png")
const TEXTURE_BADGE_SMALL := preload("res://assets/ui/exported/badge_small.png")
const TEXTURE_DIVIDER := preload("res://assets/ui/exported/divider.png")
const COLOR_BG := Color("09111c")
const COLOR_SURFACE := Color("111c2b")
const COLOR_SURFACE_ALT := Color("162335")
const COLOR_BORDER := Color("2c3f59")
const COLOR_TEXT := Color("edf4ff")
const COLOR_TEXT_MUTED := Color("98adc7")
const COLOR_GOLD := Color("f0c05e")
const COLOR_GREEN := Color("69dd8e")
const COLOR_ATTACK := Color("ff9272")
const COLOR_P1 := Color("77b8ff")
const COLOR_P2 := Color("ff8a76")
var _game_state: GameState
var _board_view: BoardDebugView
var _board_holder: Control
var _selected_model_name_label: Label
var _selected_model_role_label: Label
var _hover_label: Label
var _selected_label: Label
var _turn_label: Label
var _objective_label: Label
var _score_label: Label
var _hp_summary_label: Label
var _units_label: Label
var _control_strip_label: Label
var _status_label: Label
var _mode_label: Label
var _selected_actor_label: Label
var _map_label: Label
var _ai_label: Label
var _explanation_label: Label
var _preview_label: Label
var _stats_label: Label
var _post_match_label: Label
var _player_one_label: Label
var _player_two_label: Label
var _event_log: RichTextLabel
var _guide_label: Label
var _sidebar_scroll: ScrollContainer
var _board_meta_label: Label
var _board_hint_label: Label
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
var _mini_board_holder: Control
var _mini_board_view: BoardDebugView
var _ability_button: Button
var _debug_panel: PanelContainer
var _debug_label: Label
var _action_mode: String = ""
var _selected_actor_id: String = ""
var _autoplay_enabled: bool = false
var _autoplay_speed_index: int = 1
var _guide_visible: bool = false
var _presentation_locked: bool = false
var _debug_visible: bool = false


func _ready() -> void:
	AppState.apply_window_preferences(self)
	_reset_match()
	AudioManager.play_match_music()
	theme = _build_match_theme()
	_build_layout()
	_refresh_view()


func _build_layout() -> void:
	var background := ColorRect.new()
	background.color = COLOR_BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root_margin := MarginContainer.new()
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 16)
	root_margin.add_theme_constant_override("margin_top", 16)
	root_margin.add_theme_constant_override("margin_right", 16)
	root_margin.add_theme_constant_override("margin_bottom", 16)
	add_child(root_margin)

	var root_layout := VBoxContainer.new()
	root_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_layout.add_theme_constant_override("separation", 12)
	root_margin.add_child(root_layout)

	var top_panel := _make_panel_card(COLOR_BORDER, COLOR_SURFACE_ALT)
	top_panel.custom_minimum_size = Vector2(0, 80)
	root_layout.add_child(top_panel)
	var top_margin := _wrap_panel_content(top_panel, 18, 12)
	var top_bar := HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 16)
	top_margin.add_child(top_bar)

	var top_left := VBoxContainer.new()
	top_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_left.add_theme_constant_override("separation", 2)
	top_bar.add_child(top_left)

	_turn_label = Label.new()
	_turn_label.add_theme_font_override("font", FONT_BOLD)
	_turn_label.add_theme_font_size_override("font_size", 22)
	top_left.add_child(_turn_label)

	_objective_label = Label.new()
	_objective_label.add_theme_font_override("font", FONT_MEDIUM)
	_objective_label.add_theme_font_size_override("font_size", 14)
	_objective_label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	top_left.add_child(_objective_label)

	_score_label = Label.new()
	_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_score_label.custom_minimum_size = Vector2(180, 0)
	_score_label.add_theme_font_override("font", FONT_SEMIBOLD)
	_score_label.add_theme_font_size_override("font_size", 20)
	_score_label.add_theme_color_override("font_color", Color("d7d3c6"))
	top_bar.add_child(_score_label)

	var top_right := VBoxContainer.new()
	top_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_right.alignment = BoxContainer.ALIGNMENT_END
	top_right.add_theme_constant_override("separation", 2)
	top_bar.add_child(top_right)

	_hp_summary_label = Label.new()
	_hp_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hp_summary_label.add_theme_font_override("font", FONT_SEMIBOLD)
	_hp_summary_label.add_theme_font_size_override("font_size", 16)
	top_right.add_child(_hp_summary_label)

	_units_label = Label.new()
	_units_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_units_label.add_theme_font_override("font", FONT_MEDIUM)
	_units_label.add_theme_font_size_override("font_size", 14)
	_units_label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	top_right.add_child(_units_label)

	var content := HBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	root_layout.add_child(content)

	var board_frame := _make_panel_card(COLOR_BORDER, Color("101927"))
	board_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(board_frame)
	var board_margin := _wrap_panel_content(board_frame, 0, 0)
	var board_surface := Control.new()
	board_surface.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_surface.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_margin.add_child(board_surface)

	_board_holder = Control.new()
	_board_holder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_board_holder.clip_contents = false
	_board_holder.resized.connect(_on_board_holder_resized)
	board_surface.add_child(_board_holder)

	_board_view = BoardDebugView.new()
	_board_view.set_game_state(_game_state)
	_board_view.hovered_cell_changed.connect(_on_hover_summary_changed)
	_board_view.selected_cell_changed.connect(_on_selected_summary_changed)
	_board_view.cell_clicked.connect(_on_board_cell_clicked)
	_board_holder.add_child(_board_view)

	var side_scroll := ScrollContainer.new()
	side_scroll.custom_minimum_size = Vector2(248, 0)
	side_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(side_scroll)

	var side_rail := VBoxContainer.new()
	side_rail.custom_minimum_size = Vector2(238, 0)
	side_rail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_rail.add_theme_constant_override("separation", 12)
	side_scroll.add_child(side_rail)

	var info_panel := _make_panel_card(COLOR_BORDER, COLOR_SURFACE_ALT)
	side_rail.add_child(info_panel)
	var info_margin := _wrap_panel_content(info_panel, 14, 14)
	var info_layout := VBoxContainer.new()
	info_layout.add_theme_constant_override("separation", 8)
	info_margin.add_child(info_layout)

	var selected_title := _make_section_title("Selected Unit")
	info_layout.add_child(selected_title)
	info_layout.add_child(_make_section_divider())

	_selected_model_name_label = Label.new()
	_selected_model_name_label.add_theme_font_override("font", FONT_BOLD)
	_selected_model_name_label.add_theme_font_size_override("font_size", 20)
	info_layout.add_child(_selected_model_name_label)

	_selected_model_role_label = Label.new()
	_selected_model_role_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_selected_model_role_label.add_theme_font_override("font", FONT_MEDIUM)
	_selected_model_role_label.add_theme_font_size_override("font_size", 13)
	_selected_model_role_label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	info_layout.add_child(_selected_model_role_label)

	_status_label = _make_body_label()
	info_layout.add_child(_status_label)

	var objective_panel := _make_panel_card(COLOR_BORDER, COLOR_SURFACE)
	side_rail.add_child(objective_panel)
	var objective_margin := _wrap_panel_content(objective_panel, 14, 12)
	var objective_layout := VBoxContainer.new()
	objective_layout.add_theme_constant_override("separation", 8)
	objective_margin.add_child(objective_layout)
	objective_layout.add_child(_make_section_title("Objective"))
	objective_layout.add_child(_make_section_divider())
	_preview_label = _make_body_label()
	objective_layout.add_child(_preview_label)

	var log_panel := _make_panel_card(COLOR_BORDER, COLOR_SURFACE)
	log_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_rail.add_child(log_panel)
	var log_margin := _wrap_panel_content(log_panel, 14, 12)
	var log_layout := VBoxContainer.new()
	log_layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_layout.add_theme_constant_override("separation", 10)
	log_margin.add_child(log_layout)
	log_layout.add_child(_make_section_title("Recent Events"))
	log_layout.add_child(_make_section_divider())

	_event_log = RichTextLabel.new()
	_event_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_event_log.fit_content = false
	_event_log.scroll_following = true
	_event_log.bbcode_enabled = true
	_event_log.add_theme_font_override("normal_font", FONT_REGULAR)
	_event_log.add_theme_font_size_override("normal_font_size", 14)
	log_layout.add_child(_event_log)

	var overlay_layer := Control.new()
	overlay_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_child(overlay_layer)

	var overlay_margin := MarginContainer.new()
	overlay_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_margin.add_theme_constant_override("margin_top", 92)
	overlay_margin.add_theme_constant_override("margin_right", 0)
	overlay_margin.add_theme_constant_override("margin_bottom", 88)
	overlay_layer.add_child(overlay_margin)

	var overlay_row := HBoxContainer.new()
	overlay_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	overlay_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	overlay_margin.add_child(overlay_row)

	var overlay_spacer := Control.new()
	overlay_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	overlay_row.add_child(overlay_spacer)

	_debug_panel = _make_panel_card(COLOR_GOLD.darkened(0.28), COLOR_SURFACE)
	_debug_panel.visible = false
	_debug_panel.custom_minimum_size = Vector2(320, 0)
	overlay_row.add_child(_debug_panel)
	var debug_scroll := ScrollContainer.new()
	debug_scroll.custom_minimum_size = Vector2(0, 360)
	debug_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_debug_panel.add_child(debug_scroll)
	var debug_margin := MarginContainer.new()
	debug_margin.add_theme_constant_override("margin_left", 16)
	debug_margin.add_theme_constant_override("margin_top", 14)
	debug_margin.add_theme_constant_override("margin_right", 16)
	debug_margin.add_theme_constant_override("margin_bottom", 14)
	debug_scroll.add_child(debug_margin)
	var debug_layout := VBoxContainer.new()
	debug_layout.add_theme_constant_override("separation", 8)
	debug_margin.add_child(debug_layout)
	debug_layout.add_child(_make_section_title("Debug Panel (Shift+F3)"))

	_debug_label = _make_body_label()
	debug_layout.add_child(_debug_label)

	_hover_label = _make_body_label()
	debug_layout.add_child(_hover_label)
	_selected_label = _make_body_label()
	debug_layout.add_child(_selected_label)

	_map_label = _make_body_label()
	debug_layout.add_child(_map_label)

	var debug_controls := HBoxContainer.new()
	debug_controls.add_theme_constant_override("separation", 8)
	debug_layout.add_child(debug_controls)

	_ai_move_button = _make_action_button("Step AI", COLOR_GOLD)
	_ai_move_button.custom_minimum_size = Vector2(92, 40)
	_ai_move_button.pressed.connect(_on_ai_move_pressed)
	_wire_button_audio(_ai_move_button)
	debug_controls.add_child(_ai_move_button)

	_autoplay_button = _make_action_button("Auto", COLOR_P1)
	_autoplay_button.custom_minimum_size = Vector2(82, 40)
	_autoplay_button.pressed.connect(_on_autoplay_pressed)
	_wire_button_audio(_autoplay_button)
	debug_controls.add_child(_autoplay_button)

	_speed_button = _make_action_button("Speed", COLOR_P2)
	_speed_button.custom_minimum_size = Vector2(82, 40)
	_speed_button.pressed.connect(_on_speed_pressed)
	_wire_button_audio(_speed_button)
	debug_controls.add_child(_speed_button)

	var debug_controls_bottom := HBoxContainer.new()
	debug_controls_bottom.add_theme_constant_override("separation", 8)
	debug_layout.add_child(debug_controls_bottom)

	_reset_button = _make_action_button("Reset", COLOR_BORDER.lightened(0.18))
	_reset_button.custom_minimum_size = Vector2(82, 40)
	_reset_button.pressed.connect(_on_reset_pressed)
	_wire_button_audio(_reset_button)
	debug_controls_bottom.add_child(_reset_button)

	var back_button := _make_action_button("Back", COLOR_BORDER.lightened(0.12))
	back_button.custom_minimum_size = Vector2(82, 40)
	back_button.pressed.connect(_on_back_pressed)
	_wire_button_audio(back_button, true)
	debug_controls_bottom.add_child(back_button)

	var quit_button := _make_action_button("Quit", COLOR_P2.darkened(0.18))
	quit_button.custom_minimum_size = Vector2(82, 40)
	quit_button.pressed.connect(_on_quit_pressed)
	_wire_button_audio(quit_button, true)
	debug_controls_bottom.add_child(quit_button)

	_mini_board_holder = Control.new()
	_mini_board_holder.custom_minimum_size = Vector2(120, 120)
	_mini_board_holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_mini_board_holder.resized.connect(_recenter_mini_board)
	debug_layout.add_child(_mini_board_holder)

	_mini_board_view = BoardDebugView.new()
	_mini_board_view.hex_size = 8.0
	_mini_board_view.interaction_enabled = false
	_mini_board_view.set_game_state(_game_state)
	_mini_board_holder.add_child(_mini_board_view)

	var bottom_panel := _make_panel_card(COLOR_BORDER, COLOR_SURFACE_ALT)
	bottom_panel.custom_minimum_size = Vector2(0, 84)
	root_layout.add_child(bottom_panel)
	var bottom_margin := _wrap_panel_content(bottom_panel, 16, 14)
	var bottom_row := HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 14)
	bottom_margin.add_child(bottom_row)

	var left_spacer := Control.new()
	left_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_row.add_child(left_spacer)

	var controls_row := HBoxContainer.new()
	controls_row.add_theme_constant_override("separation", 12)
	bottom_row.add_child(controls_row)

	_move_button = _make_action_button("Move", COLOR_GREEN)
	_move_button.custom_minimum_size = Vector2(154, 52)
	_move_button.pressed.connect(_on_move_mode_pressed)
	_wire_button_audio(_move_button)
	controls_row.add_child(_move_button)

	_attack_button = _make_action_button("Attack", COLOR_ATTACK)
	_attack_button.custom_minimum_size = Vector2(154, 52)
	_attack_button.pressed.connect(_on_attack_mode_pressed)
	_wire_button_audio(_attack_button)
	controls_row.add_child(_attack_button)

	_ability_button = _make_action_button("Ability", COLOR_GOLD)
	_ability_button.custom_minimum_size = Vector2(154, 52)
	_ability_button.disabled = true
	controls_row.add_child(_ability_button)

	_pass_button = _make_action_button("End Turn", COLOR_GOLD)
	_pass_button.custom_minimum_size = Vector2(172, 52)
	_pass_button.pressed.connect(_on_pass_pressed)
	_wire_button_audio(_pass_button)
	controls_row.add_child(_pass_button)

	var right_spacer := Control.new()
	right_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_row.add_child(right_spacer)

	_control_strip_label = null

	_autoplay_timer = Timer.new()
	_autoplay_timer.one_shot = true
	_autoplay_timer.timeout.connect(_on_autoplay_timer_timeout)
	add_child(_autoplay_timer)

	call_deferred("_recenter_board_view")
	call_deferred("_recenter_mini_board")


func _build_match_theme() -> Theme:
	var match_theme := Theme.new()
	match_theme.default_font = FONT_REGULAR
	match_theme.default_font_size = 16
	match_theme.set_font("font", "Label", FONT_REGULAR)
	match_theme.set_font("font", "Button", FONT_SEMIBOLD)
	match_theme.set_font("font", "ItemList", FONT_MEDIUM)
	match_theme.set_font("font", "RichTextLabel", FONT_REGULAR)
	match_theme.set_color("font_color", "Label", COLOR_TEXT)
	match_theme.set_color("font_color", "Button", COLOR_TEXT)
	match_theme.set_color("font_hover_color", "Button", Color.WHITE)
	match_theme.set_color("font_pressed_color", "Button", Color.WHITE)
	match_theme.set_color("font_disabled_color", "Button", COLOR_TEXT_MUTED)
	match_theme.set_color("font_placeholder_color", "Label", COLOR_TEXT_MUTED)
	match_theme.set_color("font_color", "ItemList", COLOR_TEXT)
	match_theme.set_color("font_selected_color", "ItemList", Color.WHITE)
	match_theme.set_color("font_hovered_color", "ItemList", Color.WHITE)
	match_theme.set_color("guide_color", "RichTextLabel", COLOR_TEXT_MUTED)
	match_theme.set_color("default_color", "RichTextLabel", COLOR_TEXT)
	match_theme.set_color("font_color", "RichTextLabel", COLOR_TEXT)

	var item_list_style := _panel_style(COLOR_BORDER, COLOR_SURFACE) as StyleBoxTexture
	item_list_style.content_margin_left = 10.0
	item_list_style.content_margin_top = 8.0
	item_list_style.content_margin_right = 10.0
	item_list_style.content_margin_bottom = 8.0
	match_theme.set_stylebox("panel", "ItemList", item_list_style)

	var item_focus: StyleBoxTexture = item_list_style.duplicate() as StyleBoxTexture
	match_theme.set_stylebox("focus", "ItemList", item_focus)

	return match_theme


func _make_panel_card(accent_color: Color, fill_color: Color = COLOR_SURFACE) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(accent_color, fill_color))
	return panel


func _wrap_panel_content(panel: PanelContainer, horizontal_margin: int, vertical_margin: int) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", horizontal_margin)
	margin.add_theme_constant_override("margin_top", vertical_margin)
	margin.add_theme_constant_override("margin_right", horizontal_margin)
	margin.add_theme_constant_override("margin_bottom", vertical_margin)
	panel.add_child(margin)
	return margin


func _panel_style(_accent_color: Color, _fill_color: Color = COLOR_SURFACE) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = TEXTURE_PANEL_MAIN
	style.texture_margin_left = 26.0
	style.texture_margin_top = 24.0
	style.texture_margin_right = 26.0
	style.texture_margin_bottom = 24.0
	style.content_margin_left = 4.0
	style.content_margin_top = 4.0
	style.content_margin_right = 4.0
	style.content_margin_bottom = 4.0
	return style


func _make_section_title(title_text: String) -> Label:
	var label := Label.new()
	label.text = title_text.to_upper()
	label.add_theme_font_override("font", FONT_SEMIBOLD)
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color("9ec8ff"))
	return label


func _make_section_divider() -> TextureRect:
	var divider := TextureRect.new()
	divider.texture = TEXTURE_DIVIDER
	divider.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	divider.stretch_mode = TextureRect.STRETCH_SCALE
	divider.custom_minimum_size = Vector2(0, 6)
	divider.modulate = Color(0.72, 0.83, 1.0, 0.34)
	return divider


func _make_body_label() -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", FONT_REGULAR)
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", COLOR_TEXT)
	return label


func _make_action_button(text_value: String, accent_color: Color) -> Button:
	var button := Button.new()
	var use_emphasis := text_value == "End Turn"
	button.text = text_value.to_upper()
	button.custom_minimum_size = Vector2(0, 40)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal", _button_style(TEXTURE_BUTTON_EMPHASIS if use_emphasis else TEXTURE_BUTTON_PRIMARY))
	button.add_theme_stylebox_override("hover", _button_style(TEXTURE_BUTTON_PRIMARY_HOVER if not use_emphasis else TEXTURE_BUTTON_EMPHASIS))
	button.add_theme_stylebox_override("pressed", _button_style(TEXTURE_BUTTON_PRIMARY_PRESSED if not use_emphasis else TEXTURE_BUTTON_EMPHASIS))
	button.add_theme_stylebox_override("disabled", _button_style(TEXTURE_BUTTON_DISABLED))
	button.add_theme_font_override("font", FONT_SEMIBOLD)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", accent_color.lightened(0.18) if not use_emphasis else Color("fff5d8"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", COLOR_TEXT_MUTED)
	return button


func _button_style(texture: Texture2D) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = 26.0
	style.texture_margin_top = 24.0
	style.texture_margin_right = 26.0
	style.texture_margin_bottom = 24.0
	style.content_margin_left = 20.0
	style.content_margin_top = 10.0
	style.content_margin_right = 20.0
	style.content_margin_bottom = 10.0
	return style


func _refresh_view_legacy() -> void:
	_turn_label.text = "%s Player %d's Turn" % ["◆" if _game_state.current_player == 1 else "◆", _game_state.current_player]
	_turn_label.add_theme_color_override("font_color", COLOR_P1 if _game_state.current_player == 1 else COLOR_P2)
	_objective_label.text = "Turn %d" % _game_state.turn_count
	_score_label.text = "★ P1=%d  P2=%d" % [_control_score_for_player(1), _control_score_for_player(2)]
	_hp_summary_label.text = _hp_summary_text()
	_control_strip_label.text = "M=Move  A=Attack  P=Pass  Space=Step AI  Z=Auto  R=Reset  H=Guide"
	_map_label.text = _game_state.board.map_display_name
	_board_meta_label = null
	_board_hint_label = null
	_player_one_label = null
	_player_two_label = null
	_ai_label = null
	_explanation_label = null
	_preview_label = null
	_stats_label = null
	_post_match_label = null
	_guide_label = null
	_history_list = null
	_history_detail_label = null

	if _game_state.game_over:
		_status_label.text = "Game Over: %s" % _winner_label()
	elif _autoplay_enabled:
		_status_label.text = "Autoplay running at %s speed." % AUTOPLAY_SPEED_LABELS[_autoplay_speed_index]
	else:
		if _presentation_locked:
			_status_label.text = "Resolving action..."
		else:
			_status_label.text = "Selected: %s | Mode: %s" % [
				_actor_label(_selected_actor_id) if _selected_actor_id != "" else "None",
				_action_mode.capitalize() if _action_mode != "" else "None",
			]

	_board_view.set_game_state(_game_state)
	_board_view.set_selected_actor(_selected_actor_id)
	_board_view.set_action_mode(_action_mode)
	_board_view.set_highlighted_cells(_build_highlight_map())
	_mini_board_view.set_game_state(_game_state)
	_mini_board_view.set_selected_actor(_selected_actor_id)
	_mini_board_view.set_action_mode("")
	_mini_board_view.set_highlighted_cells({})
	_refresh_selected_unit_panel()
	_recenter_board_view()
	_recenter_mini_board()
	_refresh_event_log()
	_update_button_state()
	_autoplay_button.text = "Auto %s" % ("On" if _autoplay_enabled else "Off")
	_speed_button.text = AUTOPLAY_SPEED_LABELS[_autoplay_speed_index]


func _refresh_view() -> void:
	_turn_label.text = "Turn %d  |  %s" % [_game_state.turn_count, "Blue Command" if _game_state.current_player == 1 else "Red Command"]
	_turn_label.add_theme_color_override("font_color", COLOR_P1 if _game_state.current_player == 1 else COLOR_P2)
	_objective_label.text = _phase_text()
	_score_label.text = "Score  P1 %d  :  %d P2" % [_control_score_for_player(1), _control_score_for_player(2)]
	_hp_summary_label.text = _hp_summary_text()
	_units_label.text = _remaining_units_text()
	_map_label.text = "Map: %s\nController: P1 %s | P2 %s\nShift+F3 toggles debug controls." % [
		_game_state.board.map_display_name,
		_controller_label(AppState.current_match_config.player_one_ai.controller_type),
		_controller_label(AppState.current_match_config.player_two_ai.controller_type),
	]
	if _debug_panel != null:
		_debug_panel.visible = _debug_visible

	_preview_label.text = _objective_text()

	_board_view.set_game_state(_game_state)
	_board_view.set_selected_actor(_selected_actor_id)
	_board_view.set_action_mode(_action_mode)
	_board_view.set_highlighted_cells(_build_highlight_map())
	_mini_board_view.set_game_state(_game_state)
	_mini_board_view.set_selected_actor(_selected_actor_id)
	_mini_board_view.set_action_mode("")
	_mini_board_view.set_highlighted_cells({})
	_refresh_selected_unit_panel()
	_recenter_board_view()
	_recenter_mini_board()
	_refresh_event_log()
	_refresh_debug_panel()
	_update_button_state()
	_autoplay_button.text = "Auto %s" % ("On" if _autoplay_enabled else "Off")
	_speed_button.text = AUTOPLAY_SPEED_LABELS[_autoplay_speed_index]


func _control_score_for_player(player_id: int) -> int:
	var center := HexCoord.new()
	var score: int = 0
	for tank: TankData in _game_state.get_player_tanks(player_id):
		if not tank.is_alive():
			continue
		score += maxi(0, 6 - tank.position.distance_to(center))
		if tank.tank_type == GameTypes.TankType.KTANK:
			score += 1
	return score


func _hp_summary_text() -> String:
	var p1k: TankData = _find_tank(1, GameTypes.TankType.KTANK)
	var p1q: TankData = _find_tank(1, GameTypes.TankType.QTANK)
	var p2k: TankData = _find_tank(2, GameTypes.TankType.KTANK)
	var p2q: TankData = _find_tank(2, GameTypes.TankType.QTANK)
	return "P1K %s/%s   P1Q %s/%s      P2K %s/%s   P2Q %s/%s" % [
		p1k.hp if p1k != null else 0,
		p1k.max_hp if p1k != null else 0,
		p1q.hp if p1q != null else 0,
		p1q.max_hp if p1q != null else 0,
		p2k.hp if p2k != null else 0,
		p2k.max_hp if p2k != null else 0,
		p2q.hp if p2q != null else 0,
		p2q.max_hp if p2q != null else 0,
	]


func _remaining_units_text() -> String:
	return "Units  P1 %d/2   P2 %d/2" % [_game_state.get_player_tanks(1).size(), _game_state.get_player_tanks(2).size()]


func _phase_text() -> String:
	var total_units: int = _game_state.get_player_tanks(1).size() + _game_state.get_player_tanks(2).size()
	if total_units <= 2:
		return "Endgame Phase"
	if _game_state.turn_count <= 5:
		return "Opening Phase"
	return "Midgame Phase"


func _build_highlight_map() -> Dictionary:
	var highlights: Dictionary = {}
	var selected_color: Color = Color("7bdcff") if AppState.high_contrast_mode else Color("69d2ff")
	var move_color: Color = Color("95ff5f") if AppState.high_contrast_mode else Color("57d477")
	var attack_color: Color = Color("ffb347") if AppState.high_contrast_mode else Color("ff6978")
	if _selected_actor_id == "":
		for tank: TankData in _game_state.get_player_tanks(_game_state.current_player):
			highlights[tank.position.key()] = selected_color
		return highlights

	var selected_tank: TankData = _game_state.get_tank(_selected_actor_id)
	if selected_tank != null:
		highlights[selected_tank.position.key()] = selected_color

	match _action_mode:
		"move":
			for coord: HexCoord in _game_state.get_legal_move_targets(_selected_actor_id):
				highlights[coord.key()] = move_color
		"attack":
			for coord: HexCoord in _game_state.get_legal_attack_targets(_selected_actor_id):
				highlights[coord.key()] = attack_color

	return highlights


func _refresh_event_log() -> void:
	var lines: Array[String] = []
	var turns: Array = AppState.current_replay.turns
	if turns.is_empty():
		_event_log.text = "[color=#8ea3bf]No actions taken yet.[/color]"
		return

	var start_index: int = maxi(0, turns.size() - 6)
	for turn_index in range(turns.size() - 1, start_index - 1, -1):
		var turn_data: Dictionary = turns[turn_index]
		var player_id: int = int(turn_data.get("player", 0))
		var player_color: String = "77b8ff" if player_id == 1 else "ff8a76"
		var events: Array = turn_data.get("events", [])
		for event_line: Variant in events:
			lines.append("[color=#5d6f88]T%d[/color] [color=#%s]%s[/color]" % [turn_data.get("turn", 0), player_color, str(event_line)])
	if lines.size() > 6:
		lines = lines.slice(lines.size() - 6, lines.size())

	_event_log.text = "\n".join(lines)


func _refresh_selected_unit_panel() -> void:
	var focus_tank: TankData = _current_focus_tank()
	if focus_tank == null:
		_selected_model_name_label.text = "No active selection"
		_selected_model_role_label.text = "Select a unit to inspect combat and movement details."
		_status_label.text = "Integrity  -\nMobility  -\nStrike  -\nStatus  -"
		return

	_selected_model_name_label.text = _unit_card_name(focus_tank)
	_selected_model_role_label.text = _unit_role_text(focus_tank)
	_status_label.text = "Integrity  %d/%d\nMobility  %d hexes\nStrike  %d dmg\nStatus  %s" % [
		focus_tank.hp,
		focus_tank.max_hp,
		focus_tank.get_move_range(),
		focus_tank.get_attack_damage(),
		_buff_label(focus_tank.active_buff),
	]


func _refresh_debug_panel() -> void:
	if _debug_label == null:
		return
	_debug_label.text = "Current Player: P%d\nAction Mode: %s\nAutoplay: %s\nPresentation Locked: %s" % [
		_game_state.current_player,
		_action_mode if _action_mode != "" else "none",
		"On" if _autoplay_enabled else "Off",
		"Yes" if _presentation_locked else "No",
	]


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
	var can_act: bool = not _game_state.game_over and not _autoplay_enabled and not _presentation_locked and _selected_actor_id != ""
	_move_button.disabled = not can_act
	_attack_button.disabled = not can_act
	_ability_button.disabled = true
	_pass_button.disabled = _game_state.game_over or _autoplay_enabled or _presentation_locked
	_reset_button.disabled = _presentation_locked
	_ai_move_button.disabled = _game_state.game_over or _autoplay_enabled or _presentation_locked or _current_player_controller_type() == GameTypes.ControllerType.HUMAN
	_autoplay_button.disabled = _game_state.game_over or _presentation_locked or not _both_players_are_ai()


func _on_board_cell_clicked(coord_key: String) -> void:
	if _presentation_locked:
		return
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
	_debug_visible = false
	_action_mode = "move"
	_refresh_view()


func _on_attack_mode_pressed() -> void:
	if _selected_actor_id == "":
		return
	_debug_visible = false
	_action_mode = "attack"
	_refresh_view()


func _on_pass_pressed() -> void:
	_debug_visible = false
	var action: ActionData = ActionData.new(GameTypes.ActionType.PASS)
	_execute_action(action, "Human", _manual_explanation(action))


func _on_reset_pressed() -> void:
	if _presentation_locked:
		return
	_debug_visible = false
	_disable_autoplay()
	_reset_match()
	_refresh_view()


func _on_ai_move_pressed() -> void:
	_debug_visible = false
	_step_current_ai_turn()


func _on_autoplay_pressed() -> void:
	_debug_visible = false
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


func _on_guide_pressed() -> void:
	_guide_visible = not _guide_visible
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
	if _presentation_locked:
		return
	_debug_visible = false
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
	_presentation_locked = false
	_debug_visible = false
	if _board_view != null:
		_board_view.clear_transient_effects()
	AppState.last_action_explanation = ActionExplanation.new()
	AppState.current_replay.clear()
	AppState.current_replay.metadata = {
		"map_id": _game_state.board.map_id,
		"map_name": _game_state.board.map_display_name,
		"player_one_controller": _controller_label(AppState.current_match_config.player_one_ai.controller_type),
		"player_two_controller": _controller_label(AppState.current_match_config.player_two_ai.controller_type),
		"initial_state": _game_state.to_snapshot(),
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


func _on_quit_pressed() -> void:
	_disable_autoplay()
	get_tree().quit()


func _on_board_holder_resized() -> void:
	_recenter_board_view()


func _recenter_mini_board() -> void:
	if _mini_board_view == null or _mini_board_holder == null:
		return

	var holder_size: Vector2 = _mini_board_holder.size
	if holder_size.x <= 0.0 or holder_size.y <= 0.0:
		return

	var visual_size: Vector2 = _mini_board_view.get_board_visual_size()
	var width_scale: float = holder_size.x / maxf(visual_size.x, 1.0)
	var height_scale: float = holder_size.y / maxf(visual_size.y, 1.0)
	var scale_factor: float = clampf(minf(width_scale, height_scale), 0.12, 0.24)
	_mini_board_view.scale = Vector2.ONE * scale_factor
	_mini_board_view.position = holder_size * 0.5


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
	if _presentation_locked:
		return
	_presentation_locked = true
	var acting_turn: int = _game_state.turn_count
	var acting_player: int = _game_state.current_player
	var previous_state: GameState = _game_state.clone()
	_game_state.apply_action(action)
	AudioManager.play_action_feedback(previous_state, _game_state, action, _game_state.last_events)
	_board_view.play_action_feedback(previous_state, _game_state, action, _game_state.last_events)
	var feedback_hold: float = _board_view.get_feedback_hold_seconds(action, previous_state)
	if _game_state.game_over:
		_disable_autoplay()
		AppState.current_replay.winner_label = _winner_label()
		AppState.current_replay.metadata["winner_label"] = AppState.current_replay.winner_label
	AppState.last_action_explanation = explanation
	EventBus.action_explanation_updated.emit(explanation)
	_record_turn_snapshot(acting_turn, acting_player, source_label, action, explanation)
	_refresh_view()
	await get_tree().create_timer(feedback_hold).timeout
	_presentation_locked = false
	_after_action()


func _record_turn_snapshot(acting_turn: int, acting_player: int, source_label: String, action: ActionData, explanation: ActionExplanation) -> void:
	var event_lines: Array[String] = []
	var event_data: Array[Dictionary] = []
	for event_item: GameEvent in _game_state.last_events:
		event_lines.append(_format_event(event_item))
		event_data.append({
			"event_name": event_item.event_name,
			"payload": event_item.payload.duplicate(true),
		})

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
		"event_data": event_data,
		"state_hash": _game_state.get_state_hash(),
		"state_snapshot": _game_state.to_snapshot(),
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
		return "Arena Stats: no recorded turns yet.\nUse Step AI or Auto to begin.\nAccessibility: UI %.2fx | Motion %s | Contrast %s" % [
			AppState.ui_scale,
			"Reduced" if AppState.reduced_motion else "Standard",
			"High" if AppState.high_contrast_mode else "Standard",
		]

	var latest: Dictionary = AppState.current_replay.turns[total_turns - 1]
	var analytics: Dictionary = ReplayAnalytics.build_summary(AppState.current_replay)
	var damage_bucket: Dictionary = analytics.get("player_damage", {})
	return "Arena Stats: %d recorded turns\nLatest: T%d P%d via %s\nState Hash: %s\nDamage P1/P2: %d / %d\nAccessibility: UI %.2fx | Motion %s | Contrast %s" % [
		total_turns,
		latest.get("turn", 0),
		latest.get("player", 0),
		latest.get("source", "Unknown"),
		latest.get("state_hash", ""),
		int(damage_bucket.get(1, 0)),
		int(damage_bucket.get(2, 0)),
		AppState.ui_scale,
		"Reduced" if AppState.reduced_motion else "Standard",
		"High" if AppState.high_contrast_mode else "Standard",
	]


func _post_match_text() -> String:
	if not _game_state.game_over:
		return ""
	return "Post-Match Summary:\n%s" % ReplayAnalytics.format_summary_text(ReplayAnalytics.build_summary(AppState.current_replay))


func _objective_text() -> String:
	return "Destroy the enemy Ktank or move your own Ktank onto the center hex."


func _player_summary_text(player_id: int) -> String:
	var controller_type: int = _game_state.get_ai_config_for_player(player_id).controller_type
	var summary_lines: Array[String] = []
	summary_lines.append("%s pilot stack" % _controller_label(controller_type))

	var ktank: TankData = _find_tank(player_id, GameTypes.TankType.KTANK)
	var qtank: TankData = _find_tank(player_id, GameTypes.TankType.QTANK)
	if ktank != null:
		summary_lines.append("Ktank %s HP | Center %d | %s" % [ktank.hp, ktank.position.distance_to(HexCoord.new()), _buff_label(ktank.active_buff)])
	if qtank != null:
		summary_lines.append("Qtank %s HP | %s" % [qtank.hp, _buff_label(qtank.active_buff)])

	var total_hp: int = 0
	for tank: TankData in _game_state.get_player_tanks(player_id):
		total_hp += tank.hp
	summary_lines.append("Total %d HP%s" % [total_hp, " | Initiative" if _game_state.current_player == player_id else ""])
	return "\n".join(summary_lines)


func _preview_text() -> String:
	if _autoplay_enabled:
		return "Spectator mode is active. Watch board control swing in the roster strip and inspect choices from Replay and Summary."

	if _selected_actor_id == "":
		return "Select a tank to bring up tactical options. Qtanks dominate lines. Ktanks crack adjacent hexes and convert center pressure into instant wins."

	var tank: TankData = _game_state.get_tank(_selected_actor_id)
	if tank == null:
		return "Preview: Selected tank is no longer available."

	var tank_name: String = "Qtank" if tank.tank_type == GameTypes.TankType.QTANK else "Ktank"
	var move_count: int = _game_state.get_legal_move_targets(_selected_actor_id).size()
	var attack_count: int = _game_state.get_legal_attack_targets(_selected_actor_id).size()
	var base_text: String = "%s | %s HP | %s | %d moves | %d attack targets." % [tank_name, tank.hp, _buff_label(tank.active_buff), move_count, attack_count]

	match _action_mode:
		"move":
			var can_reach_center: bool = false
			for coord: HexCoord in _game_state.get_legal_move_targets(_selected_actor_id):
				if coord.q == 0 and coord.r == 0:
					can_reach_center = true
					break
			return "%s Move mode engaged.%s" % [base_text, " Center is reachable this turn." if can_reach_center else ""]
		"attack":
			return "%s Attack mode engaged. Highlighted hexes show the live threat lane." % base_text
		_:
			return "%s Choose Move, Attack, or Pass." % base_text


func _guide_text() -> String:
	return "Quick Guide:\n- Center wins instantly for a Ktank, so mid-board tempo matters from turn one.\n- Qtank lasers stop at the first tank or blocking cell, making line control the core spacing puzzle.\n- Ktank attacks every adjacent hex, including allies, so heavy pressure can backfire.\n- Standard flow is one action per turn. Bonus Move is the main exception.\n- Minimax usually excels in sharp tactical fights. MCTS becomes more dangerous on larger, noisier maps."


func _current_focus_tank() -> TankData:
	if _selected_actor_id != "":
		var selected_tank: TankData = _game_state.get_tank(_selected_actor_id)
		if selected_tank != null and selected_tank.is_alive():
			return selected_tank

	for tank: TankData in _game_state.get_player_tanks(_game_state.current_player):
		if tank.is_alive():
			return tank
	return null


func _unit_card_name(tank: TankData) -> String:
	var unit_name: String = "Qtank" if tank.tank_type == GameTypes.TankType.QTANK else "Ktank"
	return "Player %d %s" % [tank.owner_id, unit_name]


func _unit_role_text(tank: TankData) -> String:
	if tank.tank_type == GameTypes.TankType.QTANK:
		return "Long-range control tank. Strongest on clean lanes."
	return "Heavy objective tank. Breaks space and threatens center wins."


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
	var scale_factor: float = clampf(minf(width_scale, height_scale), 1.0, 2.15)
	_board_view.scale = Vector2.ONE * scale_factor
	_board_view.position = Vector2(holder_size.x * 0.5, holder_size.y * 0.5)


func _reset_sidebar_scroll() -> void:
	if _sidebar_scroll != null:
		_sidebar_scroll.scroll_vertical = 0


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.pressed or event.echo:
		return

	match event.keycode:
		KEY_F3:
			if event.shift_pressed:
				_debug_visible = not _debug_visible
				_refresh_view()
				accept_event()
		KEY_M:
			if not _move_button.disabled:
				_on_move_mode_pressed()
				accept_event()
		KEY_A:
			if not _attack_button.disabled:
				_on_attack_mode_pressed()
				accept_event()
		KEY_P:
			if not _pass_button.disabled:
				_on_pass_pressed()
				accept_event()
		KEY_SPACE:
			if not _ai_move_button.disabled:
				_on_ai_move_pressed()
				accept_event()
		KEY_Z:
			if not _autoplay_button.disabled:
				_on_autoplay_pressed()
				accept_event()
		KEY_R:
			if not _presentation_locked:
				_on_reset_pressed()
				accept_event()
		KEY_H:
			get_tree().change_scene_to_file(AppState.HELP_SCENE)
			accept_event()
		KEY_ESCAPE:
			get_tree().change_scene_to_file(MENU_SCENE)
			accept_event()


func _wire_button_audio(button: Button, use_back_sound: bool = false) -> void:
	if button == null:
		return
	button.mouse_entered.connect(AudioManager.play_ui_hover)
	if use_back_sound:
		button.pressed.connect(AudioManager.play_ui_back)
	else:
		button.pressed.connect(AudioManager.play_ui_click)
