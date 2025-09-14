extends Node2D

@onready var player: CharacterBody2D = $CharacterBody2D

@onready var rigidbody_template = preload("res://RigidBody2D.tscn")
@onready var polyFracture := PolygonFracture.new()
@onready var _rng := RandomNumberGenerator.new()
@onready var _pool_fracture_shards := $Pool_FractureShards
@onready var _pool_cut_visualizer := $Pool_CutVisualizer
@onready var _pool_point_fracture_ball := $Pool_PointFractureBall
@onready var _source_polygon_parent := $SourceParent
@onready var planet := $RedPlanet

func _ready() -> void:
	$AnimationPlayer.play("plank")
	$AnimationPlayer2.play("planet")


func _on_character_body_2d_parent_found(area: Area2D) -> void:
	if area is OwnerArea:
		var planet = area.get_master()
		player.reparent(planet)


func _on_character_body_2d_parent_lost() -> void:
	player.reparent(self)
	
func test():
	print("HELLO WORLD")
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		var ct: Transform2D = $Cutout.transform
		ct = ct.scaled(Vector2.ONE * (1/1.7))
		var cut_fracture_info: Dictionary = polyFracture.cutFracture(planet.get_polygon(), $Cutout.polygon, planet.global_transform,  $Cutout.transform, 0, 0, 0, 0)
		planet.set_polygon(cut_fracture_info.shapes[0].shape)
		#var body: RigidShape = rigidbody_template.instantiate()
		var total_area : float = PolygonLib.getPolygonArea($Cutout.polygon)
		for fracture in cut_fracture_info.fractures:
			for fracture_shard in fracture:
				
				var area_p : float = fracture_shard.area / total_area
				var rand_lifetime : float = _rng.randf_range(.1, 1) #+ 2.0 * area_p
				spawnFractureBody(fracture_shard, planet.getTextureInfo(), 100, rand_lifetime)
				
			
		#body.set_polygon(dict.fractures[0])
		#print(dict)
		call_deferred("test")
	
func cutSourcePolygons(source, cut_pos : Vector2, cut_shape : PackedVector2Array, cut_rot : float, cut_force : float = 0.0, fade_speed : float = 2.0) -> void:
	var source_polygon : PackedVector2Array = source.get_polygon()
	var total_area : float = PolygonLib.getPolygonArea(source_polygon)
	
	var source_trans : Transform2D = source.get_global_transform()
	var cut_trans := Transform2D(cut_rot, cut_pos)
	
	var s_lin_vel := Vector2.ZERO
	var s_ang_vel : float = 0.0
	var s_mass : float = 0.0
	
	if source is RigidBody2D:
		s_lin_vel = source.linear_velocity
		s_ang_vel = source.angular_velocity
		s_mass = source.mass
	
	
	var cut_fracture_info : Dictionary = polyFracture.cutFracture(source_polygon, cut_shape, source_trans, cut_trans, 2500, 1500, 100, 1)
	
	if cut_fracture_info.shapes.size() <= 0 and cut_fracture_info.fractures.size() <= 0:
		return
	
	for fracture in cut_fracture_info.fractures:
		for fracture_shard in fracture:
			var area_p : float = fracture_shard.area / total_area
			var rand_lifetime : float = _rng.randf_range(1.0, 3.0) + 2.0 * area_p
			#spawnFractureBody(fracture_shard, source.getTextureInfo(), s_mass * area_p, rand_lifetime)
	
	
	for shape in cut_fracture_info.shapes:
		var area_p : float = shape.area / total_area
		var mass : float = s_mass * area_p
		var dir : Vector2 = (shape.spawn_pos - cut_pos).normalized()
		
		call_deferred("spawnRigibody2d", shape, source.modulate, s_lin_vel + (dir * cut_force) / mass, s_ang_vel, mass, cut_pos, source.getTextureInfo())
		
	source.queue_free()


#func fractureCollision(pos : Vector2, other_body, fracture_ball) -> void:
	#if _fracture_disabled: return
	#
	#var p : float = fracture_ball.launch_velocity / FLICK_MAX_VELOCITY
	#var cut_shape : PackedVector2Array = polyFracture.generateRandomPolygon(Vector2(25, 200) * p, Vector2(18,72), Vector2.ZERO)
	#cutSourcePolygons(other_body, pos, cut_shape, 0.0, _rng.randf_range(400.0, 800.0), 2.0)
	#
	#_fracture_disabled = true
	#set_deferred("_fracture_disabled", false)
#
#func spawnRigibody2d(shape_info : Dictionary, color : Color, lin_vel : Vector2, ang_vel : float, mass : float, cut_pos : Vector2, texture_info : Dictionary) -> void:
	#var instance = rigidbody_template.instantiate()
	#_source_polygon_parent.add_child(instance)
	#instance.global_position = shape_info.spawn_pos
	#instance.global_rotation = shape_info.spawn_rot
	#instance.set_polygon(shape_info.centered_shape)
	#instance.modulate = color
	#instance.linear_velocity = lin_vel
	#instance.angular_velocity = ang_vel
	#instance.mass = mass
	#instance.setTexture(PolygonLib.setTextureOffset(texture_info, shape_info.centroid))


func spawnFractureBody(fracture_shard : Dictionary, texture_info : Dictionary, new_mass : float, life_time : float) -> void:
	var instance: FractureShard = _pool_fracture_shards.getInstance()
	if not instance:
		return
	
	var dir : Vector2 = (fracture_shard.spawn_pos - fracture_shard.source_global_trans.get_origin()).normalized()
	instance.spawn(fracture_shard.spawn_pos, fracture_shard.spawn_rot, fracture_shard.source_global_trans.get_scale(), life_time)
	instance.setPolygon(fracture_shard.centered_shape, Color(1,1,1,.7), PolygonLib.setTextureOffset(texture_info, fracture_shard.centroid))
	instance.setMass(new_mass)
