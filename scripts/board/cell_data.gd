class_name CellData
extends Resource

var coord: HexCoord
var cell_type: int = GameTypes.CellType.EMPTY
var hp: int = 0


func _init(p_coord: HexCoord = null, p_cell_type: int = GameTypes.CellType.EMPTY, p_hp: int = 0) -> void:
	coord = p_coord if p_coord != null else HexCoord.new()
	cell_type = p_cell_type
	hp = p_hp


func clone() -> CellData:
	return CellData.new(coord.clone(), cell_type, hp)
