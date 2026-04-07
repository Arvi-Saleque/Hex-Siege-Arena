extends Control

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"
const MATCH_SCENE := "res://scenes/match/match_root.tscn"
const SETTINGS_SCENE := "res://scenes/settings/settings_root.tscn"


func _ready() -> void:
	AppState.apply_window_preferences(self)
	AudioManager.play_menu_music()
	_build_layout()


func _build_layout() -> void:
	var background := ColorRect.new()
	background.color = Color("0f141d")
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
	layout.add_theme_constant_override("separation", 16)
	root_margin.add_child(layout)

	var title := Label.new()
	title.text = "Quick Start Guide"
	title.add_theme_font_size_override("font_size", 34)
	layout.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Use this page to understand the core rules before jumping into the arena."
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.modulate = Color(0.8, 0.87, 0.94, 1.0)
	layout.add_child(subtitle)

	var content_panel := PanelContainer.new()
	content_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(content_panel)

	var content_margin := MarginContainer.new()
	content_margin.add_theme_constant_override("margin_left", 22)
	content_margin.add_theme_constant_override("margin_top", 22)
	content_margin.add_theme_constant_override("margin_right", 22)
	content_margin.add_theme_constant_override("margin_bottom", 22)
	content_panel.add_child(content_margin)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_margin.add_child(scroll)

	var sections := VBoxContainer.new()
	sections.add_theme_constant_override("separation", 18)
	scroll.add_child(sections)

	sections.add_child(_section("Objective", "Win by doing either of these:\n- Destroy the enemy Ktank\n- Move your own Ktank onto the center hex"))
	sections.add_child(_section("Unit Roles", "Qtank:\n- controls straight lines with a laser\n- can reposition quickly\n- excels at tactical pressure\n\nKtank:\n- tougher and more important to protect\n- attacks adjacent hexes with a blast\n- can win instantly by reaching center"))
	sections.add_child(_section("Turn Structure", "Each turn usually allows one action:\n- Move\n- Attack\n- Pass\n\nThe main exception is Bonus Move, which grants an extra action for that turn."))
	sections.add_child(_section("AI Personalities", "Minimax:\n- deeper tactical lookahead\n- usually stronger in direct calculation-heavy positions\n\nMCTS:\n- broader exploration through many simulated futures\n- often more flexible on larger or more open maps"))
	sections.add_child(_section("Suggested First Checks", "1. Start with Standard or Labyrinth.\n2. Run Minimax vs MCTS with Auto enabled.\n3. Watch center pressure, Ktank safety, and power pickups.\n4. Use Replay Viewer after the match to review the action history."))
	sections.add_child(_section("Accessibility", "In Settings you can now adjust:\n- UI Scale\n- Reduced Motion\n- High Contrast Highlights\n- Music / SFX / UI volume"))

	var button_row := HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 12)
	layout.add_child(button_row)

	button_row.add_child(_make_button("Start Match", _on_start_match_pressed))
	button_row.add_child(_make_button("Open Settings", _on_settings_pressed))
	button_row.add_child(_make_button("Back To Menu", _on_back_pressed, true))


func _section(title_text: String, body_text: String) -> Control:
	var panel := PanelContainer.new()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	margin.add_child(layout)

	var title := Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 22)
	layout.add_child(title)

	var body := Label.new()
	body.text = body_text
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(body)

	return panel


func _make_button(text: String, callback: Callable, use_back_sound: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(180, 48)
	button.mouse_entered.connect(AudioManager.play_ui_hover)
	if use_back_sound:
		button.pressed.connect(AudioManager.play_ui_back)
	else:
		button.pressed.connect(AudioManager.play_ui_click)
	button.pressed.connect(callback)
	return button


func _on_start_match_pressed() -> void:
	get_tree().change_scene_to_file(MATCH_SCENE)


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file(SETTINGS_SCENE)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
