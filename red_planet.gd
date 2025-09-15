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
var core_node: Node2D = null
@onready var _pool_fracture_shards := $Pool_FractureShards

@onready var polyFracture := PolygonFracture.new()



func _ready() -> void:
	_col_polygon2d.polygon = _polygon2d.polygon
	var core_node = get_node("Core")
	
	var childs = get_children()
	for child in get_children():
		if child is PlanetArea:
			child.setup.set_master(self)

func _physics_process(delta: float) -> void:
	if core_node:
		core_node.rotate(0.01 * delta)

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
	
func append_strike(strike: StrikeInfo):
	var cut_fracture_info: Dictionary = polyFracture.cutFracture(self.get_polygon(), strike.poly, self.global_transform,  Transform2D(), 0, 0, 0, 0)
	set_polygon(cut_fracture_info.shapes[0].shape)
	##var body: RigidShape = rigidbody_template.instantiate()
	var total_area : float = PolygonLib.getPolygonArea(strike.poly)
	for fracture in cut_fracture_info.fractures:
		for fracture_shard in fracture:
			var area_p : float = fracture_shard.area / total_area
			var rand_lifetime : float = _rng.randf_range(.1, 1) #+ 2.0 * area_p
			spawnFractureBody(fracture_shard, self.getTextureInfo(), 100, rand_lifetime)
	pass
	
func spawnFractureBody(fracture_shard : Dictionary, texture_info : Dictionary, new_mass : float, life_time : float) -> void:
	var instance: FractureShard = _pool_fracture_shards.getInstance()
	if not instance:
		return
	
	var dir : Vector2 = (fracture_shard.spawn_pos - fracture_shard.source_global_trans.get_origin()).normalized()
	instance.spawn(fracture_shard.spawn_pos, fracture_shard.spawn_rot, fracture_shard.source_global_trans.get_scale(), life_time)
	instance.setPolygon(fracture_shard.centered_shape, Color(1,1,1,.7), PolygonLib.setTextureOffset(texture_info, fracture_shard.centroid))
	instance.setMass(new_mass)
