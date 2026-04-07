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

var hex_size: float = 34.0
var board_state: BoardState = BoardState.new()
var game_state: GameState
var hovered_key: String = ""
var selected_key: String = ""
var selected_actor_id: String = ""
var highlighted_keys: Dictionary = {}
var current_action_mode: String = ""


func _ready() -> void:
	if game_state == null:
		board_state.load_map_preset(MapLibrary.get_preset("standard"))
	set_process_input(true)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_update_hover(to_local(event.position))
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_hex(to_local(event.position))


func _draw() -> void:
	var active_board: BoardState = _active_board()
	for cell: CellData in active_board.cells.values():
		var center: Vector2 = cell.coord.to_world_flat(hex_size)
		var fill: Color = COLOR_BY_TYPE.get(cell.cell_type, Color.DIM_GRAY)
		if highlighted_keys.has(cell.coord.key()):
			fill = fill.lerp(highlighted_keys[cell.coord.key()], 0.45)
		if cell.coord.key() == hovered_key:
			fill = fill.lerp(Color.WHITE, 0.18)
		if cell.coord.key() == selected_key:
			fill = fill.lerp(Color("67f0ff"), 0.35)

		var points: PackedVector2Array = _hex_points(center)
		draw_colored_polygon(points, fill)
		var outline: PackedVector2Array = points.duplicate()
		outline.append(points[0])
		draw_polyline(outline, Color("0f131a"), 2.0, true)
		if cell.cell_type == GameTypes.CellType.CENTER:
			draw_arc(center, hex_size * 0.52, 0.0, TAU, 48, Color("fff2a8"), 2.0, true)
		if highlighted_keys.has(cell.coord.key()) and current_action_mode != "":
			var preview_outline: PackedVector2Array = points.duplicate()
			preview_outline.append(points[0])
			var preview_color: Color = Color("63e38f") if current_action_mode == "move" else Color("ff7a86")
			draw_polyline(preview_outline, preview_color, 3.0, true)

	if game_state != null:
		_draw_tanks()


func _hex_points(center: Vector2) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for index in range(6):
		var angle: float = deg_to_rad(60.0 * index)
		points.append(center + Vector2(cos(angle), sin(angle)) * hex_size)
	return points


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


func _active_board() -> BoardState:
	return game_state.board if game_state != null else board_state


func _draw_tanks() -> void:
	var font: Font = ThemeDB.fallback_font
	for tank: TankData in game_state.get_all_tanks():
		if not tank.is_alive():
			continue
		var center: Vector2 = tank.position.to_world_flat(hex_size)
		var player_color: Color = Color("72a7ff") if tank.owner_id == 1 else Color("ff6978")
		if tank.owner_id == game_state.current_player:
			draw_arc(center, 20.0, 0.0, TAU, 40, player_color.lerp(Color.WHITE, 0.2), 2.5, true)
		if tank.actor_id() == selected_actor_id:
			draw_circle(center, 18.0, player_color.lerp(Color.WHITE, 0.3))
		else:
			draw_circle(center, 15.0, player_color)

		if tank.tank_type == GameTypes.TankType.QTANK:
			var triangle: PackedVector2Array = PackedVector2Array([
				center + Vector2(0, -10),
				center + Vector2(9, 8),
				center + Vector2(-9, 8),
			])
			draw_colored_polygon(triangle, Color("141821"))
		else:
			draw_circle(center, 8.0, Color("141821"))

		if font != null:
			var label: String = "Q" if tank.tank_type == GameTypes.TankType.QTANK else "K"
			draw_string(font, center + Vector2(-6, 24), "%s%d" % [label, tank.owner_id], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color.WHITE)
			draw_string(font, center + Vector2(-10, -20), "%d" % tank.hp, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color("f5f7fb"))

		if tank.active_buff != GameTypes.BuffType.NONE:
			var buff_color: Color = _buff_color(tank.active_buff)
			draw_circle(center + Vector2(13, -13), 5.0, buff_color)
			draw_circle(center + Vector2(13, -13), 2.0, Color("10141c"))


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
