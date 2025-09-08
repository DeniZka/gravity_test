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

const MAX_SHAPE_CAST_MISS_TIME = 2
var shape_cast_found_times = 0
var shape_cast_not_foun_times = 0 #количество раз когда каст промахнулся
var shape_cast_step: float = 1.0
var shape_cast_increment: float = 1.0
@onready var shape_cast: ShapeCast2D = $ShapeCast2D
@onready var gravity_vector_rotation = 0

@onready var picker: Line2D = $Picker
var last_collider: RigidBody2D = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func add_rays_length():
	for child in $Area2D.get_children():
		ray = (child as CollisionShape2D).shape
		ray.length += ray_increment

func _process(delta: float) -> void:
	add_rays_length()
	
func size_shape_cast():
	(shape_cast.shape as CircleShape2D).radius += shape_cast_increment
	
func angle_to_angle(from, to):
	return fposmod(to-from + PI, PI*2) - PI
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	apply_central_force(forward_force + backward_force + up_force + Vector2.DOWN.rotated(gravity_vector_rotation) * gravity_force)
	#angle correction
	var dang = angle_to_angle(rotation, gravity_vector_rotation)
	if abs(dang) > 0.2: #11.4 deg lesser just use physics
		angular_velocity = dang

	
	if shape_cast.is_colliding():
		#сброс промахов
		shape_cast_not_foun_times = 0
		#
		var coll_cnt = $ShapeCast2D.get_collision_count()
		
		var collider = $ShapeCast2D.get_collider(0)

		if last_collider == collider:
			#TODO:
			collider
		else:
			picker.points[1] = Vector2(10.0)
			picker.reparent(self)
			last_collider = null
		last_collider = collider
			
			
			
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
		up_force = Vector2.UP.rotated(gravity_vector_rotation) * 50
	if event.is_action_released("force"):
		up_force = Vector2.ZERO
	
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	first_encounter = true
	print(body)
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	#ray_increment = 1
	#if ray_pair.size() == 1:
		#var a = ray_pair.pop_front()
		#if a == 0:
			#angular_velocity = 0
		#if a == 1:
			#angular_velocity = .5
		#if a == 7:
			#angular_velocity = -.5
	#if ray_pair.size() == 2:
		#var a = ray_pair.pop_front()
		#var b = ray_pair.pop_front()
		#if a == 1 or b == 1:
			#angular_velocity = .5
		#if a == 7 or b == 7:
			#angular_velocity = -.5
			##rotation_degrees += 2
			##print(rotation_degrees)
		#
	#ray_pair.clear()
	pass # Replace with function body.


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	#print(local_shape_index, " - ", body_shape_index)
	ray_increment = -1
	#ray_pair.push_back(($Area2D.get_child(local_shape_index) as CollisionShape2D).rotation_degrees)
	ray_pair.push_back(local_shape_index)
	#if first_encounter:
		#first_encounter = false
		#if local_shape_index == 1:
			#print("rotate")
			#rotation_degrees += 22.5
	#pass # Replace with function body.


func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	pass # Replace with function body.
