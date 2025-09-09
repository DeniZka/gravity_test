extends FlyingObject

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


var stay_same_state_times = 0
@onready var gravity_vector_rotation = 0

var last_collider: CollisionObject2D = null
var actual_collider: CollisionObject2D = null

var last_time_collided: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	pre_position = global_position
	pre_picker_outer = global_position #set picker outer point to self position

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var node: RayCast2D = get_node("../RayCast2D")
	if node:
		node.position = global_position                         
		node.target_position = delta_planet_point_move * 1000 #v * 1000
	super._integrate_forces(state)
		
	   	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#print("BEFORE: ", global_position, " ", get_picker_global())
	apply_central_force(forward_force + backward_force + up_force + Vector2.DOWN.rotated(gravity_vector_rotation) * gravity_force)
	#pre_picker_outer = get_picker_global() #buffer picker outer point before phisics

	#do angle correction to gravity direction
	var dang = angle_to_angle(rotation, gravity_vector_rotation)
	if abs(dang) > 0.01: #11.4 deg lesser just use physics
		angular_velocity = dang
		

	last_collider = actual_collider
	if caster.is_colliding():
		#сброс промахов
		shape_cast_not_foun_times = 0
		if not last_time_collided:
			shape_cast_step = 1.0
		#
		var coll_cnt = $ShapeCast2D.get_collision_count()
		
		#swap planet via picker
		actual_collider = $ShapeCast2D.get_collider(0)
		if last_collider != actual_collider:
			print("Swapt collider")
			var global_outer = get_picker_global()
			picker.reparent(actual_collider, false)
			set_picker_global(global_outer)
			last_collider = null
			
		var surface_normal = caster.get_collision_normal(0)
		var dangle = (surface_normal * -1.0).angle()
		gravity_vector_rotation = -PI/2 + dangle
		
		#if was not collision before
		shape_cast_found_times += 1
		if shape_cast_found_times >= MAX_SHAPE_CAST_MISS_TIME:			
			shape_cast_step += shape_cast_step
			shape_cast_found_times = 0
		shape_cast_increment = -shape_cast_step
		
		last_time_collided = true
	else:
		#reset found times
		shape_cast_found_times = 0
		if last_time_collided:
			stay_same_state_times = 0
			shape_cast_step = 1.0
			
		shape_cast_not_foun_times += 1
		if shape_cast_not_foun_times >= MAX_SHAPE_CAST_MISS_TIME:
			shape_cast_step += shape_cast_step
			stay_same_state_times = 0
			shape_cast_not_foun_times = 0
		shape_cast_increment = shape_cast_step
		last_time_collided = false
		
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
	
	
