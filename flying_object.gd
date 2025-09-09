class_name FlyingObject
extends RigidBody2D

const CENTRAL = 0
const OUTER = 1

var pre_position
var pre_picker_outer
var picker: Line2D = null
var caster: ShapeCast2D = null
var delta_planet_point_move: Vector2 = Vector2.ZERO
var shape_cast_increment: float = 1.0

var last_collider: CollisionObject2D = null
var actual_collider: CollisionObject2D = null

const MAX_SHAPE_CAST_MISS_TIME = 2
var was_collided: bool = false
var stay_same_state_times = 0
var shape_cast_step: float = 1.0

func _ready() -> void:
	#line picker
	picker = Line2D.new()
	add_child(picker)
	picker.width = 1
	var pva: PackedVector2Array = PackedVector2Array(
		[Vector2.ZERO, to_local(global_position)])
	picker.points = pva
	picker.visible = false
	
	#shape caster
	caster = ShapeCast2D.new()
	add_child(caster)
	caster.target_position = Vector2.ZERO
	caster.shape = CircleShape2D.new()
	caster.shape.radius = 5
	caster.modulate = Color(1.0, 1.0, 1.0, 0.141)
	
func get_picker_global() -> Vector2:
	return picker.to_global(picker.points[OUTER])
	
func set_picker_global(point: Vector2):
	picker.points[OUTER] = picker.to_local(point)
	
func size_shape_cast():
	(caster.shape as CircleShape2D).radius += shape_cast_increment
	
func angle_to_angle(from, to):
	return fposmod(to-from + PI, PI*2) - PI

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#print("AFTER: ", global_position, pre_position, get_picker_global())
	var delta_move = global_position - pre_position
	delta_planet_point_move = get_picker_global() - pre_picker_outer
	print(delta_planet_point_move)
	#var v = delta_move - delta_planet_point_move
	#print(v)

	#if on fly little compensation
	if get_contact_count() == 0:
		global_position += delta_planet_point_move
	
	set_picker_global(global_position)
	pre_position = global_position
	pre_picker_outer = global_position #must be there (not in physiscs_process due to bug)
	
func _physics_process(delta: float) -> void:
	#swap planet
	last_collider = actual_collider
	if caster.is_colliding():
		actual_collider = caster.get_collider(0)
		if last_collider != actual_collider:
			var global_outer = get_picker_global()
			picker.reparent(actual_collider, false)
			set_picker_global(global_outer)
			last_collider = null
			
	#seadd rching gravity point
	if caster.is_colliding():
		#сброс промахов
		if not was_collided:
			was_collided = true
			stay_same_state_times = 0
			shape_cast_step = -1.0
	else:
		#reset found times
		if was_collided:
			was_collided = false
			stay_same_state_times = 0
			shape_cast_step = 1.0
			
	if stay_same_state_times >= MAX_SHAPE_CAST_MISS_TIME:
		shape_cast_step = shape_cast_step * 2.0
		stay_same_state_times = 0
	(caster.shape as CircleShape2D).radius += shape_cast_step
	stay_same_state_times += 1
