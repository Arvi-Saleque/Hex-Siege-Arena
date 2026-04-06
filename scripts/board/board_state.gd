class_name BoardState
extends Resource

const DEFAULT_RINGS := 5

var rings: int = DEFAULT_RINGS
var cells: Dictionary = {}


func _init(p_rings: int = DEFAULT_RINGS) -> void:
	rings = p_rings
	generate_empty_board()


func generate_empty_board() -> void:
	cells.clear()
	for coord: HexCoord in HexCoord.all_within_rings(rings):
		var cell_type: int = GameTypes.CellType.CENTER if coord.q == 0 and coord.r == 0 else GameTypes.CellType.EMPTY
		set_cell(CellData.new(coord, cell_type))


func set_cell(cell: CellData) -> void:
	cells[cell.coord.key()] = cell


func get_cell(coord: HexCoord) -> CellData:
	return cells.get(coord.key())


func has_cell(coord: HexCoord) -> bool:
	return cells.has(coord.key())


func is_walkable(coord: HexCoord) -> bool:
	var cell: CellData = get_cell(coord)
	return cell != null and cell.is_walkable()


func blocks_attack(coord: HexCoord) -> bool:
	var cell: CellData = get_cell(coord)
	return cell != null and cell.blocks_attack()


func all_cells() -> Array[CellData]:
	var results: Array[CellData] = []
	for cell: CellData in cells.values():
		results.append(cell)
	return results


func set_cell_type(coord: HexCoord, cell_type: int) -> void:
	var cell: CellData = get_cell(coord)
	if cell == null:
		cell = CellData.new(coord, cell_type)
		set_cell(cell)
	else:
		cell.set_type(cell_type)


func create_phase2_debug_terrain() -> void:
	set_cell_type(HexCoord.new(1, 0), GameTypes.CellType.WALL)
	set_cell_type(HexCoord.new(-1, 0), GameTypes.CellType.BLOCK)
	set_cell_type(HexCoord.new(0, -1), GameTypes.CellType.ARMOR_BLOCK)
	set_cell_type(HexCoord.new(0, 1), GameTypes.CellType.POWER_BLOCK)
	set_cell_type(HexCoord.new(2, -1), GameTypes.CellType.POWER_ATTACK)
	set_cell_type(HexCoord.new(-2, 1), GameTypes.CellType.POWER_SHIELD)
	set_cell_type(HexCoord.new(1, -2), GameTypes.CellType.POWER_BONUS_MOVE)


func apply_damage(coord: HexCoord, amount: int) -> Dictionary:
	var cell: CellData = get_cell(coord)
	if cell == null or not cell.is_destructible():
		return {"destroyed": false, "revealed_type": -1}

	cell.hp = maxi(0, cell.hp - amount)
	if cell.hp > 0:
		return {"destroyed": false, "revealed_type": -1}

	var revealed_type: int = -1
	if cell.cell_type == GameTypes.CellType.POWER_BLOCK:
		revealed_type = GameTypes.CellType.POWER_ATTACK
		cell.set_type(revealed_type)
	else:
		cell.set_type(GameTypes.CellType.EMPTY)

	return {"destroyed": true, "revealed_type": revealed_type}


func clone() -> BoardState:
	var duplicate: BoardState = BoardState.new(rings)
	duplicate.cells.clear()
	for key: String in cells.keys():
		duplicate.cells[key] = (cells[key] as CellData).clone()
	return duplicate
