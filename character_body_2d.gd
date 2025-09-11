extends FlyingObject

const  ACCELERATION_DUMPING = 0.99

signal parent_found(area: Area2D)
signal parent_lost()

var forward_force: Vector2 = Vector2.ZERO
var backward_force: Vector2 = Vector2.ZERO
var up_force: Vector2 = Vector2.ZERO
var back_force: Vector2 = Vector2.ZERO
var areas: Array[Area2D] = []
var gravity_areas: Dictionary = {}

func _ready() -> void:
	super._ready()
	
func angle_to_angle(from, to):
	return fposmod(to-from + PI, PI*2) - PI

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
		#do angle correction to gravity direction
	var gravity_force = Vector2.ZERO
	var dang = angle_to_angle(global_rotation, gravity_vector_rotation)
	if owner_area: #landing mode pritority
		if abs(dang) > 0.01: #11.4 deg lesser just use physics
			rotate(dang * delta)
		var ga_keys: Array = gravity_areas.keys()
		if len(ga_keys) > 0:
			gravity_force = Vector2.DOWN.rotated(dang) * ga_keys[0].gravity_power
	elif gravity_areas: #fly with gravity
		for garea in gravity_areas:
			var nearest_q_len: float = INF
			var nearest_shape: CollisionShape2D = gravity_areas[garea][0]
			#select nearest shape
			if len(gravity_areas[garea]) > 1:
				for coll_shape in gravity_areas[garea]:
					var sq_dist: float = global_position.distance_squared_to(coll_shape.global_position)
					if sq_dist < nearest_q_len:
						nearest_q_len = sq_dist
						nearest_shape = coll_shape
			var vec_to_gravity_shape: Vector2 = nearest_shape.global_position - global_position
			gravity_force += vec_to_gravity_shape.normalized() * (garea as GravityArea).gravity_power
			#TODO: calc gravities  (garea as GravityArea).getch

	#FIXME: fix
	var force: Vector2 = forward_force + backward_force + up_force + back_force + gravity_force      
	#print(force)
	velocity = force.rotated(global_rotation) * delta
	move_and_slide()
	
func _on_area_sendor_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area is GravityArea:
		var owner_id: int = (area as GravityArea).shape_find_owner(area_shape_index)
		var shape_owner: CollisionShape2D = (area as GravityArea).shape_owner_get_owner(owner_id)
		gravity_areas[area].append(shape_owner)

func _on_area_sendor_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area is GravityArea and area in gravity_areas:
		var owner_id: int = (area as GravityArea).shape_find_owner(area_shape_index)
		var shape_owner: CollisionShape2D = (area as GravityArea).shape_owner_get_owner(owner_id)
		gravity_areas[area].erase(shape_owner)
	
func _on_area_sendor_area_entered(area: Area2D) -> void:
	areas.append(area)
	if area is OwnerArea:
		owner_area = area
		parent_found.emit(area)
	if area is GravityArea:
		gravity_areas[area] = []

func _on_area_sendor_area_exited(area: Area2D) -> void:
	areas.erase(area)
	if area is OwnerArea:
		owner_area = null
		parent_lost.emit()
	if area is GravityArea:
		gravity_areas.erase(area)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right"):
		#physics_material_override.friction = 0.3
		if owner_area:
			forward_force = Vector2.RIGHT * 20000
	if event.is_action_released("right"):
		#physics_material_override.friction = 1000
		#if owner_area:
		forward_force = Vector2.ZERO
	
	if event.is_action_pressed("left"):
		#physics_material_override.friction = 0.3
		if owner_area:
			backward_force = Vector2.LEFT * 20000
	if event.is_action_released("left"):
		#physics_material_override.friction = 1000
		#if owner_area:
		backward_force = Vector2.ZERO
		
	if event.is_action_pressed("force"):
		up_force = Vector2.UP * 20000
	if event.is_action_released("force"):
		up_force = Vector2.ZERO
	if event.is_action_pressed("back_force"):
		back_force = Vector2.DOWN * 15000
	if event.is_action_released("back_force"):
		back_force = Vector2.ZERO
		


func _on_tree_entered() -> void:
	print(get_parent().name)
	pass # Replace with function body.
