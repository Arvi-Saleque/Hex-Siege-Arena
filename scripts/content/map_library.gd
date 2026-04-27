class_name MapLibrary
extends RefCounted


static func get_preset(map_id: String) -> MapPreset:
	match map_id:
		"labyrinth":
			return _build_labyrinth_preset()
		"open":
			return _build_open_preset()
		"fortress":
			return _build_fortress_preset()
		_:
			return _build_standard_preset()


static func _build_standard_preset() -> MapPreset:
	var terrain_entries: Array[Dictionary] = []
	var wall_coords: Array[String] = [
		"-4,2", "4,-2",
		"-3,0", "3,0",
		"-2,4", "2,-4",
	]
	var block_coords: Array[String] = [
		"0,4", "0,3", "0,-4", "0,-3",
		"-1,4", "1,4", "1,3",
		"1,-4", "-1,-4", "-1,-3",
		"-4,4", "4,-4",
		"-3,3", "3,-3",
		"-1,2", "1,-2",
		"-2,1", "2,-1",
	]
	var armor_coords: Array[String] = [
		"-1,1", "1,-1",
		"-2,2", "2,-2",
	]
	for coord_key: String in wall_coords:
		terrain_entries.append(_entry(coord_key, GameTypes.CellType.WALL))
	for coord_key: String in block_coords:
		terrain_entries.append(_entry(coord_key, GameTypes.CellType.BLOCK))
	for coord_key: String in armor_coords:
		terrain_entries.append(_entry(coord_key, GameTypes.CellType.ARMOR_BLOCK))
	terrain_entries.append_array([
		_entry("0,2", GameTypes.CellType.POWER_BLOCK, GameTypes.CellType.POWER_ATTACK),
		_entry("0,-2", GameTypes.CellType.POWER_BLOCK, GameTypes.CellType.POWER_SHIELD),
		_entry("-3,2", GameTypes.CellType.POWER_BLOCK, GameTypes.CellType.POWER_BONUS_MOVE),
		_entry("3,-2", GameTypes.CellType.POWER_BLOCK, GameTypes.CellType.POWER_BONUS_MOVE),
		_entry("-4,1", GameTypes.CellType.POWER_ATTACK),
		_entry("4,-1", GameTypes.CellType.POWER_SHIELD),
		_entry("-2,5", GameTypes.CellType.POWER_BONUS_MOVE),
		_entry("2,-5", GameTypes.CellType.POWER_BONUS_MOVE),
	])
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
		"Siege Works",
		"Bomber-style arena with destructible gates, shielded center lanes, and power crates that must be opened before direct pressure is safe.",
		6,
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


static func _build_labyrinth_preset() -> MapPreset:
	var terrain_entries: Array[Dictionary] = []
	var wall_coords: Array[String] = [
		"-4,1", "4,-1",
		"-3,-1", "3,1",
		"-1,4", "1,-4",
		"1,3", "-1,-3",
		"-4,3", "4,-3",
		"-3,4", "3,-4",
	]
	var block_coords: Array[String] = [
		"-2,0", "2,0",
		"-2,2", "2,-2",
		"0,2", "0,-2",
		"-1,2", "1,-2",
		"-2,1", "2,-1",
		"-3,2", "3,-2",
		"-2,3", "2,-3",
		"-5,1", "5,-1",
		"-1,5", "1,-5",
	]
	var armor_coords: Array[String] = [
		"-1,1", "1,-1",
		"-3,1", "3,-1",
		"-1,3", "1,-3",
		"0,4", "0,-4",
	]
	for coord_key: String in wall_coords:
		terrain_entries.append(_entry(coord_key, GameTypes.CellType.WALL))
	for coord_key: String in block_coords:
		terrain_entries.append(_entry(coord_key, GameTypes.CellType.BLOCK))
	for coord_key: String in armor_coords:
		terrain_entries.append(_entry(coord_key, GameTypes.CellType.ARMOR_BLOCK))
	terrain_entries.append_array([
		_entry("0,1", GameTypes.CellType.POWER_BLOCK, GameTypes.CellType.POWER_ATTACK),
		_entry("0,-1", GameTypes.CellType.POWER_BLOCK, GameTypes.CellType.POWER_SHIELD),
		_entry("-4,0", GameTypes.CellType.POWER_ATTACK),
		_entry("4,0", GameTypes.CellType.POWER_SHIELD),
		_entry("-2,4", GameTypes.CellType.POWER_BONUS_MOVE),
		_entry("2,-4", GameTypes.CellType.POWER_BONUS_MOVE),
	])
	var spawns: Dictionary = {
		1: {
			GameTypes.TankType.QTANK: "-6,6",
			GameTypes.TankType.KTANK: "0,6",
		},
		2: {
			GameTypes.TankType.QTANK: "6,-6",
			GameTypes.TankType.KTANK: "0,-6",
		},
	}
	return MapPreset.new(
		"labyrinth",
		"Labyrinth Arena",
		"Larger tactical map with denser obstacles, layered approaches, and more meaningful path optimization.",
		6,
		terrain_entries,
		spawns
	)


static func _entry(coord_key: String, cell_type: int, reveal_type: int = -1) -> Dictionary:
	return {
		"coord": coord_key,
		"type": cell_type,
		"reveal_type": reveal_type,
	}
