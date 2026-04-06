extends Control

const MATCH_SCENE := "res://scenes/match/match_root.tscn"
const SETTINGS_SCENE := "res://scenes/settings/settings_root.tscn"


func _ready() -> void:
	_build_layout()


func _build_layout() -> void:
	var background := ColorRect.new()
	background.color = Color("10141c")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(540, 420)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_bottom", 32)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 18)
	margin.add_child(layout)

	var title := Label.new()
	title.text = "Hex Siege Arena"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	layout.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Phase 1 foundation build"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.modulate = Color(0.74, 0.82, 0.92, 1.0)
	layout.add_child(subtitle)

	var summary := RichTextLabel.new()
	summary.bbcode_enabled = true
	summary.fit_content = true
	summary.scroll_active = false
	summary.text = "[center]AI-vs-AI is the flagship mode.[/center]\n[center]Phase 1 provides the Godot skeleton, data models, and scene flow.[/center]"
	layout.add_child(summary)

	layout.add_child(_make_button("Open Match Placeholder", _on_open_match_pressed))
	layout.add_child(_make_button("Open Settings Placeholder", _on_open_settings_pressed))
	layout.add_child(_make_button("Reset Runtime State", _on_reset_state_pressed))


func _make_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(280, 52)
	button.pressed.connect(callback)
	return button


func _on_open_match_pressed() -> void:
	get_tree().change_scene_to_file(MATCH_SCENE)


func _on_open_settings_pressed() -> void:
	get_tree().change_scene_to_file(SETTINGS_SCENE)


func _on_reset_state_pressed() -> void:
	AppState.reset_runtime_state()
	EventBus.publish_status("Runtime state reset for Phase 1 verification.")
