class_name BoardState
extends Resource

const DEFAULT_RINGS := 5

var rings: int = DEFAULT_RINGS
var cells: Dictionary = {}


func _init(p_rings: int = DEFAULT_RINGS) -> void:
	rings = p_rings


func set_cell(cell: CellData) -> void:
	cells[cell.coord.key()] = cell


func get_cell(coord: HexCoord) -> CellData:
	return cells.get(coord.key())


func has_cell(coord: HexCoord) -> bool:
	return cells.has(coord.key())


func clone() -> BoardState:
	var duplicate := BoardState.new(rings)
	for key: String in cells.keys():
		duplicate.cells[key] = (cells[key] as CellData).clone()
	return duplicate
