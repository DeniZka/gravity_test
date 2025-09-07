extends RigidBody2D

var ground_found: bool = false
var ray_increment: int = 1
var first_encounter: bool = false
var ray: SeparationRayShape2D
var ray_pair: Array = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func add_rays_length():
	for child in $Area2D.get_children():
		ray = (child as CollisionShape2D).shape
		ray.length += ray_increment

func _process(delta: float) -> void:
	add_rays_length()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	apply_force( Vector2(0, 10).rotated(rotation) )
	$RayCast2D.add_exception()
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	first_encounter = true
	print(body)
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	ray_increment = 1
	if ray_pair.size() == 1:
		var a = ray_pair.pop_front()
		if a == 0:
			angular_velocity = 0
		if a == 1:
			angular_velocity = .5
		if a == 7:
			angular_velocity = -.5
	if ray_pair.size() == 2:
		var a = ray_pair.pop_front()
		var b = ray_pair.pop_front()
		if a == 1 or b == 1:
			angular_velocity = .5
		if a == 7 or b == 7:
			angular_velocity = -.5
			#rotation_degrees += 2
			#print(rotation_degrees)
		
	ray_pair.clear()
	pass # Replace with function body.


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	print(local_shape_index, " - ", body_shape_index)
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
