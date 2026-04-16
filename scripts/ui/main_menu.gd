extends Control

const MATCH_SCENE := "res://scenes/match/match_root.tscn"
const REPLAY_SCENE := "res://scenes/replay/replay_shell.tscn"
const SETTINGS_SCENE := "res://scenes/settings/settings_root.tscn"
const HELP_SCENE := "res://scenes/help/help_root.tscn"
const FONT_REGULAR := preload("res://assets/fonts/space_grotesk/SpaceGrotesk-Regular.ttf")
const FONT_MEDIUM := preload("res://assets/fonts/space_grotesk/SpaceGrotesk-Medium.ttf")
const FONT_SEMIBOLD := preload("res://assets/fonts/space_grotesk/SpaceGrotesk-SemiBold.ttf")
const FONT_BOLD := preload("res://assets/fonts/space_grotesk/SpaceGrotesk-Bold.ttf")
const COLOR_BG := Color("09111c")
const COLOR_SURFACE := Color("111c2b")
const COLOR_SURFACE_ALT := Color("162335")
const COLOR_BORDER := Color("2c3f59")
const COLOR_TEXT := Color("edf4ff")
const COLOR_TEXT_MUTED := Color("98adc7")
const COLOR_GOLD := Color("f0c05e")
const COLOR_P1 := Color("77b8ff")
const COLOR_P2 := Color("ff8a76")
const COLOR_GREEN := Color("69dd8e")

var _p1_controller: OptionButton
var _p2_controller: OptionButton
var _map_select: OptionButton
var _max_turns_spin: SpinBox
var _p1_depth_spin: SpinBox
var _p2_rollout_spin: SpinBox
var _replay_button: Button
var _summary_label: RichTextLabel


func _ready() -> void:
	AppState.apply_window_preferences(self)
	AudioManager.play_menu_music()
	theme = _build_menu_theme()
	_build_layout()
	_refresh_summary()


func _build_layout() -> void:
	var background := ColorRect.new()
	background.color = COLOR_BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var glow_left := ColorRect.new()
	glow_left.color = Color(0.19, 0.32, 0.48, 0.08)
	glow_left.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glow_left.offset_left = -280
	glow_left.offset_top = 80
	glow_left.offset_right = -980
	glow_left.offset_bottom = -140
	add_child(glow_left)

	var glow_right := ColorRect.new()
	glow_right.color = Color(0.94, 0.75, 0.37, 0.04)
	glow_right.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glow_right.offset_left = 980
	glow_right.offset_top = 0
	glow_right.offset_right = 160
	glow_right.offset_bottom = -320
	add_child(glow_right)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)

	var root_margin := MarginContainer.new()
	root_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_margin.add_theme_constant_override("margin_left", 28)
	root_margin.add_theme_constant_override("margin_top", 28)
	root_margin.add_theme_constant_override("margin_right", 28)
	root_margin.add_theme_constant_override("margin_bottom", 28)
	scroll.add_child(root_margin)

	var root_layout := VBoxContainer.new()
	root_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_layout.add_theme_constant_override("separation", 20)
	root_margin.add_child(root_layout)

	var hero_panel := _make_panel_card(COLOR_GOLD, COLOR_SURFACE_ALT)
	hero_panel.custom_minimum_size = Vector2(0, 192)
	root_layout.add_child(hero_panel)

	var hero_margin := _wrap_panel_content(hero_panel, 28, 26)
	var hero_layout := HBoxContainer.new()
	hero_layout.add_theme_constant_override("separation", 24)
	hero_margin.add_child(hero_layout)

	var hero_left := VBoxContainer.new()
	hero_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_left.add_theme_constant_override("separation", 10)
	hero_layout.add_child(hero_left)

	var eyebrow := Label.new()
	eyebrow.text = "TACTICAL AI ARENA"
	eyebrow.add_theme_font_override("font", FONT_SEMIBOLD)
	eyebrow.add_theme_font_size_override("font_size", 13)
	eyebrow.add_theme_color_override("font_color", COLOR_GOLD)
	hero_left.add_child(eyebrow)

	var title := Label.new()
	title.text = "Hex Siege Arena"
	title.add_theme_font_override("font", FONT_BOLD)
	title.add_theme_font_size_override("font_size", 48)
	hero_left.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Command a four-tank duel across a hex battlefield where Minimax and MCTS fight for center control."
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_override("font", FONT_MEDIUM)
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	hero_left.add_child(subtitle)

	var hero_note := Label.new()
	hero_note.text = "Professional spectator-style prototype with replay support, analytics, audio, accessibility, and AI-vs-AI as the flagship mode."
	hero_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hero_note.add_theme_font_override("font", FONT_REGULAR)
	hero_note.add_theme_font_size_override("font_size", 15)
	hero_note.add_theme_color_override("font_color", Color("d7e3f5"))
	hero_left.add_child(hero_note)

	var hero_right := _make_panel_card(COLOR_BORDER.lightened(0.15), Color("142033"))
	hero_right.custom_minimum_size = Vector2(380, 0)
	hero_layout.add_child(hero_right)

	var hero_right_margin := _wrap_panel_content(hero_right, 20, 18)
	var hero_right_layout := VBoxContainer.new()
	hero_right_layout.add_theme_constant_override("separation", 8)
	hero_right_margin.add_child(hero_right_layout)

	var snapshot_label := Label.new()
	snapshot_label.text = "SESSION SNAPSHOT"
	snapshot_label.add_theme_font_override("font", FONT_SEMIBOLD)
	snapshot_label.add_theme_font_size_override("font_size", 12)
	snapshot_label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	hero_right_layout.add_child(snapshot_label)

	_summary_label = RichTextLabel.new()
	_summary_label.bbcode_enabled = true
	_summary_label.fit_content = true
	_summary_label.scroll_active = false
	_summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_summary_label.add_theme_font_override("normal_font", FONT_MEDIUM)
	_summary_label.add_theme_font_size_override("normal_font_size", 15)
	hero_right_layout.add_child(_summary_label)

	var content_row := HBoxContainer.new()
	content_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_row.add_theme_constant_override("separation", 18)
	root_layout.add_child(content_row)

	var setup_panel := _make_panel_card(COLOR_P1, COLOR_SURFACE)
	setup_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	setup_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_row.add_child(setup_panel)

	var setup_margin := _wrap_panel_content(setup_panel, 24, 22)
	var setup_layout := VBoxContainer.new()
	setup_layout.add_theme_constant_override("separation", 18)
	setup_margin.add_child(setup_layout)

	var setup_header := HBoxContainer.new()
	setup_header.add_theme_constant_override("separation", 12)
	setup_layout.add_child(setup_header)

	var setup_title_block := VBoxContainer.new()
	setup_title_block.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	setup_title_block.add_theme_constant_override("separation", 4)
	setup_header.add_child(setup_title_block)

	var setup_title := Label.new()
	setup_title.text = "Match Setup"
	setup_title.add_theme_font_override("font", FONT_BOLD)
	setup_title.add_theme_font_size_override("font_size", 28)
	setup_title_block.add_child(setup_title)

	var setup_subtitle := Label.new()
	setup_subtitle.text = "Tune both commanders, choose the battleground, and launch straight into the arena."
	setup_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	setup_subtitle.add_theme_font_override("font", FONT_MEDIUM)
	setup_subtitle.add_theme_font_size_override("font_size", 15)
	setup_subtitle.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	setup_title_block.add_child(setup_subtitle)

	var setup_badge := _make_chip("AI-vs-AI Recommended", COLOR_GOLD)
	setup_header.add_child(setup_badge)

	var setup_grid := GridContainer.new()
	setup_grid.columns = 2
	setup_grid.add_theme_constant_override("h_separation", 18)
	setup_grid.add_theme_constant_override("v_separation", 14)
	setup_layout.add_child(setup_grid)

	setup_grid.add_child(_field_label("Player 1 Controller"))
	_p1_controller = _controller_option()
	setup_grid.add_child(_p1_controller)

	setup_grid.add_child(_field_label("Player 2 Controller"))
	_p2_controller = _controller_option()
	setup_grid.add_child(_p2_controller)

	setup_grid.add_child(_field_label("Arena Map"))
	_map_select = OptionButton.new()
	for map_id: String in ["standard", "open", "fortress", "labyrinth"]:
		_map_select.add_item(map_id.capitalize())
		_map_select.set_item_metadata(_map_select.item_count - 1, map_id)
	_map_select.item_selected.connect(_on_setup_changed)
	_style_option_button(_map_select)
	setup_grid.add_child(_map_select)

	setup_grid.add_child(_field_label("Turn Limit"))
	_max_turns_spin = _make_spin_box(20, 200, 5)
	setup_grid.add_child(_max_turns_spin)

	setup_grid.add_child(_field_label("Minimax Depth"))
	_p1_depth_spin = _make_spin_box(1, 6, 1)
	setup_grid.add_child(_p1_depth_spin)

	setup_grid.add_child(_field_label("MCTS Rollouts"))
	_p2_rollout_spin = _make_spin_box(50, 2000, 50)
	setup_grid.add_child(_p2_rollout_spin)

	var action_column := VBoxContainer.new()
	action_column.add_theme_constant_override("separation", 12)
	setup_layout.add_child(action_column)

	var primary_row := HBoxContainer.new()
	primary_row.add_theme_constant_override("separation", 12)
	action_column.add_child(primary_row)
	primary_row.add_child(_make_button("Start Match", _on_open_match_pressed, COLOR_GOLD, 56))

	_replay_button = _make_button("Replay Viewer", _on_open_replay_pressed, COLOR_P1, 56)
	primary_row.add_child(_replay_button)

	var secondary_row := HBoxContainer.new()
	secondary_row.add_theme_constant_override("separation", 12)
	action_column.add_child(secondary_row)
	secondary_row.add_child(_make_button("Quick Start Guide", _on_open_help_pressed, COLOR_GREEN, 46))
	secondary_row.add_child(_make_button("Settings", _on_open_settings_pressed, COLOR_BORDER.lightened(0.18), 46))

	var utility_row := HBoxContainer.new()
	utility_row.add_theme_constant_override("separation", 12)
	action_column.add_child(utility_row)
	utility_row.add_child(_make_button("Reset Runtime State", _on_reset_state_pressed, COLOR_BORDER.lightened(0.10), 44))
	utility_row.add_child(_make_button("Exit Game", _on_exit_game_pressed, COLOR_P2, 44, true))

	var side_column := VBoxContainer.new()
	side_column.custom_minimum_size = Vector2(360, 0)
	side_column.add_theme_constant_override("separation", 18)
	content_row.add_child(side_column)

	var brief_panel := _make_panel_card(COLOR_BORDER.lightened(0.15), COLOR_SURFACE_ALT)
	side_column.add_child(brief_panel)
	var brief_margin := _wrap_panel_content(brief_panel, 22, 20)
	var brief_layout := VBoxContainer.new()
	brief_layout.add_theme_constant_override("separation", 12)
	brief_margin.add_child(brief_layout)
	brief_layout.add_child(_make_section_heading("Arena Brief"))

	var brief_text := Label.new()
	brief_text.text = "Standard is the cleanest tactical read. Labyrinth adds heavier obstacle pressure and rewards better optimization under uncertainty."
	brief_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	brief_text.add_theme_font_override("font", FONT_REGULAR)
	brief_text.add_theme_font_size_override("font_size", 15)
	brief_text.add_theme_color_override("font_color", COLOR_TEXT)
	brief_layout.add_child(brief_text)

	var start_steps := Label.new()
	start_steps.text = "1. Pick controllers and map.\n2. Launch the match.\n3. Use F3 in-game for extra tools.\n4. Open Replay Viewer after a finished match."
	start_steps.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	start_steps.add_theme_font_override("font", FONT_MEDIUM)
	start_steps.add_theme_font_size_override("font_size", 14)
	start_steps.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	brief_layout.add_child(start_steps)

	var profile_panel := _make_panel_card(COLOR_BORDER, COLOR_SURFACE)
	side_column.add_child(profile_panel)
	var profile_margin := _wrap_panel_content(profile_panel, 22, 20)
	var profile_layout := VBoxContainer.new()
	profile_layout.add_theme_constant_override("separation", 10)
	profile_margin.add_child(profile_layout)
	profile_layout.add_child(_make_section_heading("Saved Profile"))

	var profile_text := Label.new()
	profile_text.text = "Your match setup, accessibility preferences, and audio levels are stored automatically between sessions."
	profile_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	profile_text.add_theme_font_override("font", FONT_REGULAR)
	profile_text.add_theme_font_size_override("font_size", 15)
	profile_text.add_theme_color_override("font_color", COLOR_TEXT)
	profile_layout.add_child(profile_text)

	var support_panel := _make_panel_card(COLOR_BORDER, COLOR_SURFACE)
	side_column.add_child(support_panel)
	var support_margin := _wrap_panel_content(support_panel, 22, 20)
	var support_layout := VBoxContainer.new()
	support_layout.add_theme_constant_override("separation", 10)
	support_margin.add_child(support_layout)
	support_layout.add_child(_make_section_heading("Build Focus"))

	var support_text := Label.new()
	support_text.text = "This version prioritizes a professional board-first match screen, readable AI battles, richer pacing, replay analytics, and a cleaner fullscreen shell."
	support_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	support_text.add_theme_font_override("font", FONT_REGULAR)
	support_text.add_theme_font_size_override("font_size", 15)
	support_text.add_theme_color_override("font_color", COLOR_TEXT)
	support_layout.add_child(support_text)

	_apply_config_to_controls()


func _build_menu_theme() -> Theme:
	var menu_theme := Theme.new()
	menu_theme.default_font = FONT_REGULAR
	menu_theme.default_font_size = 16
	menu_theme.set_font("font", "Label", FONT_REGULAR)
	menu_theme.set_font("font", "Button", FONT_SEMIBOLD)
	menu_theme.set_font("font", "OptionButton", FONT_MEDIUM)
	menu_theme.set_font("font", "SpinBox", FONT_MEDIUM)
	menu_theme.set_font("font", "RichTextLabel", FONT_REGULAR)
	menu_theme.set_color("font_color", "Label", COLOR_TEXT)
	menu_theme.set_color("font_color", "Button", COLOR_TEXT)
	menu_theme.set_color("font_hover_color", "Button", Color.WHITE)
	menu_theme.set_color("font_pressed_color", "Button", Color.WHITE)
	menu_theme.set_color("font_disabled_color", "Button", COLOR_TEXT_MUTED)
	menu_theme.set_color("default_color", "RichTextLabel", COLOR_TEXT)
	menu_theme.set_color("font_color", "RichTextLabel", COLOR_TEXT)
	menu_theme.set_color("font_color", "OptionButton", COLOR_TEXT)
	menu_theme.set_color("font_color", "SpinBox", COLOR_TEXT)
	return menu_theme


func _field_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", FONT_SEMIBOLD)
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
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
	_style_option_button(option)
	return option


func _make_spin_box(min_value: float, max_value: float, step: float) -> SpinBox:
	var spin := SpinBox.new()
	spin.min_value = min_value
	spin.max_value = max_value
	spin.step = step
	spin.value_changed.connect(_on_setup_changed)
	spin.custom_minimum_size = Vector2(0, 44)
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return spin


func _style_option_button(option: OptionButton) -> void:
	option.custom_minimum_size = Vector2(0, 44)
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option.focus_mode = Control.FOCUS_NONE
	var normal := _button_style(COLOR_BORDER.lightened(0.08), 0.08)
	var hover := _button_style(COLOR_P1, 0.14)
	var pressed := _button_style(COLOR_P1, 0.20)
	option.add_theme_stylebox_override("normal", normal)
	option.add_theme_stylebox_override("hover", hover)
	option.add_theme_stylebox_override("pressed", pressed)
	option.add_theme_stylebox_override("focus", hover)
	option.add_theme_stylebox_override("disabled", _button_style(COLOR_BORDER, 0.04))
	option.add_theme_font_override("font", FONT_MEDIUM)
	option.add_theme_font_size_override("font_size", 14)


func _make_button(text: String, callback: Callable, accent_color: Color, min_height: int = 46, use_back_sound: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, min_height)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal", _button_style(accent_color, 0.10))
	button.add_theme_stylebox_override("hover", _button_style(accent_color, 0.18))
	button.add_theme_stylebox_override("pressed", _button_style(accent_color, 0.24))
	button.add_theme_stylebox_override("disabled", _button_style(COLOR_BORDER, 0.04))
	button.add_theme_font_override("font", FONT_SEMIBOLD)
	button.add_theme_font_size_override("font_size", 15 if min_height >= 52 else 14)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", COLOR_TEXT_MUTED)
	button.mouse_entered.connect(AudioManager.play_ui_hover)
	button.pressed.connect(func() -> void:
		if use_back_sound:
			AudioManager.play_ui_back()
		else:
			AudioManager.play_ui_click()
		callback.call()
	)
	return button


func _make_panel_card(accent_color: Color, fill_color: Color) -> PanelContainer:
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


func _panel_style(accent_color: Color, fill_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = accent_color.lerp(COLOR_BORDER, 0.58)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.24)
	style.shadow_size = 10
	return style


func _button_style(accent_color: Color, fill_alpha: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(accent_color.r, accent_color.g, accent_color.b, fill_alpha)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = accent_color
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.16)
	style.shadow_size = 5
	style.content_margin_left = 14.0
	style.content_margin_top = 8.0
	style.content_margin_right = 14.0
	style.content_margin_bottom = 8.0
	return style


func _make_section_heading(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", FONT_SEMIBOLD)
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	return label


func _make_chip(text: String, accent_color: Color) -> PanelContainer:
	var chip := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(accent_color.r, accent_color.g, accent_color.b, 0.10)
	style.border_color = accent_color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	chip.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	chip.add_child(margin)

	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", FONT_SEMIBOLD)
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", accent_color)
	margin.add_child(label)
	return chip


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
	AppState.save_preferences()
	_refresh_summary()


func _refresh_summary() -> void:
	var config: MatchConfig = AppState.current_match_config
	var replay_ready: String = "Ready" if not AppState.current_replay.turns.is_empty() else "Empty"
	if _replay_button != null:
		_replay_button.disabled = AppState.current_replay.turns.is_empty()

	_summary_label.text = "[right][b]Build[/b] %s[/right]\n" % AppState.build_label.replace("-", " ")
	_summary_label.text += "[right]P1 [color=#77b8ff]%s[/color]  •  P2 [color=#ff8a76]%s[/color][/right]\n" % [
		_controller_label(config.player_one_ai.controller_type),
		_controller_label(config.player_two_ai.controller_type),
	]
	_summary_label.text += "[right]Map [color=#f0c05e]%s[/color]  •  Replay %s[/right]\n" % [config.map_id.capitalize(), replay_ready]
	_summary_label.text += "[right]UI %.2fx  •  Motion %s  •  Contrast %s[/right]" % [
		AppState.ui_scale,
		"Reduced" if AppState.reduced_motion else "Standard",
		"High" if AppState.high_contrast_mode else "Standard",
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


func _on_open_help_pressed() -> void:
	get_tree().change_scene_to_file(HELP_SCENE)


func _on_open_settings_pressed() -> void:
	get_tree().change_scene_to_file(SETTINGS_SCENE)


func _on_reset_state_pressed() -> void:
	AppState.reset_runtime_state()
	_apply_config_to_controls()
	_refresh_summary()


func _on_exit_game_pressed() -> void:
	get_tree().quit()
