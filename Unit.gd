extends FlyingObject

var ray: SeparationRayShape2D
#input forces
var forward_force: Vector2 = Vector2.ZERO
var backward_force: Vector2 = Vector2.ZERO
var up_force: Vector2 = Vector2.ZERO
var gravity_force = 90

@onready var gravity_vector_rotation = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()


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
		
	if caster.is_colliding():
		var surface_normal = caster.get_collision_normal(0)
		var dangle = (surface_normal * -1.0).angle()
		gravity_vector_rotation = -PI/2 + dangle
		
	super._physics_process(delta)
		
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("forward"):
		physics_material_override.friction = 0.3
		forward_force = Vector2.RIGHT.rotated(gravity_vector_rotation) * 50
	if event.is_action_released("forward"):
		physics_material_override.friction = 1000
		forward_force = Vector2.ZERO
	
	if event.is_action_pressed("backward"):
		physics_material_override.friction = 0.3
		backward_force = Vector2.LEFT.rotated(gravity_vector_rotation) * 50
	if event.is_action_released("backward"):
		physics_material_override.friction = 1000
		backward_force = Vector2.ZERO
		
	if event.is_action_pressed("force"):
		up_force = Vector2.UP.rotated(gravity_vector_rotation) * 200
	if event.is_action_released("force"):
		up_force = Vector2.ZERO
	
	
