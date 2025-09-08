extends RigidBody2D

var ground_found: bool = false
var ray_increment: int = 1
var first_encounter: bool = false
var ray: SeparationRayShape2D
var ray_pair: Array = []
var forward_force: Vector2 = Vector2.ZERO
var backward_force: Vector2 = Vector2.ZERO
var up_force: Vector2 = Vector2.ZERO
var gravity_force = 40
var applied_force: Vector2 = Vector2(0,0)

const CENTRAL = 0
const OUTER = 1

const MAX_SHAPE_CAST_MISS_TIME = 2
var shape_cast_found_times = 0
var shape_cast_not_foun_times = 0 #количество раз когда каст промахнулся
var shape_cast_step: float = 1.0
var shape_cast_increment: float = 1.0
@onready var shape_cast: ShapeCast2D = $ShapeCast2D
@onready var gravity_vector_rotation = 0

@onready var picker: Line2D = $Picker
var last_collider: CollisionObject2D = null
var actual_collider: CollisionObject2D = null
var pre_position: Vector2 = Vector2.ZERO
var pre_picker_outer: Vector2 = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pre_position = global_position
	picker.points[OUTER] = to_local(global_position)
	pass # Replace with function body.


func size_shape_cast():
	(shape_cast.shape as CircleShape2D).radius += shape_cast_increment
	
func angle_to_angle(from, to):
	return fposmod(to-from + PI, PI*2) - PI
	
func get_picker_global() -> Vector2:
	return picker.to_global(picker.points[OUTER])
	
func set_picker_global(point: Vector2):
	picker.points[OUTER] = picker.to_local(point)
	
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#print("AFTER: ", global_position, get_picker_global())
	var delta_move = global_position - pre_position
	var delta_planet_point_move = get_picker_global() - pre_picker_outer
	#var v = delta_move - delta_planet_point_move
	$"../RayCast2D".position = global_position                         
	$"../RayCast2D".target_position = delta_planet_point_move * 1000 #v * 1000
	#print(v)
	#if on fly little compensation
	if get_contact_count() == 0                       :
		global_position += delta_planet_point_move
	#print(delta_move)
	#print(delta_planet_point_move)
	#global_position += v
	
	#after _physics process
	if actual_collider and actual_collider == last_collider:
		#TODO: skip if STATIC
		#print("Hello")
		var actual_picker_outer = get_picker_global()
		if actual_picker_outer != pre_picker_outer:
			var dv = actual_picker_outer - pre_picker_outer
			
			#global_position += dv
		#pre_picker_outer = actual_picker_outer
	else:
		#pre_picker_outer = global_position
		pass
		
	set_picker_global(global_position)
	pre_position = global_position
		
		
	#if shape_cast.is_colliding():
		#print("COLLIDING")
		#var collider = $ShapeCast2D.get_collider(0)
		#if collider and last_collider == collider:
			#var dv = picker.to_global(picker.points[OUTER]) - global_position
			#print(dv)
			#global_position += dv
		#
	#print("IF: ", picker.to_global(picker.points[OUTER]), " - ", global_position)
	   	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#print("BEFORE: ", global_position, " ", get_picker_global())
	apply_central_force(forward_force + backward_force + up_force + Vector2.DOWN.rotated(gravity_vector_rotation) * gravity_force)
	pre_picker_outer = get_picker_global()

	#angle correction
	var dang = angle_to_angle(rotation, gravity_vector_rotation)
	if abs(dang) > 0.01: #11.4 deg lesser just use physics
		angular_velocity = dang
		

	last_collider = actual_collider
	if shape_cast.is_colliding():
		#print("COLLIDING!!!")
		#сброс промахов
		shape_cast_not_foun_times = 0
		#
		var coll_cnt = $ShapeCast2D.get_collision_count()
		
		actual_collider = $ShapeCast2D.get_collider(0)

		if last_collider == actual_collider:
			#TODO:
			#print("PP: ", picker.to_global(picker.points[OUTER]), " - ", global_position)
			#picker.points[OUTER] = picker.to_local(global_position)
			pass
		else:
			#print("reparent")
			var global_outer = get_picker_global()
			picker.reparent(actual_collider, false)
			set_picker_global(global_outer)
			
			#picker.points[CENTRAL] = Vector2(10, 0)
			#picker.points[OUTER] = picker.to_local(global_position)
			last_collider = null
			
			
			
		if coll_cnt > 1:
			#TODO: узнать количество столкновений снизу им приоритет
			#остальные скип
			
			#если несколько коллизий снизу нужно снова уменьшить шаг интегрирования коллизионной сферы
			#shape_cast_increment = -shape_cast_step
			#shape_cast_step = shape_cast_step / 2.0
			pass
			
			
		
		
		var surface_normal = shape_cast.get_collision_normal(0)
		var dangle = (surface_normal * -1.0).angle()
		gravity_vector_rotation = -PI/2 + dangle
		
		#if was not collision before
		shape_cast_found_times += 1
		if shape_cast_found_times >= MAX_SHAPE_CAST_MISS_TIME:			
			shape_cast_step = shape_cast_step / 2.0
			if shape_cast_step < 1.0:
				shape_cast_step = 1.0
			shape_cast_found_times = 0
		shape_cast_increment = -shape_cast_step
	else:
		#reset found times
		shape_cast_found_times = 0
		shape_cast_not_foun_times += 1
		if shape_cast_not_foun_times >= MAX_SHAPE_CAST_MISS_TIME:
			shape_cast_step += shape_cast_step #resize x 2
			shape_cast_not_foun_times = 0
		shape_cast_increment = shape_cast_step
		
	size_shape_cast()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("forward"):
		physics_material_override.friction = 0.3
		forward_force = Vector2.RIGHT.rotated(gravity_vector_rotation) * 50
	if event.is_action_released("forward"):
		physics_material_override.friction = 1.0
		forward_force = Vector2.ZERO
	
	if event.is_action_pressed("backward"):
		physics_material_override.friction = 0.3
		backward_force = Vector2.LEFT.rotated(gravity_vector_rotation) * 50
	if event.is_action_released("backward"):
		physics_material_override.friction = 1.0
		backward_force = Vector2.ZERO
		
	if event.is_action_pressed("force"):
		up_force = Vector2.UP.rotated(gravity_vector_rotation) * 100
	if event.is_action_released("force"):
		up_force = Vector2.ZERO
	
	
