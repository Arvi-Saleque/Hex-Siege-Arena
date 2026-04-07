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


func _ready() -> void:
	if game_state == null:
		board_state.load_map_preset(MapLibrary.get_preset("standard"))
	set_process_input(true)
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_pulse_time += delta
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
	return center


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
	draw_circle(used_rect.position + Vector2(used_rect.size.x * 0.3, used_rect.size.y * 0.28), 180.0, Color(0.2, 0.32, 0.48, 0.08))
	draw_circle(used_rect.position + Vector2(used_rect.size.x * 0.72, used_rect.size.y * 0.62), 210.0, Color(0.66, 0.55, 0.2, 0.05))
	draw_circle(used_rect.position + Vector2(used_rect.size.x * 0.5, used_rect.size.y * 0.48), 290.0, Color(0.08, 0.12, 0.2, 0.25))


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
