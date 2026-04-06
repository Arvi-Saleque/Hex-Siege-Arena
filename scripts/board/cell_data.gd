class_name CellData
extends Resource

const TYPE_HP := {
	GameTypes.CellType.EMPTY: 0,
	GameTypes.CellType.CENTER: 0,
	GameTypes.CellType.WALL: 0,
	GameTypes.CellType.BLOCK: 2,
	GameTypes.CellType.ARMOR_BLOCK: 3,
	GameTypes.CellType.POWER_BLOCK: 2,
	GameTypes.CellType.POWER_ATTACK: 0,
	GameTypes.CellType.POWER_SHIELD: 0,
	GameTypes.CellType.POWER_BONUS_MOVE: 0,
}

var coord: HexCoord
var cell_type: int = GameTypes.CellType.EMPTY
var hp: int = 0


func _init(p_coord: HexCoord = null, p_cell_type: int = GameTypes.CellType.EMPTY, p_hp: int = 0) -> void:
	coord = p_coord if p_coord != null else HexCoord.new()
	cell_type = p_cell_type
	hp = p_hp if p_hp > 0 else get_default_hp_for_type(p_cell_type)


func clone() -> CellData:
	return CellData.new(coord.clone(), cell_type, hp)


func set_type(new_type: int) -> void:
	cell_type = new_type
	hp = get_default_hp_for_type(new_type)


static func get_default_hp_for_type(query_type: int) -> int:
	return TYPE_HP.get(query_type, 0)
