extends FlyingObject

signal parent_found(area: Area2D)
signal parent_lost()

var forward_force: Vector2 = Vector2.ZERO
var backward_force: Vector2 = Vector2.ZERO
var up_force: Vector2 = Vector2.ZERO
var areas: Array[Area2D] = []
var gravity_area: GravityArea = null

func _ready() -> void:
	super._ready()
	
func angle_to_angle(from, to):
	return fposmod(to-from + PI, PI*2) - PI

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
		#do angle correction to gravity direction
	var dang = angle_to_angle(global_rotation, gravity_vector_rotation)
	if abs(dang) > 0.01: #11.4 deg lesser just use physics
		rotate(dang * delta)

	var gravity_force = Vector2.ZERO
	if gravity_area:
		gravity_force = Vector2.DOWN.rotated(dang) * gravity_area.gravity_power
	var force: Vector2 = forward_force + backward_force + up_force + gravity_force
	velocity = force.rotated(global_rotation) * delta * 10        
	move_and_slide()
	
func _on_area_sendor_area_entered(area: Area2D) -> void:
	areas.append(area)
	if area is GravityArea:
		parent_found.emit(area)
		gravity_area = area

func _on_area_sendor_area_exited(area: Area2D) -> void:
	areas.erase(area)
	if area is GravityArea:
		parent_lost.emit()
		gravity_area = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("forward"):
		#physics_material_override.friction = 0.3
		forward_force = Vector2.RIGHT * 200
	if event.is_action_released("forward"):
		#physics_material_override.friction = 1000
		forward_force = Vector2.ZERO
	
	if event.is_action_pressed("backward"):
		#physics_material_override.friction = 0.3
		backward_force = Vector2.LEFT * 200
	if event.is_action_released("backward"):
		#physics_material_override.friction = 1000
		backward_force = Vector2.ZERO
		
	if event.is_action_pressed("force"):
		up_force = Vector2.UP * 200
	if event.is_action_released("force"):
		up_force = Vector2.ZERO


func _on_tree_entered() -> void:
	print(get_parent().name)
	pass # Replace with function body.
