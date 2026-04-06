class_name TankData
extends Resource

var tank_type: int = GameTypes.TankType.QTANK
var position: HexCoord = HexCoord.new()
var hp: int = 0
var max_hp: int = 0
var owner_id: int = 1
var active_buff: int = GameTypes.BuffType.NONE
var shield_hits_remaining: int = 0


func _init(
	p_tank_type: int = GameTypes.TankType.QTANK,
	p_position: HexCoord = null,
	p_hp: int = 0,
	p_max_hp: int = 0,
	p_owner_id: int = 1
) -> void:
	tank_type = p_tank_type
	position = p_position if p_position != null else HexCoord.new()
	hp = p_hp
	max_hp = p_max_hp
	owner_id = p_owner_id


func clone() -> TankData:
	var duplicate := TankData.new(tank_type, position.clone(), hp, max_hp, owner_id)
	duplicate.active_buff = active_buff
	duplicate.shield_hits_remaining = shield_hits_remaining
	return duplicate
