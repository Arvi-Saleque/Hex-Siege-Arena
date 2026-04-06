class_name TankData
extends Resource

const QTANK_HP := 8
const KTANK_HP := 10
const QTANK_DAMAGE := 2
const KTANK_DAMAGE := 3
const QTANK_MOVE_RANGE := 10
const KTANK_MOVE_RANGE := 2

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
	var duplicate: TankData = TankData.new(tank_type, position.clone(), hp, max_hp, owner_id)
	duplicate.active_buff = active_buff
	duplicate.shield_hits_remaining = shield_hits_remaining
	return duplicate


func actor_id() -> String:
	return "%d_%d" % [owner_id, tank_type]


func is_alive() -> bool:
	return hp > 0


func get_move_range() -> int:
	return QTANK_MOVE_RANGE if tank_type == GameTypes.TankType.QTANK else KTANK_MOVE_RANGE


func get_base_damage() -> int:
	return QTANK_DAMAGE if tank_type == GameTypes.TankType.QTANK else KTANK_DAMAGE


func get_attack_damage() -> int:
	var damage: int = get_base_damage()
	if active_buff == GameTypes.BuffType.ATTACK_MULTIPLIER:
		damage *= 2
	return damage


func apply_buff(buff_type: int) -> void:
	active_buff = buff_type
	if buff_type == GameTypes.BuffType.SHIELD_BUFFER:
		shield_hits_remaining = 2
	elif buff_type != GameTypes.BuffType.BONUS_MOVE:
		shield_hits_remaining = 0


func consume_attack_buff_if_needed() -> void:
	if active_buff == GameTypes.BuffType.ATTACK_MULTIPLIER:
		active_buff = GameTypes.BuffType.NONE


func take_damage(amount: int) -> int:
	if shield_hits_remaining > 0:
		shield_hits_remaining -= 1
		if shield_hits_remaining <= 0 and active_buff == GameTypes.BuffType.SHIELD_BUFFER:
			active_buff = GameTypes.BuffType.NONE
		return 0

	var applied: int = mini(amount, hp)
	hp -= applied
	return applied


static func create_default_qtank(owner_id: int, coord: HexCoord) -> TankData:
	return TankData.new(GameTypes.TankType.QTANK, coord, QTANK_HP, QTANK_HP, owner_id)


static func create_default_ktank(owner_id: int, coord: HexCoord) -> TankData:
	return TankData.new(GameTypes.TankType.KTANK, coord, KTANK_HP, KTANK_HP, owner_id)
