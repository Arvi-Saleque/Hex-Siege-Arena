class_name BoardDebugView
extends Node2D

signal hovered_cell_changed(summary: String)
signal selected_cell_changed(summary: String)

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
var hovered_key: String = ""
var selected_key: String = ""


func _ready() -> void:
	board_state.create_phase2_debug_terrain()
	set_process_unhandled_input(true)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_update_hover(to_local(event.position))
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_hex(to_local(event.position))


func _draw() -> void:
	for cell: CellData in board_state.cells.values():
		var center := cell.coord.to_world_flat(hex_size)
		var fill := COLOR_BY_TYPE.get(cell.cell_type, Color.DIM_GRAY)
		if cell.coord.key() == hovered_key:
			fill = fill.lerp(Color.WHITE, 0.18)
		if cell.coord.key() == selected_key:
			fill = fill.lerp(Color("67f0ff"), 0.35)

		var points := _hex_points(center)
		draw_colored_polygon(points, fill)
		var outline := points.duplicate()
		outline.append(points[0])
		draw_polyline(outline, Color("0f131a"), 2.0, true)


func _hex_points(center: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(6):
		var angle := deg_to_rad(60.0 * index)
		points.append(center + Vector2(cos(angle), sin(angle)) * hex_size)
	return points


func _update_hover(local_position: Vector2) -> void:
	var coord := HexCoord.from_world_flat(local_position, hex_size)
	var new_key := coord.key() if board_state.has_cell(coord) else ""
	if new_key == hovered_key:
		return
	hovered_key = new_key
	hovered_cell_changed.emit(_build_summary(coord, board_state.get_cell(coord)) if new_key != "" else "Hover: outside board")
	queue_redraw()


func _select_hex(local_position: Vector2) -> void:
	var coord := HexCoord.from_world_flat(local_position, hex_size)
	if not board_state.has_cell(coord):
		return
	selected_key = coord.key()
	selected_cell_changed.emit(_build_summary(coord, board_state.get_cell(coord)))
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
