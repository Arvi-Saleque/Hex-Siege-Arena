class_name MapLibrary
extends RefCounted


static func get_preset(map_id: String) -> MapPreset:
	match map_id:
		"open":
			return _build_open_preset()
		"fortress":
			return _build_fortress_preset()
		_:
			return _build_standard_preset()


static func _build_standard_preset() -> MapPreset:
	var terrain_entries: Array[Dictionary] = [
		_entry("1,0", GameTypes.CellType.WALL),
		_entry("-1,0", GameTypes.CellType.BLOCK),
		_entry("0,-1", GameTypes.CellType.ARMOR_BLOCK),
		_entry("0,1", GameTypes.CellType.POWER_BLOCK, GameTypes.CellType.POWER_BONUS_MOVE),
		_entry("2,-1", GameTypes.CellType.POWER_ATTACK),
		_entry("-2,1", GameTypes.CellType.POWER_SHIELD),
		_entry("1,-2", GameTypes.CellType.POWER_BONUS_MOVE),
	]
	var spawns: Dictionary = {
		1: {
			GameTypes.TankType.QTANK: "-5,5",
			GameTypes.TankType.KTANK: "0,5",
		},
		2: {
			GameTypes.TankType.QTANK: "5,-5",
			GameTypes.TankType.KTANK: "0,-5",
		},
	}
	return MapPreset.new(
		"standard",
		"Standard Arena",
		"Balanced central skirmish map with one hidden bonus tile and three exposed power lanes.",
		5,
		terrain_entries,
		spawns
	)


static func _build_open_preset() -> MapPreset:
	var terrain_entries: Array[Dictionary] = [
		_entry("-1,1", GameTypes.CellType.POWER_BLOCK, GameTypes.CellType.POWER_ATTACK),
		_entry("1,-1", GameTypes.CellType.POWER_BLOCK, GameTypes.CellType.POWER_SHIELD),
		_entry("0,2", GameTypes.CellType.POWER_BONUS_MOVE),
		_entry("0,-2", GameTypes.CellType.POWER_BONUS_MOVE),
	]
	var spawns: Dictionary = {
		1: {
			GameTypes.TankType.QTANK: "-5,5",
			GameTypes.TankType.KTANK: "-1,5",
		},
		2: {
			GameTypes.TankType.QTANK: "5,-5",
			GameTypes.TankType.KTANK: "1,-5",
		},
	}
	return MapPreset.new(
		"open",
		"Open Arena",
		"Low-obstacle test map for AI benchmarking and movement-heavy matches.",
		5,
		terrain_entries,
		spawns
	)


static func _build_fortress_preset() -> MapPreset:
	var terrain_entries: Array[Dictionary] = [
		_entry("-2,0", GameTypes.CellType.WALL),
		_entry("-1,0", GameTypes.CellType.BLOCK),
		_entry("-1,1", GameTypes.CellType.ARMOR_BLOCK),
		_entry("1,-1", GameTypes.CellType.ARMOR_BLOCK),
		_entry("1,0", GameTypes.CellType.BLOCK),
		_entry("2,0", GameTypes.CellType.WALL),
		_entry("0,2", GameTypes.CellType.POWER_BLOCK, GameTypes.CellType.POWER_ATTACK),
		_entry("0,-2", GameTypes.CellType.POWER_BLOCK, GameTypes.CellType.POWER_SHIELD),
	]
	var spawns: Dictionary = {
		1: {
			GameTypes.TankType.QTANK: "-4,5",
			GameTypes.TankType.KTANK: "0,5",
		},
		2: {
			GameTypes.TankType.QTANK: "4,-5",
			GameTypes.TankType.KTANK: "0,-5",
		},
	}
	return MapPreset.new(
		"fortress",
		"Fortress Arena",
		"Obstacle-heavy map with tighter central approach lanes and delayed power reveals.",
		5,
		terrain_entries,
		spawns
	)


static func _entry(coord_key: String, cell_type: int, reveal_type: int = -1) -> Dictionary:
	return {
		"coord": coord_key,
		"type": cell_type,
		"reveal_type": reveal_type,
	}
