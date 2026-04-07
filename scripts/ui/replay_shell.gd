extends Control

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"

var _play_button: Button
var _step_button: Button
var _restart_button: Button
var _turn_list: ItemList
var _summary_label: Label
var _analytics_label: Label
var _detail_label: Label
var _timer: Timer
var _current_index: int = -1
var _autoplay_enabled: bool = false


func _ready() -> void:
	AppState.apply_window_preferences(self)
	AudioManager.play_menu_music()
	_build_layout()
	_refresh_replay()


func _build_layout() -> void:
	var background := ColorRect.new()
	background.color = Color("11161f")
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
	title.text = "Replay Viewer And Analytics"
	title.add_theme_font_size_override("font_size", 32)
	layout.add_child(title)

	_summary_label = Label.new()
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(_summary_label)

	_analytics_label = Label.new()
	_analytics_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(_analytics_label)

	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 10)
	layout.add_child(controls)

	_play_button = _make_button("Play", _on_play_pressed)
	controls.add_child(_play_button)
	_step_button = _make_button("Step", _on_step_pressed)
	controls.add_child(_step_button)
	_restart_button = _make_button("Restart", _on_restart_pressed)
	controls.add_child(_restart_button)
	controls.add_child(_make_button("Back To Menu", _on_back_pressed, true))

	var content := HBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 18)
	layout.add_child(content)

	var left_panel := PanelContainer.new()
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(left_panel)

	var left_margin := MarginContainer.new()
	left_margin.add_theme_constant_override("margin_left", 18)
	left_margin.add_theme_constant_override("margin_top", 18)
	left_margin.add_theme_constant_override("margin_right", 18)
	left_margin.add_theme_constant_override("margin_bottom", 18)
	left_panel.add_child(left_margin)

	var left_layout := VBoxContainer.new()
	left_layout.add_theme_constant_override("separation", 10)
	left_margin.add_child(left_layout)

	var list_title := Label.new()
	list_title.text = "Recorded Turns"
	left_layout.add_child(list_title)

	_turn_list = ItemList.new()
	_turn_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_turn_list.custom_minimum_size = Vector2(0, 420)
	_turn_list.item_selected.connect(_on_turn_selected)
	left_layout.add_child(_turn_list)

	var right_panel := PanelContainer.new()
	right_panel.custom_minimum_size = Vector2(420, 0)
	right_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(right_panel)

	var right_margin := MarginContainer.new()
	right_margin.add_theme_constant_override("margin_left", 18)
	right_margin.add_theme_constant_override("margin_top", 18)
	right_margin.add_theme_constant_override("margin_right", 18)
	right_margin.add_theme_constant_override("margin_bottom", 18)
	right_panel.add_child(right_margin)

	_detail_label = Label.new()
	_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right_margin.add_child(_detail_label)

	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)


func _make_button(text: String, callback: Callable, use_back_sound: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(140, 44)
	button.mouse_entered.connect(AudioManager.play_ui_hover)
	if use_back_sound:
		button.pressed.connect(AudioManager.play_ui_back)
	else:
		button.pressed.connect(AudioManager.play_ui_click)
	button.pressed.connect(callback)
	return button


func _refresh_replay() -> void:
	var replay: ReplayRecord = AppState.current_replay
	var map_name: String = str(replay.metadata.get("map_name", "Unknown Map"))
	var p1_label: String = str(replay.metadata.get("player_one_controller", "Unknown"))
	var p2_label: String = str(replay.metadata.get("player_two_controller", "Unknown"))
	_summary_label.text = "Replay shell for the current recorded match.\nMap: %s | P1: %s | P2: %s | Turns: %d | Winner: %s" % [map_name, p1_label, p2_label, replay.turns.size(), replay.winner_label if replay.winner_label != "" else "Pending"]
	_analytics_label.text = ReplayAnalytics.format_summary_text(ReplayAnalytics.build_summary(replay))

	_turn_list.clear()
	for index in range(replay.turns.size()):
		var turn_data: Dictionary = replay.turns[index]
		_turn_list.add_item("T%d P%d %s" % [int(turn_data.get("turn", 0)), int(turn_data.get("player", 0)), str(turn_data.get("source", "Unknown"))])

	if replay.turns.is_empty():
		_detail_label.text = "No replay data yet. Play a match first, then come back here to browse the recorded turns."
		_analytics_label.text = ""
		_play_button.disabled = true
		_step_button.disabled = true
		_restart_button.disabled = true
		return

	_play_button.disabled = false
	_step_button.disabled = false
	_restart_button.disabled = false
	_select_index(clampi(_current_index, 0, replay.turns.size() - 1) if _current_index >= 0 else 0)


func _select_index(index: int) -> void:
	var replay: ReplayRecord = AppState.current_replay
	if replay.turns.is_empty():
		return
	_current_index = clampi(index, 0, replay.turns.size() - 1)
	_turn_list.select(_current_index)
	var turn_data: Dictionary = replay.turns[_current_index]
	var metrics: Dictionary = turn_data.get("metrics", {})
	var timeline_position: String = "Replay Position: %d / %d" % [_current_index + 1, replay.turns.size()]
	_detail_label.text = "Turn %d | Player %d\nSource: %s\nSummary: %s\nScore: %.2f\nMetrics: %s\nState Hash: %s\n\nEvents:\n%s" % [
		int(turn_data.get("turn", 0)),
		int(turn_data.get("player", 0)),
		str(turn_data.get("source", "Unknown")),
		str(turn_data.get("summary", "")),
		float(turn_data.get("score", 0.0)),
		JSON.stringify(metrics),
		str(turn_data.get("state_hash", "")),
		"\n".join(_string_array(turn_data.get("events", []))),
	]
	_detail_label.text = "%s\n\n%s" % [timeline_position, _detail_label.text]


func _string_array(values: Array) -> Array[String]:
	var results: Array[String] = []
	for item: Variant in values:
		results.append(str(item))
	return results


func _on_turn_selected(index: int) -> void:
	_autoplay_enabled = false
	_timer.stop()
	_select_index(index)


func _on_play_pressed() -> void:
	if AppState.current_replay.turns.is_empty():
		return
	_autoplay_enabled = not _autoplay_enabled
	_play_button.text = "Pause" if _autoplay_enabled else "Play"
	if _autoplay_enabled:
		_schedule_next()
	else:
		_timer.stop()


func _on_step_pressed() -> void:
	if AppState.current_replay.turns.is_empty():
		return
	_autoplay_enabled = false
	_play_button.text = "Play"
	_timer.stop()
	_select_index(mini(_current_index + 1, AppState.current_replay.turns.size() - 1))


func _on_restart_pressed() -> void:
	_autoplay_enabled = false
	_play_button.text = "Play"
	_timer.stop()
	_select_index(0)


func _on_timer_timeout() -> void:
	if not _autoplay_enabled:
		return
	var next_index: int = _current_index + 1
	if next_index >= AppState.current_replay.turns.size():
		_autoplay_enabled = false
		_play_button.text = "Play"
		return
	_select_index(next_index)
	_schedule_next()


func _schedule_next() -> void:
	_timer.stop()
	_timer.wait_time = 0.65
	_timer.start()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
