class_name BoardDebugView
extends Node2D

signal hovered_cell_changed(summary: String)
signal selected_cell_changed(summary: String)
signal cell_clicked(coord_key: String)

const COLOR_BY_TYPE := {
	GameTypes.CellType.EMPTY: Color("232a37"),
	GameTypes.CellType.CENTER: Color("e7be37"),
	GameTypes.CellType.WALL: Color("5b6475"),
	GameTypes.CellType.BLOCK: Color("7a5933"),
	GameTypes.CellType.ARMOR_BLOCK: Color("a8b0bd"),
	GameTypes.CellType.POWER_BLOCK: Color("9757c9"),
	GameTypes.CellType.POWER_ATTACK: Color("e64f67"),
	GameTypes.CellType.POWER_SHIELD: Color("5fa8ff"),
	GameTypes.CellType.POWER_BONUS_MOVE: Color("57d477"),
}
const PLAYER_PRIMARY := {
	1: Color("72a7ff"),
	2: Color("ff6978"),
}
const PLAYER_ACCENT := {
	1: Color("d7ebff"),
	2: Color("ffe1d7"),
}

var hex_size: float = 34.0
var board_state: BoardState = BoardState.new()
var game_state: GameState
var hovered_key: String = ""
var selected_key: String = ""
var selected_actor_id: String = ""
var highlighted_keys: Dictionary = {}
var current_action_mode: String = ""
var _pulse_time: float = 0.0
var _beam_effects: Array[Dictionary] = []
var _ring_effects: Array[Dictionary] = []
var _flash_effects: Array[Dictionary] = []
var _floating_texts: Array[Dictionary] = []
var _shake_timer: float = 0.0
var _shake_strength: float = 0.0
var _shake_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	if game_state == null:
		board_state.load_map_preset(MapLibrary.get_preset("standard"))
	set_process_input(true)
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_pulse_time += delta
	_process_effects(delta)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_update_hover(to_local(event.position))
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_hex(to_local(event.position))


func _draw() -> void:
	var active_board: BoardState = _active_board()
	_draw_board_backdrop(active_board)
	for cell: CellData in _sorted_cells(active_board):
		var center: Vector2 = _tile_center(cell)
		var fill: Color = COLOR_BY_TYPE.get(cell.cell_type, Color.DIM_GRAY)
		if highlighted_keys.has(cell.coord.key()):
			fill = fill.lerp(highlighted_keys[cell.coord.key()], 0.45)
		if cell.coord.key() == hovered_key:
			fill = fill.lerp(Color.WHITE, 0.18)
		if cell.coord.key() == selected_key:
			fill = fill.lerp(Color("67f0ff"), 0.35)

		var points: PackedVector2Array = _hex_points(center)
		var shadow_points: PackedVector2Array = _offset_points(points, Vector2(0, 11 + _tile_depth(cell)))
		draw_colored_polygon(shadow_points, Color(0.03, 0.05, 0.08, 0.55))

		var side_points: PackedVector2Array = _side_face_points(points, 8 + _tile_depth(cell))
		if not side_points.is_empty():
			draw_colored_polygon(side_points, fill.darkened(0.38))

		var glow_color: Color = _tile_glow_color(cell)
		if glow_color.a > 0.0:
			draw_circle(center + Vector2(0, 8), hex_size * 0.82, glow_color)

		draw_colored_polygon(points, fill)
		var outline: PackedVector2Array = points.duplicate()
		outline.append(points[0])
		draw_polyline(outline, Color("0f131a"), 2.0, true)
		var top_highlight: PackedVector2Array = PackedVector2Array([points[4], points[5], points[0], points[1]])
		draw_polyline(top_highlight, Color.WHITE.lerp(fill, 0.65), 1.5, true)
		_draw_tile_material(cell, center, points, fill)
		if cell.cell_type == GameTypes.CellType.CENTER:
			var pulse_radius: float = hex_size * (0.52 + 0.08 * sin(_pulse_time * 2.2))
			draw_circle(center, pulse_radius + 6.0, Color(1.0, 0.92, 0.47, 0.08))
			draw_arc(center, pulse_radius, 0.0, TAU, 48, Color("fff2a8"), 2.0, true)
		if highlighted_keys.has(cell.coord.key()) and current_action_mode != "":
			var preview_outline: PackedVector2Array = points.duplicate()
			preview_outline.append(points[0])
			var preview_color: Color = Color("63e38f") if current_action_mode == "move" else Color("ff7a86")
			draw_polyline(preview_outline, preview_color, 3.0, true)
		if cell.coord.key() == hovered_key:
			draw_circle(center + Vector2(0, 2), hex_size * 0.33, Color(1.0, 1.0, 1.0, 0.06))

	if game_state != null:
		_draw_tanks()
	_draw_effects()


func _hex_points(center: Vector2) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for index in range(6):
		var angle: float = deg_to_rad(60.0 * index)
		points.append(center + Vector2(cos(angle), sin(angle)) * hex_size)
	return points


func _offset_points(points: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var offset_points: PackedVector2Array = PackedVector2Array()
	for point: Vector2 in points:
		offset_points.append(point + offset)
	return offset_points


func _side_face_points(points: PackedVector2Array, depth: float) -> PackedVector2Array:
	if points.size() < 6:
		return PackedVector2Array()
	return PackedVector2Array([
		points[1],
		points[2],
		points[2] + Vector2(0, depth),
		points[1] + Vector2(0, depth),
		points[0] + Vector2(0, depth),
		points[5] + Vector2(0, depth),
		points[5],
		points[0],
	])


func _update_hover(local_position: Vector2) -> void:
	var coord: HexCoord = HexCoord.from_world_flat(local_position, hex_size)
	var active_board: BoardState = _active_board()
	var new_key: String = coord.key() if active_board.has_cell(coord) else ""
	if new_key == hovered_key:
		return
	hovered_key = new_key
	hovered_cell_changed.emit(_build_summary(coord, active_board.get_cell(coord)) if new_key != "" else "Hover: outside board")
	queue_redraw()


func _select_hex(local_position: Vector2) -> void:
	var coord: HexCoord = HexCoord.from_world_flat(local_position, hex_size)
	var active_board: BoardState = _active_board()
	if not active_board.has_cell(coord):
		return
	selected_key = coord.key()
	selected_cell_changed.emit(_build_summary(coord, active_board.get_cell(coord)))
	cell_clicked.emit(selected_key)
	queue_redraw()


func _build_summary(coord: HexCoord, cell: CellData) -> String:
	if cell == null:
		return "No cell"
	return "Hex %s | %s | HP %d" % [coord.key(), _type_label(cell.cell_type), cell.hp]


func _type_label(cell_type: int) -> String:
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


func set_game_state(new_game_state: GameState) -> void:
	game_state = new_game_state
	board_state = game_state.board
	queue_redraw()


func set_selected_actor(actor_id: String) -> void:
	selected_actor_id = actor_id
	queue_redraw()


func set_highlighted_cells(keys: Dictionary) -> void:
	highlighted_keys = keys.duplicate(true)
	queue_redraw()


func set_action_mode(action_mode: String) -> void:
	current_action_mode = action_mode
	queue_redraw()


func play_action_feedback(previous_state: GameState, current_state: GameState, action: ActionData, events: Array[GameEvent]) -> void:
	if previous_state == null or current_state == null:
		return

	match action.action_type:
		GameTypes.ActionType.MOVE:
			var moved_tank: TankData = previous_state.get_tank(action.actor_id)
			if moved_tank != null:
				var start_center: Vector2 = moved_tank.position.to_world_flat(hex_size)
				var end_center: Vector2 = action.target_coord.to_world_flat(hex_size)
				_beam_effects.append({
					"start": start_center,
					"end": end_center,
					"color": Color("7be0ff"),
					"width": 4.0,
					"time_left": 0.18,
					"duration": 0.18,
				})
				_ring_effects.append({
					"center": end_center,
					"color": Color("7be0ff"),
					"radius": 26.0,
					"time_left": 0.28,
					"duration": 0.28,
					"filled": false,
				})
				_trigger_shake(0.15)
		GameTypes.ActionType.ATTACK:
			_play_attack_effect(previous_state, action)
		_:
			pass

	for event_item: GameEvent in events:
		_apply_event_feedback(current_state, event_item)

	queue_redraw()


func get_board_visual_size() -> Vector2:
	var active_board: BoardState = _active_board()
	if active_board.cells.is_empty():
		return Vector2(820, 760)

	var min_x: float = INF
	var min_y: float = INF
	var max_x: float = -INF
	var max_y: float = -INF
	for cell: CellData in active_board.cells.values():
		var center: Vector2 = cell.coord.to_world_flat(hex_size)
		min_x = minf(min_x, center.x)
		min_y = minf(min_y, center.y)
		max_x = maxf(max_x, center.x)
		max_y = maxf(max_y, center.y)

	return Vector2((max_x - min_x) + hex_size * 6.0, (max_y - min_y) + hex_size * 7.0)


func _active_board() -> BoardState:
	return game_state.board if game_state != null else board_state


func _sorted_cells(active_board: BoardState) -> Array[CellData]:
	var cells: Array[CellData] = active_board.all_cells()
	cells.sort_custom(func(a: CellData, b: CellData) -> bool:
		var a_center: Vector2 = a.coord.to_world_flat(hex_size)
		var b_center: Vector2 = b.coord.to_world_flat(hex_size)
		return a_center.y < b_center.y
	)
	return cells


func _tile_center(cell: CellData) -> Vector2:
	var center: Vector2 = cell.coord.to_world_flat(hex_size)
	if cell.coord.key() == hovered_key:
		center.y -= 4.0
	if cell.coord.key() == selected_key:
		center.y -= 6.0
	return center + _shake_offset


func _tile_depth(cell: CellData) -> float:
	if cell.cell_type == GameTypes.CellType.CENTER:
		return 8.0
	if cell.cell_type == GameTypes.CellType.WALL or cell.cell_type == GameTypes.CellType.ARMOR_BLOCK:
		return 6.0
	if cell.cell_type == GameTypes.CellType.BLOCK or cell.cell_type == GameTypes.CellType.POWER_BLOCK:
		return 5.0
	if cell.coord.key() == hovered_key or cell.coord.key() == selected_key:
		return 5.0
	return 2.0


func _tile_glow_color(cell: CellData) -> Color:
	match cell.cell_type:
		GameTypes.CellType.CENTER:
			return Color(1.0, 0.9, 0.35, 0.08 + 0.03 * sin(_pulse_time * 2.0))
		GameTypes.CellType.POWER_ATTACK:
			return Color(0.93, 0.42, 0.45, 0.09)
		GameTypes.CellType.POWER_SHIELD:
			return Color(0.39, 0.7, 1.0, 0.09)
		GameTypes.CellType.POWER_BONUS_MOVE:
			return Color(0.42, 0.89, 0.63, 0.09)
		GameTypes.CellType.POWER_BLOCK:
			return Color(0.66, 0.42, 0.95, 0.07)
		_:
			return Color(0.0, 0.0, 0.0, 0.0)


func _draw_board_backdrop(active_board: BoardState) -> void:
	var used_rect: Rect2 = Rect2(Vector2(-420, -320), Vector2(840, 700))
	if not active_board.cells.is_empty():
		var min_x: float = INF
		var min_y: float = INF
		var max_x: float = -INF
		var max_y: float = -INF
		for cell: CellData in active_board.cells.values():
			var center: Vector2 = cell.coord.to_world_flat(hex_size)
			min_x = minf(min_x, center.x)
			min_y = minf(min_y, center.y)
			max_x = maxf(max_x, center.x)
			max_y = maxf(max_y, center.y)
		used_rect = Rect2(Vector2(min_x - 120.0, min_y - 120.0), Vector2((max_x - min_x) + 240.0, (max_y - min_y) + 260.0))

	draw_rect(used_rect, Color("121722"))
	draw_circle(used_rect.position + Vector2(used_rect.size.x * 0.3, used_rect.size.y * 0.28) + _shake_offset, 180.0, Color(0.2, 0.32, 0.48, 0.08))
	draw_circle(used_rect.position + Vector2(used_rect.size.x * 0.72, used_rect.size.y * 0.62) + _shake_offset, 210.0, Color(0.66, 0.55, 0.2, 0.05))
	draw_circle(used_rect.position + Vector2(used_rect.size.x * 0.5, used_rect.size.y * 0.48) + _shake_offset, 290.0, Color(0.08, 0.12, 0.2, 0.25))


func _draw_tanks() -> void:
	var font: Font = ThemeDB.fallback_font
	for tank: TankData in game_state.get_all_tanks():
		if not tank.is_alive():
			continue
		var tank_cell: CellData = game_state.board.get_cell(tank.position)
		var center: Vector2 = _tile_center(tank_cell) if tank_cell != null else tank.position.to_world_flat(hex_size)
		var player_color: Color = PLAYER_PRIMARY.get(tank.owner_id, Color.WHITE)
		var accent_color: Color = PLAYER_ACCENT.get(tank.owner_id, Color.WHITE)
		draw_colored_polygon(_ellipse_points(center + Vector2(0, 15), Vector2(18, 8), 20), Color(0.03, 0.05, 0.08, 0.4))
		if tank.owner_id == game_state.current_player:
			draw_arc(center, 20.0, 0.0, TAU, 40, player_color.lerp(Color.WHITE, 0.2), 2.5, true)
		if tank.actor_id() == selected_actor_id:
			draw_circle(center, 19.0, player_color.lerp(Color.WHITE, 0.4))
		if tank.tank_type == GameTypes.TankType.QTANK:
			_draw_qtank(center, player_color, accent_color)
		else:
			_draw_ktank(center, player_color, accent_color)

		if font != null:
			var label: String = "Q" if tank.tank_type == GameTypes.TankType.QTANK else "K"
			draw_string(font, center + Vector2(-7, 25), "%s%d" % [label, tank.owner_id], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color.WHITE)
			draw_string(font, center + Vector2(-10, -22), "%d" % tank.hp, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color("f5f7fb"))

		if tank.active_buff != GameTypes.BuffType.NONE:
			var buff_color: Color = _buff_color(tank.active_buff)
			draw_circle(center + Vector2(13, -13), 5.0, buff_color)
			draw_circle(center + Vector2(13, -13), 2.0, Color("10141c"))


func _draw_effects() -> void:
	var font: Font = ThemeDB.fallback_font
	for beam: Dictionary in _beam_effects:
		var ratio: float = _effect_float(beam, "time_left", 0.0) / maxf(_effect_float(beam, "duration", 1.0), 0.001)
		var beam_color: Color = _effect_color(beam, "color", Color.WHITE)
		beam_color.a = 0.15 + 0.85 * ratio
		var beam_width: float = _effect_float(beam, "width", 3.0) * (0.8 + 0.35 * ratio)
		var beam_start: Vector2 = _effect_vec2(beam, "start", Vector2.ZERO)
		var beam_end: Vector2 = _effect_vec2(beam, "end", Vector2.ZERO)
		draw_line(beam_start + _shake_offset, beam_end + _shake_offset, beam_color, beam_width)
		draw_circle(beam_end + _shake_offset, 4.0 + 6.0 * ratio, beam_color)

	for ring: Dictionary in _ring_effects:
		var ratio: float = _effect_float(ring, "time_left", 0.0) / maxf(_effect_float(ring, "duration", 1.0), 0.001)
		var ring_color: Color = _effect_color(ring, "color", Color.WHITE)
		ring_color.a = 0.1 + 0.7 * ratio
		var radius: float = _effect_float(ring, "radius", 18.0) * (1.0 + (1.0 - ratio) * 0.55)
		var ring_center: Vector2 = _effect_vec2(ring, "center", Vector2.ZERO) + _shake_offset
		if _effect_bool(ring, "filled", false):
			draw_circle(ring_center, radius, Color(ring_color.r, ring_color.g, ring_color.b, ring_color.a * 0.18))
		draw_arc(ring_center, radius, 0.0, TAU, 42, ring_color, 2.4, true)

	for flash: Dictionary in _flash_effects:
		var ratio: float = _effect_float(flash, "time_left", 0.0) / maxf(_effect_float(flash, "duration", 1.0), 0.001)
		var flash_color: Color = _effect_color(flash, "color", Color.WHITE)
		flash_color.a = 0.08 + 0.45 * ratio
		draw_circle(_effect_vec2(flash, "center", Vector2.ZERO) + _shake_offset, _effect_float(flash, "radius", 16.0) * (1.0 + 0.25 * (1.0 - ratio)), flash_color)

	if font != null:
		for floater: Dictionary in _floating_texts:
			var ratio: float = _effect_float(floater, "time_left", 0.0) / maxf(_effect_float(floater, "duration", 1.0), 0.001)
			var text_color: Color = _effect_color(floater, "color", Color.WHITE)
			text_color.a = 0.15 + 0.85 * ratio
			var drift: float = (1.0 - ratio) * 18.0
			var position: Vector2 = _effect_vec2(floater, "center", Vector2.ZERO) + Vector2(-10, -18 - drift) + _shake_offset
			draw_string(font, position, _effect_string(floater, "text", ""), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, text_color)


func _draw_tile_material(cell: CellData, center: Vector2, points: PackedVector2Array, fill: Color) -> void:
	var inset: PackedVector2Array = _scaled_points(points, center, 0.72)
	match cell.cell_type:
		GameTypes.CellType.EMPTY:
			draw_polyline(PackedVector2Array([inset[5], inset[0], inset[1]]), fill.lightened(0.18), 1.1, true)
		GameTypes.CellType.CENTER:
			draw_circle(center, hex_size * 0.28, Color("fff4ba"))
			draw_arc(center, hex_size * 0.44, 0.0, TAU, 36, Color("8c6317"), 2.2, true)
			draw_polyline(PackedVector2Array([
				center + Vector2(-8, 0),
				center + Vector2(0, -8),
				center + Vector2(8, 0),
				center + Vector2(0, 8),
				center + Vector2(-8, 0),
			]), Color("8c6317"), 2.0, true)
		GameTypes.CellType.WALL:
			for offset_x in [-10.0, 0.0, 10.0]:
				draw_line(center + Vector2(offset_x, -12), center + Vector2(offset_x, 12), fill.lightened(0.18), 2.0)
			draw_line(center + Vector2(-16, -6), center + Vector2(16, -6), fill.darkened(0.22), 1.4)
		GameTypes.CellType.BLOCK:
			draw_polyline(PackedVector2Array([
				center + Vector2(-10, -6),
				center + Vector2(-2, 0),
				center + Vector2(-6, 10),
				center + Vector2(3, 4),
				center + Vector2(10, 12),
			]), Color("d6b07b"), 1.8, true)
		GameTypes.CellType.ARMOR_BLOCK:
			draw_colored_polygon(inset, fill.lightened(0.08))
			draw_polyline(_closed_polyline(inset), Color("5a6470"), 1.6, true)
			var armor_points: PackedVector2Array = PackedVector2Array([inset[0], inset[2], inset[4]])
			for point: Vector2 in armor_points:
				draw_circle(point.lerp(center, 0.22), 2.3, Color("6d7684"))
		GameTypes.CellType.POWER_BLOCK:
			var crystal: PackedVector2Array = PackedVector2Array([
				center + Vector2(0, -14),
				center + Vector2(10, -1),
				center + Vector2(5, 13),
				center + Vector2(-5, 13),
				center + Vector2(-10, -1),
			])
			draw_colored_polygon(crystal, Color("e7c6ff"))
			draw_polyline(_closed_polyline(crystal), Color("5d2d83"), 1.6, true)
		GameTypes.CellType.POWER_ATTACK:
			draw_polyline(PackedVector2Array([
				center + Vector2(-9, 11),
				center + Vector2(-2, -10),
				center + Vector2(3, -2),
				center + Vector2(10, -12),
			]), Color("fff1d6"), 3.2, true)
		GameTypes.CellType.POWER_SHIELD:
			var shield: PackedVector2Array = PackedVector2Array([
				center + Vector2(0, -12),
				center + Vector2(12, -5),
				center + Vector2(8, 11),
				center + Vector2(0, 16),
				center + Vector2(-8, 11),
				center + Vector2(-12, -5),
			])
			draw_colored_polygon(shield, Color(1.0, 1.0, 1.0, 0.3))
			draw_polyline(_closed_polyline(shield), Color("d6efff"), 1.8, true)
		GameTypes.CellType.POWER_BONUS_MOVE:
			draw_polyline(PackedVector2Array([
				center + Vector2(-10, 4),
				center + Vector2(0, -10),
				center + Vector2(10, 4),
			]), Color("f0fff5"), 2.2, true)
			draw_polyline(PackedVector2Array([
				center + Vector2(-10, 10),
				center + Vector2(0, -4),
				center + Vector2(10, 10),
			]), Color("c6ffdb"), 2.2, true)
		_:
			pass


func _draw_qtank(center: Vector2, player_color: Color, accent_color: Color) -> void:
	var chassis: PackedVector2Array = PackedVector2Array([
		center + Vector2(0, -16),
		center + Vector2(13, -4),
		center + Vector2(11, 11),
		center + Vector2(0, 15),
		center + Vector2(-11, 11),
		center + Vector2(-13, -4),
	])
	var canopy: PackedVector2Array = PackedVector2Array([
		center + Vector2(0, -10),
		center + Vector2(8, -1),
		center + Vector2(0, 8),
		center + Vector2(-8, -1),
	])
	var stabilizer_left: PackedVector2Array = PackedVector2Array([
		center + Vector2(-15, -2),
		center + Vector2(-10, 8),
		center + Vector2(-5, 5),
		center + Vector2(-8, -4),
	])
	var stabilizer_right: PackedVector2Array = PackedVector2Array([
		center + Vector2(15, -2),
		center + Vector2(10, 8),
		center + Vector2(5, 5),
		center + Vector2(8, -4),
	])
	draw_colored_polygon(chassis, player_color.darkened(0.15))
	draw_colored_polygon(stabilizer_left, player_color.darkened(0.3))
	draw_colored_polygon(stabilizer_right, player_color.darkened(0.3))
	draw_line(center + Vector2(0, -15), center + Vector2(0, -27), accent_color, 3.0)
	draw_circle(center + Vector2(0, -28), 2.8, accent_color)
	draw_colored_polygon(canopy, Color("101722"))
	draw_polyline(_closed_polyline(chassis), Color("eff7ff"), 1.5, true)
	draw_line(center + Vector2(-7, 6), center + Vector2(7, 6), accent_color, 1.6)


func _draw_ktank(center: Vector2, player_color: Color, accent_color: Color) -> void:
	var treads: PackedVector2Array = PackedVector2Array([
		center + Vector2(-16, -8),
		center + Vector2(16, -8),
		center + Vector2(16, 10),
		center + Vector2(-16, 10),
	])
	var hull: PackedVector2Array = PackedVector2Array([
		center + Vector2(0, -14),
		center + Vector2(14, -7),
		center + Vector2(15, 5),
		center + Vector2(0, 13),
		center + Vector2(-15, 5),
		center + Vector2(-14, -7),
	])
	draw_colored_polygon(treads, Color("141922"))
	draw_colored_polygon(hull, player_color.darkened(0.08))
	draw_circle(center + Vector2(0, -1), 7.5, Color("0f141d"))
	draw_circle(center + Vector2(0, -1), 4.2, accent_color)
	draw_line(center + Vector2(0, -1), center + Vector2(0, -21), Color("0f141d"), 5.0)
	draw_line(center + Vector2(0, -1), center + Vector2(0, -21), accent_color, 2.2)
	draw_line(center + Vector2(-11, 2), center + Vector2(11, 2), accent_color.darkened(0.25), 1.8)
	draw_polyline(_closed_polyline(hull), Color("eff7ff"), 1.6, true)
	for track_x in [-10.0, -3.0, 4.0, 11.0]:
		draw_circle(center + Vector2(track_x, 11), 1.5, Color("445061"))


func _scaled_points(points: PackedVector2Array, center: Vector2, amount: float) -> PackedVector2Array:
	var scaled: PackedVector2Array = PackedVector2Array()
	for point: Vector2 in points:
		scaled.append(center + (point - center) * amount)
	return scaled


func _closed_polyline(points: PackedVector2Array) -> PackedVector2Array:
	var outline: PackedVector2Array = points.duplicate()
	if not outline.is_empty():
		outline.append(outline[0])
	return outline


func _ellipse_points(center: Vector2, radii: Vector2, segments: int) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for index in range(segments):
		var angle: float = TAU * float(index) / float(maxi(segments, 3))
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	return points


func _process_effects(delta: float) -> void:
	_tick_effect_array(_beam_effects, delta)
	_tick_effect_array(_ring_effects, delta)
	_tick_effect_array(_flash_effects, delta)
	_tick_effect_array(_floating_texts, delta)
	if _shake_timer > 0.0:
		_shake_timer = maxf(0.0, _shake_timer - delta)
		var shake_ratio: float = _shake_timer / maxf(_shake_strength, 0.001)
		var offset_scale: float = 5.0 * shake_ratio
		_shake_offset = Vector2(randf_range(-offset_scale, offset_scale), randf_range(-offset_scale * 0.7, offset_scale * 0.7))
	else:
		_shake_offset = Vector2.ZERO


func _tick_effect_array(effect_array: Array[Dictionary], delta: float) -> void:
	for index in range(effect_array.size() - 1, -1, -1):
		var effect: Dictionary = effect_array[index]
		effect["time_left"] = _effect_float(effect, "time_left", 0.0) - delta
		if _effect_float(effect, "time_left", 0.0) <= 0.0:
			effect_array.remove_at(index)
		else:
			effect_array[index] = effect


func _apply_event_feedback(current_state: GameState, event_item: GameEvent) -> void:
	match event_item.event_name:
		"hit_tank":
			var hit_coord: HexCoord = HexCoord.from_key(str(event_item.payload.get("coord", "")))
			var hit_center: Vector2 = hit_coord.to_world_flat(hex_size)
			var damage: int = int(event_item.payload.get("damage", 0))
			_flash_effects.append({
				"center": hit_center,
				"color": Color("ffb0b8"),
				"radius": 18.0,
				"time_left": 0.24,
				"duration": 0.24,
			})
			_floating_texts.append({
				"center": hit_center,
				"text": "-%d" % damage,
				"color": Color("fff1f3"),
				"time_left": 0.7,
				"duration": 0.7,
			})
			_trigger_shake(0.18)
		"hit_cell":
			var cell_coord: HexCoord = HexCoord.from_key(str(event_item.payload.get("coord", "")))
			var cell_center: Vector2 = cell_coord.to_world_flat(hex_size)
			_flash_effects.append({
				"center": cell_center,
				"color": Color("ffd59e"),
				"radius": 15.0,
				"time_left": 0.2,
				"duration": 0.2,
			})
			if bool(event_item.payload.get("destroyed", false)):
				_ring_effects.append({
					"center": cell_center,
					"color": Color("ffcf7a"),
					"radius": 24.0,
					"time_left": 0.32,
					"duration": 0.32,
					"filled": true,
				})
			_trigger_shake(0.14)
		"power_up":
			var actor_id: String = str(event_item.payload.get("actor_id", ""))
			var buff_tank: TankData = current_state.get_tank(actor_id)
			if buff_tank != null:
				_ring_effects.append({
					"center": buff_tank.position.to_world_flat(hex_size),
					"color": _buff_color(buff_tank.active_buff),
					"radius": 22.0,
					"time_left": 0.45,
					"duration": 0.45,
					"filled": true,
				})
		"tank_destroyed":
			var destroyed_id: String = str(event_item.payload.get("target", ""))
			var destroyed_tank: TankData = current_state.get_tank(destroyed_id)
			if destroyed_tank != null:
				_ring_effects.append({
					"center": destroyed_tank.position.to_world_flat(hex_size),
					"color": Color("ffd09b"),
					"radius": 34.0,
					"time_left": 0.48,
					"duration": 0.48,
					"filled": true,
				})
			_trigger_shake(0.3)
		"win_center":
			_ring_effects.append({
				"center": HexCoord.new().to_world_flat(hex_size),
				"color": Color("fff1a9"),
				"radius": 38.0,
				"time_left": 0.6,
				"duration": 0.6,
				"filled": true,
			})


func _play_attack_effect(previous_state: GameState, action: ActionData) -> void:
	var attacker: TankData = previous_state.get_tank(action.actor_id)
	if attacker == null:
		return
	var source_center: Vector2 = attacker.position.to_world_flat(hex_size)
	if attacker.tank_type == GameTypes.TankType.QTANK:
		var target_center: Vector2 = source_center
		for step_coord: HexCoord in attacker.position.raycast(action.direction, previous_state.board.rings * 3):
			if not previous_state.board.has_cell(step_coord):
				break
			target_center = step_coord.to_world_flat(hex_size)
			if previous_state.get_tank_at(step_coord) != null or previous_state.board.blocks_attack(step_coord):
				break
		_beam_effects.append({
			"start": source_center,
			"end": target_center,
			"color": Color("7ef3ff"),
			"width": 5.0,
			"time_left": 0.18,
			"duration": 0.18,
		})
		_ring_effects.append({
			"center": target_center,
			"color": Color("b7ffff"),
			"radius": 18.0,
			"time_left": 0.22,
			"duration": 0.22,
			"filled": false,
		})
		_trigger_shake(0.16)
	else:
		_ring_effects.append({
			"center": source_center,
			"color": Color("ffb46f"),
			"radius": 26.0,
			"time_left": 0.32,
			"duration": 0.32,
			"filled": true,
		})
		for neighbor_coord: HexCoord in attacker.position.neighbors():
			if previous_state.board.has_cell(neighbor_coord):
				_flash_effects.append({
					"center": neighbor_coord.to_world_flat(hex_size),
					"color": Color("ff936d"),
					"radius": 12.0,
					"time_left": 0.22,
					"duration": 0.22,
				})
		_trigger_shake(0.24)


func _trigger_shake(duration: float) -> void:
	_shake_timer = maxf(_shake_timer, duration)
	_shake_strength = maxf(_shake_strength, duration)


func clear_transient_effects() -> void:
	_beam_effects.clear()
	_ring_effects.clear()
	_flash_effects.clear()
	_floating_texts.clear()
	_shake_timer = 0.0
	_shake_strength = 0.0
	_shake_offset = Vector2.ZERO
	queue_redraw()


func _effect_vec2(effect: Dictionary, key: String, default_value: Vector2) -> Vector2:
	var value: Variant = effect.get(key, default_value)
	if value is Vector2:
		return value
	return default_value


func _effect_color(effect: Dictionary, key: String, default_value: Color) -> Color:
	var value: Variant = effect.get(key, default_value)
	if value is Color:
		return value
	return default_value


func _effect_float(effect: Dictionary, key: String, default_value: float) -> float:
	var value: Variant = effect.get(key, default_value)
	return float(value)


func _effect_bool(effect: Dictionary, key: String, default_value: bool) -> bool:
	var value: Variant = effect.get(key, default_value)
	return bool(value)


func _effect_string(effect: Dictionary, key: String, default_value: String) -> String:
	var value: Variant = effect.get(key, default_value)
	return str(value)


func _buff_color(buff_type: int) -> Color:
	match buff_type:
		GameTypes.BuffType.ATTACK_MULTIPLIER:
			return Color("ff8c69")
		GameTypes.BuffType.SHIELD_BUFFER:
			return Color("7cc3ff")
		GameTypes.BuffType.BONUS_MOVE:
			return Color("69e59d")
		_:
			return Color.WHITE
