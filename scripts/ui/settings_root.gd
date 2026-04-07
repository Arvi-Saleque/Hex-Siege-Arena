extends Control

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"


func _ready() -> void:
	AudioManager.play_menu_music()
	_build_layout()


func _build_layout() -> void:
	var background := ColorRect.new()
	background.color = Color("141923")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var container := CenterContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(container)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 320)
	container.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	margin.add_child(layout)

	var title := Label.new()
	title.text = "Settings Placeholder"
	title.add_theme_font_size_override("font_size", 30)
	layout.add_child(title)

	var description := Label.new()
	description.text = "Audio now plays in the menu and match scenes. Later phases will add volume controls, accessibility, replay speed, and more AI debug settings."
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(description)

	var back_button := Button.new()
	back_button.text = "Back To Menu"
	back_button.custom_minimum_size = Vector2(220, 48)
	back_button.mouse_entered.connect(AudioManager.play_ui_hover)
	back_button.pressed.connect(_on_back_pressed)
	layout.add_child(back_button)


func _on_back_pressed() -> void:
	AudioManager.play_ui_back()
	get_tree().change_scene_to_file(MENU_SCENE)
