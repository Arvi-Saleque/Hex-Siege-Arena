extends Control

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"

var _music_slider: HSlider
var _sfx_slider: HSlider
var _ui_slider: HSlider
var _music_value_label: Label
var _sfx_value_label: Label
var _ui_value_label: Label


func _ready() -> void:
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
	panel.custom_minimum_size = Vector2(620, 420)
	container.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	margin.add_child(layout)

	var title := Label.new()
	title.text = "Settings"
	title.add_theme_font_size_override("font_size", 30)
	layout.add_child(title)

	var description := Label.new()
	description.text = "Phase 13 adds live audio controls and a cleaner shell around the arena. These sliders update the current session immediately."
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(description)

	layout.add_child(_slider_row("Music Volume", AudioManager.music_volume_db, "_on_music_changed"))
	layout.add_child(_slider_row("SFX Volume", AudioManager.sfx_volume_db, "_on_sfx_changed"))
	layout.add_child(_slider_row("UI Volume", AudioManager.ui_volume_db, "_on_ui_changed"))

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


func _slider_row(label_text: String, initial_value: float, callback_name: String) -> Control:
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
	slider.min_value = -30.0
	slider.max_value = 0.0
	slider.step = 1.0
	slider.value = initial_value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(Callable(self, callback_name))
	row.add_child(slider)

	match label_text:
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


func _refresh_labels() -> void:
	if _music_value_label != null:
		_music_value_label.text = "%.0f dB" % _music_slider.value
	if _sfx_value_label != null:
		_sfx_value_label.text = "%.0f dB" % _sfx_slider.value
	if _ui_value_label != null:
		_ui_value_label.text = "%.0f dB" % _ui_slider.value


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


func _on_restore_defaults_pressed() -> void:
	AudioManager.play_ui_click()
	_music_slider.value = -16.0
	_sfx_slider.value = -8.0
	_ui_slider.value = -10.0
	AudioManager.set_music_volume_db(_music_slider.value)
	AudioManager.set_sfx_volume_db(_sfx_slider.value)
	AudioManager.set_ui_volume_db(_ui_slider.value)
	_refresh_labels()


func _on_back_pressed() -> void:
	AudioManager.play_ui_back()
	get_tree().change_scene_to_file(MENU_SCENE)
