extends Control

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"

var _scale_slider: HSlider
var _music_slider: HSlider
var _sfx_slider: HSlider
var _ui_slider: HSlider
var _scale_value_label: Label
var _music_value_label: Label
var _sfx_value_label: Label
var _ui_value_label: Label
var _reduced_motion_check: CheckBox
var _high_contrast_check: CheckBox


func _ready() -> void:
	AppState.apply_window_preferences(self)
	AudioManager.play_menu_music()
	_build_layout()
	_refresh_labels()


func _build_layout() -> void:
	var background := ColorRect.new()
	background.color = Color("141923")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var container := CenterContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(container)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 620)
	container.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(margin)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(scroll)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	scroll.add_child(layout)

	var title := Label.new()
	title.text = "Settings"
	title.add_theme_font_size_override("font_size", 30)
	layout.add_child(title)

	var description := Label.new()
	description.text = "Accessibility and audio settings update the current session immediately. Use these to make the arena easier to read and more comfortable during long AI-vs-AI runs."
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(description)

	layout.add_child(_slider_row("UI Scale", AppState.ui_scale, "_on_scale_changed", 0.85, 1.35, 0.05))
	layout.add_child(_slider_row("Music Volume", AudioManager.music_volume_db, "_on_music_changed"))
	layout.add_child(_slider_row("SFX Volume", AudioManager.sfx_volume_db, "_on_sfx_changed"))
	layout.add_child(_slider_row("UI Volume", AudioManager.ui_volume_db, "_on_ui_changed"))
	layout.add_child(_toggle_row("Reduced Motion", AppState.reduced_motion, "_on_reduced_motion_toggled", "Disables board shake and tones down animated motion where practical."))
	layout.add_child(_toggle_row("High Contrast Highlights", AppState.high_contrast_mode, "_on_high_contrast_toggled", "Uses stronger preview and player colors so move, attack, and team cues stand out more clearly."))

	var button_row := HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 12)
	layout.add_child(button_row)

	var reset_button := Button.new()
	reset_button.text = "Restore Defaults"
	reset_button.custom_minimum_size = Vector2(180, 46)
	reset_button.mouse_entered.connect(AudioManager.play_ui_hover)
	reset_button.pressed.connect(_on_restore_defaults_pressed)
	button_row.add_child(reset_button)

	var back_button := Button.new()
	back_button.text = "Back To Menu"
	back_button.custom_minimum_size = Vector2(180, 46)
	back_button.mouse_entered.connect(AudioManager.play_ui_hover)
	back_button.pressed.connect(_on_back_pressed)
	button_row.add_child(back_button)


func _slider_row(label_text: String, initial_value: float, callback_name: String, min_value: float = -30.0, max_value: float = 0.0, step: float = 1.0) -> Control:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	row.add_child(top)

	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(label)

	var value_label := Label.new()
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top.add_child(value_label)

	var slider := HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.value = initial_value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(Callable(self, callback_name))
	row.add_child(slider)

	match label_text:
		"UI Scale":
			_scale_slider = slider
			_scale_value_label = value_label
		"Music Volume":
			_music_slider = slider
			_music_value_label = value_label
		"SFX Volume":
			_sfx_slider = slider
			_sfx_value_label = value_label
		"UI Volume":
			_ui_slider = slider
			_ui_value_label = value_label

	return row


func _toggle_row(label_text: String, initial_value: bool, callback_name: String, description_text: String) -> Control:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 4)

	var check := CheckBox.new()
	check.text = label_text
	check.button_pressed = initial_value
	check.toggled.connect(Callable(self, callback_name))
	row.add_child(check)

	var description := Label.new()
	description.text = description_text
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.modulate = Color(0.76, 0.82, 0.9, 1.0)
	row.add_child(description)

	match label_text:
		"Reduced Motion":
			_reduced_motion_check = check
		"High Contrast Highlights":
			_high_contrast_check = check

	return row


func _refresh_labels() -> void:
	if _scale_value_label != null:
		_scale_value_label.text = "%.2fx" % _scale_slider.value
	if _music_value_label != null:
		_music_value_label.text = "%.0f dB" % _music_slider.value
	if _sfx_value_label != null:
		_sfx_value_label.text = "%.0f dB" % _sfx_slider.value
	if _ui_value_label != null:
		_ui_value_label.text = "%.0f dB" % _ui_slider.value


func _on_scale_changed(value: float) -> void:
	AppState.ui_scale = value
	AppState.apply_window_preferences(self)
	_refresh_labels()
	AudioManager.play_ui_confirm()


func _on_music_changed(value: float) -> void:
	AudioManager.set_music_volume_db(value)
	_refresh_labels()


func _on_sfx_changed(value: float) -> void:
	AudioManager.set_sfx_volume_db(value)
	_refresh_labels()
	AudioManager.play_ui_confirm()


func _on_ui_changed(value: float) -> void:
	AudioManager.set_ui_volume_db(value)
	_refresh_labels()
	AudioManager.play_ui_confirm()


func _on_reduced_motion_toggled(enabled: bool) -> void:
	AppState.reduced_motion = enabled
	AudioManager.play_ui_confirm()


func _on_high_contrast_toggled(enabled: bool) -> void:
	AppState.high_contrast_mode = enabled
	AudioManager.play_ui_confirm()


func _on_restore_defaults_pressed() -> void:
	AudioManager.play_ui_click()
	_scale_slider.value = 1.0
	_music_slider.value = -16.0
	_sfx_slider.value = -8.0
	_ui_slider.value = -10.0
	if _reduced_motion_check != null:
		_reduced_motion_check.button_pressed = false
	if _high_contrast_check != null:
		_high_contrast_check.button_pressed = false
	AppState.ui_scale = _scale_slider.value
	AppState.reduced_motion = false
	AppState.high_contrast_mode = false
	AppState.apply_window_preferences(self)
	AudioManager.set_music_volume_db(_music_slider.value)
	AudioManager.set_sfx_volume_db(_sfx_slider.value)
	AudioManager.set_ui_volume_db(_ui_slider.value)
	_refresh_labels()


func _on_back_pressed() -> void:
	AudioManager.play_ui_back()
	get_tree().change_scene_to_file(MENU_SCENE)
