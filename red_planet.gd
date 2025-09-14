extends AnimatableBody2D
class_name Planet

@export var rand_linear_velocity_range: Vector2 = Vector2(750.0, 1000.0)
#export(Vector2) var rand_angular_velocity_range = Vector2(-10.0, 10.0)
@export var radius: float = 250.0
@export var smoothing : int = 1 # (int, 0, 5, 1)

@export var placed_in_level: bool = false
@export var randomize_texture_properties: bool = true
@export var poly_texture: Texture2D

@onready var _polygon2d := $Polygon2D
@onready var _col_polygon2d := $CollisionPolygon2D
@onready var _rng := RandomNumberGenerator.new()



func _ready() -> void:
	_col_polygon2d.polygon = _polygon2d.polygon
	
	var childs = get_children()
	for child in get_children():
		if child is PlanetArea:
			child.setup.set_master(self)
	#$GravityArea.set_master(self)
	#$OwnerArea.set_master(self)
	
	_rng.randomize()
	if placed_in_level:
		var poly = PolygonLib.createCirclePolygon(radius, smoothing)
		setPolygon(poly)
		
		#linear_velocity = Vector2.RIGHT.rotated(PI * 2.0 * _rng.randf()) * _rng.randf_range(rand_linear_velocity_range.x, rand_linear_velocity_range.y)
		
		_polygon2d.texture = poly_texture
		
		
		if randomize_texture_properties and is_instance_valid(poly_texture):
			var rand_scale : float = _rng.randf_range(0.25, 0.75)
			var t_size = poly_texture.get_size() / rand_scale
			var offset_range = t_size.x * 0.25
			_polygon2d.texture_offset = (t_size / 2) + Vector2(_rng.randf_range(-offset_range, offset_range), _rng.randf_range(-offset_range, offset_range))
			_polygon2d.texture_scale = Vector2(rand_scale, rand_scale)*10
			_polygon2d.texture_rotation = _rng.randf_range(0.0, PI * 2.0)
			#_polygon2d.texture_offset = Vector2(_rng.randf_range(-500, 500), _rng.randf_range(-500, 500))



func getGlobalRotPolygon() -> float:
	return _polygon2d.global_rotation

func setPolygon(poly : PackedVector2Array) -> void:
	_polygon2d.set_polygon(poly)
	_col_polygon2d.set_polygon(poly)
	poly.append(poly[0])
	#_line2d.points = poly


func setTexture(texture_info : Dictionary) -> void:
	_polygon2d.texture = texture_info.texture
	_polygon2d.texture_scale = texture_info.scale
	_polygon2d.texture_offset = texture_info.offset
	_polygon2d.texture_rotation = texture_info.rot


func getTextureInfo() -> Dictionary:
	return {"texture" : _polygon2d.texture, "rot" : _polygon2d.texture_rotation, "offset" : _polygon2d.texture_offset, "scale" : _polygon2d.texture_scale}


func getPolygon() -> PackedVector2Array:
	return _polygon2d.get_polygon()


func get_polygon() -> PackedVector2Array:
	return getPolygon()

func set_polygon(poly : PackedVector2Array) -> void:
	setPolygon(poly)
	
func get_shape_transform() -> Transform2D:
	return _col_polygon2d.global_transform
