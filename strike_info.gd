extends Resource
class_name StrikeInfo

@export var size: Vector2 = Vector2.ONE
@export var poly: PackedVector2Array = []:
	set(val):
		poly = val
		area = PolygonLib.getPolygonArea(val)
@export var transform: Transform2D
@export var force: float = 0.0
var area: float = 0
