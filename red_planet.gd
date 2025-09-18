extends AnimatableBody2D
class_name Planet

@export var destruction_levels: Array[DestructionLevel] = []
@export var rand_linear_velocity_range: Vector2 = Vector2(750.0, 1000.0)
#export(Vector2) var rand_angular_velocity_range = Vector2(-10.0, 10.0)
@export var radius: float = 250.0
@export var smoothing : int = 1 # (int, 0, 5, 1)

@export var placed_in_level: bool = false
@export var randomize_texture_properties: bool = true

@onready var _polygon2d: Polygon2D = null
@onready var _col_polygon2d: CollisionPolygon2D = null
@onready var _fracture_shards :PoolBasic = $FractureShards
@onready var _rng := RandomNumberGenerator.new()
var core_node: Node2D = null

var _pool_inst: PackedScene = preload("res://pool-manager/Pool2DBasic.tscn")
var _frac_shard_inst: PackedScene = preload("res://FractureShard.tscn")


@onready var polyFracture := PolygonFracture.new()
@onready var active_destruction_level: int = 0
var cp_pool: Array[CollisionPolygon2D] = []
@onready var outline_line: Line2D = Line2D.new()
@onready var outline_timer: Timer = Timer.new()
var outline_available: bool = false



func _ready() -> void:
	self.input_pickable = true
	self.mouse_shape_entered.connect(_on_mouse_shape_entered)
	self.mouse_entered.connect(_on_mouse_entered)
	add_child(outline_line)
	outline_line.closed = true
	outline_line.width = 2
	add_child(outline_timer)
	outline_timer.one_shot = true
	outline_timer.wait_time = 1
	outline_timer.timeout.connect(_on_outline_timer)
	#_pool_fracture_shards = _pool_inst.instantiate()
	#add_child(_pool_fracture_shards)
	#_pool_fracture_shards.placed_in_level = true
	#_pool_fracture_shards.instantiate_new_on_empty = true
	#_pool_fracture_shards.keep_instances_in_tree = true
	#_pool_fracture_shards.instance_template = _frac_shard_inst
	#_pool_fracture_shards.max_amount = 100
	
	#if has_node("Core"):
	#	core_node = get_node("Core")
	
	var childs = get_children()
	for child in get_children():
		if child is PlanetArea:
			child.setup.set_master(self)
	#destruction_levels[active_destruction_level].enable()
	enable_level(0)
	
func enable_level(level: int):
	_polygon2d = get_node(destruction_levels[level].poly[0])
	if len(cp_pool) < 1:
		cp_pool.append(CollisionPolygon2D.new())
	_col_polygon2d = cp_pool.pop_front()
	_col_polygon2d.polygon = _polygon2d.polygon
	_col_polygon2d.set_deferred("disabled", false)
	if not _col_polygon2d.get_parent():
		add_child(_col_polygon2d)
	
func disable_level(level: int, hide: bool = true):
	_col_polygon2d.set_deferred("disabled", true)
	cp_pool.append(_col_polygon2d)

func getGlobalRotPolygon() -> float:
	return _polygon2d.global_rotation

func setPolygon(poly : PackedVector2Array) -> void:
	_polygon2d.set_polygon(poly)
	_col_polygon2d.set_polygon(poly)
	if poly:
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
	call_deferred("setPolygon", poly)
	#setPolygon(poly)
	
func get_shape_transform() -> Transform2D:
	return _col_polygon2d.global_transform
	
func append_strike(strike: StrikeInfo):
	var half_area = PolygonLib.getPolygonArea(_polygon2d.polygon) / 2
	var cut_fracture_info: Dictionary = polyFracture.cutFracture(_polygon2d.polygon, strike.poly, self.global_transform,  strike.transform, half_area, 0, 0, 0)
	#leave maximal of shapes
	var max_area: float = 0
	var leave_shape_index = 0
	if len(cut_fracture_info.shapes) > 1:
		for i in len(cut_fracture_info.shapes):
			var area = PolygonLib.getPolygonArea(cut_fracture_info.shapes[i].shape)
			if area > max_area:
				leave_shape_index = i
				max_area = area
	if cut_fracture_info.shapes:
		var area = PolygonLib.getPolygonArea(cut_fracture_info.shapes[leave_shape_index].shape)
		print("leave_area: ", area)
		set_polygon(cut_fracture_info.shapes[leave_shape_index].shape)
	else:
		set_polygon(PackedVector2Array([]))
	
	var total_area : float = PolygonLib.getPolygonArea(strike.poly)
	for fracture in cut_fracture_info.fractures:
		for fracture_shard in fracture:
			var area_p : float = fracture_shard.area / total_area
			var rand_lifetime : float = _rng.randf_range(.1, 1) #+ 2.0 * area_p
			spawnFractureBody(fracture_shard, self.getTextureInfo(), 100, rand_lifetime)
			
	if not cut_fracture_info.shapes:
		disable_level(active_destruction_level)
		active_destruction_level += 1
		if len(destruction_levels) > active_destruction_level:
			call_deferred("enable_level", active_destruction_level)
	
func spawnFractureBody(fracture_shard : Dictionary, texture_info : Dictionary, new_mass : float, life_time : float) -> void:
	var instance: FractureShard = _fracture_shards.getInstance()
	if not instance:
		return
	
	var dir : Vector2 = (fracture_shard.spawn_pos - fracture_shard.source_global_trans.get_origin()).normalized()
	instance.spawn(fracture_shard.spawn_pos, fracture_shard.spawn_rot, fracture_shard.source_global_trans.get_scale(), life_time)
	instance.setPolygon(fracture_shard.centered_shape, Color(1,1,1,.7), PolygonLib.setTextureOffset(texture_info, fracture_shard.centroid))
	instance.setMass(new_mass)

func _on_mouse_entered() -> void:
	outline_available = true

func _on_mouse_shape_entered(shape_idx: int) -> void:
	if outline_available:
		var owner_id: int = self.shape_find_owner(shape_idx)
		var shape: CollisionPolygon2D = self.shape_owner_get_owner(owner_id)
		outline_line.points = shape.polygon
		outline_line.visible = true
		outline_timer.start()
		outline_available = false
	
func _on_outline_timer():
	outline_line.visible = false
	
func _process(delta: float) -> void:
	outline_line.modulate.a = outline_timer.time_left
	
	
	
