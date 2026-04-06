class_name HexCoord
extends RefCounted

const DIRECTIONS := [
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1),
]

var q: int
var r: int


func _init(p_q: int = 0, p_r: int = 0) -> void:
	q = p_q
	r = p_r


func clone() -> HexCoord:
	return HexCoord.new(q, r)


func add(other: HexCoord) -> HexCoord:
	return HexCoord.new(q + other.q, r + other.r)


func neighbor(direction: int) -> HexCoord:
	var vector := DIRECTIONS[wrapi(direction, 0, DIRECTIONS.size())]
	return HexCoord.new(q + vector.x, r + vector.y)


func distance_to(other: HexCoord) -> int:
	var s := -q - r
	var other_s := -other.q - other.r
	var dq := abs(q - other.q)
	var dr := abs(r - other.r)
	var ds := abs(s - other_s)
	return maxi(maxi(dq, dr), ds)


func to_vector2i() -> Vector2i:
	return Vector2i(q, r)


func key() -> String:
	return "%s,%s" % [q, r]


func equals(other: HexCoord) -> bool:
	return q == other.q and r == other.r


func _to_string() -> String:
	return "HexCoord(%d, %d)" % [q, r]
