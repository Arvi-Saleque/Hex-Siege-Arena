extends Control

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"


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
	title.text = "Match Scene Placeholder"
	title.add_theme_font_size_override("font_size", 32)
	layout.add_child(title)

	var info := RichTextLabel.new()
	info.fit_content = true
	info.scroll_active = false
	info.text = "Phase 1 keeps this scene intentionally light.\nUpcoming phases will add the board, units, AI loop, spectator controls, and tactical previews."
	layout.add_child(info)

	var config_summary := Label.new()
	config_summary.text = "P1: %s | P2: %s | Map: %s" % [
		_controller_label(AppState.current_match_config.player_one_ai.controller_type),
		_controller_label(AppState.current_match_config.player_two_ai.controller_type),
		AppState.current_match_config.map_id,
	]
	layout.add_child(config_summary)

	var back_button := Button.new()
	back_button.text = "Back To Menu"
	back_button.custom_minimum_size = Vector2(220, 48)
	back_button.pressed.connect(_on_back_pressed)
	layout.add_child(back_button)


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
