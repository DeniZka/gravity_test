extends FlyingObject
class_name Ship

const  ACCELERATION_DUMPING = 0.99
const ROTATION_BASED = false
const GRAVITY_BASED = true

const WEAPON_BLASTER = 0
const WEAPON_ROCKET_LOUNCHER = 1
const WEAPON_LASER = 3

var rocket_count = 10

signal spawn_projectile(pos: Vector2, angle: float, vel: float)
signal start_hitscan()


var forward_force: Vector2 = Vector2.ZERO
var backward_force: Vector2 = Vector2.ZERO
var up_force: Vector2 = Vector2.ZERO
var acceleration_force: Vector2 = Vector2.ZERO
var back_force: Vector2 = Vector2.ZERO
var rot_force: float = 0
var rot_vel: float = 0
var areas: Array[Area2D] = []
var gravity_areas: Dictionary = {}
var behaivor = GRAVITY_BASED
var sel_weapon: int = WEAPON_BLASTER

var origin_parent: Node = null

var lock_exit: bool = false #lock exit while reparent

func _ready() -> void:
	super._ready()
	$Magnet/CollisionShape2D.disabled = true
	
func angle_to_angle(from, to):
	return fposmod(to-from + PI, PI*2) - PI

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if get_parent() is Planet:
		up_direction = (global_position - get_parent().global_position).normalized()
	else:
		up_direction = Vector2.UP.rotated(rotation)
		#do angle correction to gravity direction
	var gravity_force = Vector2.ZERO
	var dang: float = 0.0
	if behaivor == GRAVITY_BASED:
		dang = angle_to_angle(global_rotation, up_direction.angle() + PI/2.0)
	else:
		dang = angle_to_angle(global_rotation, gravity_vector_rotation)
	#print(dang, " ", global_rotation, " ", gravity_vector_rotation, " ", global_rotation + dang)
	if owner_area: #landing mode pritority
		if abs(dang) > 0.01: #11.4 deg lesser just use physics
			rotate(dang * delta)
		var ga_keys: Array = gravity_areas.keys()
		if len(ga_keys) > 0:
			if not is_on_wall():
				if behaivor == GRAVITY_BASED:
					gravity_force = up_direction.rotated(PI) * ga_keys[0].setup.gravity_str
				else:
					gravity_force = Vector2.DOWN.rotated(gravity_vector_rotation) * ga_keys[0].setup.gravity_str  
			#print("own:", gravity_force)ataaa
	elif gravity_areas: #fly with gravity mix mplanet gravity
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
			gravity_force += vec_to_gravity_shape.normalized() * (garea as PlanetArea).setup.gravity_str
			#print("gF:", gravity_force)
			#TODO: calc gravities  (garea as GravityArea).getch

	#FIXME: fix
	
	
	#print(get_parent().name, " ud:", up_direction)
	var force: Vector2 = (forward_force + backward_force + up_force + back_force + acceleration_force)
	#print(force)
	var body_dump: float = 2.0
	if is_on_wall():
		body_dump = 10.0
	
	var combined_dump = ProjectSettings.get_setting("physics/2d/default_linear_damp") + body_dump
	var pps = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
	#print("force", gravity_force)
	if behaivor == GRAVITY_BASED:
		velocity += (force.rotated(up_direction.angle() + PI/2) + gravity_force) * delta 
	else:
		velocity += (force.rotated(global_rotation) + gravity_force) * delta
	#dump
	velocity *= (1.0 - combined_dump / pps)
	
	## rotation calculation
	rot_vel += rot_force * delta
	var body_angular_damp = 2.0
	var combined_angular_damp = ProjectSettings.get_setting("physics/2d/default_angular_damp") + body_angular_damp
	rot_vel *= (1.0 - combined_angular_damp / pps)
	rotate(rot_vel * delta)
	
	#print("velo: ", velocity)
	move_and_slide()
	#print("velo2: ", velocity)
	
func _on_area_sendor_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area is PlanetArea and area.setup.gravity:
		var owner_id: int = area.shape_find_owner(area_shape_index)
		var shape_owner: CollisionShape2D = area.shape_owner_get_owner(owner_id)
		if not shape_owner in gravity_areas[area]: 
			gravity_areas[area].append(shape_owner)

func _on_area_sendor_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if lock_exit:
		return
	if area is PlanetArea and area.setup.gravity and area in gravity_areas:
		var owner_id: int = (area as GravityArea).shape_find_owner(area_shape_index)
		var shape_owner: CollisionShape2D = (area as GravityArea).shape_owner_get_owner(owner_id)
		gravity_areas[area].erase(shape_owner)
	
func reparent_push_deffer(master: Node2D):
	origin_parent = get_parent()
	lock_exit = true
	reparent(master)
	print("reparent ", master)
	
func reparent_pop_deffer():
	lock_exit = true 
	reparent(origin_parent)
	origin_parent = null
	
	
func _on_area_sendor_area_entered(area: Area2D) -> void:
	if area in areas:
		lock_exit = false #unlock enter same area
		return
	else:
		areas.append(area)
		
	print("enter area: ", area.name)
	if area is PlanetArea:
		var setup = area.setup
		if setup.parentize_ship:
			owner_area = area
			motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
			call_deferred("reparent_push_deffer", setup.master)
		if setup.gravity:
			gravity_areas[area] = []

func _on_area_sendor_area_exited(area: Area2D) -> void:
	if lock_exit:
		return
	areas.erase(area)
	print("exit area: ", area.name)

	if area is PlanetArea:
		if area == owner_area:
			motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
			call_deferred("reparent_pop_deffer")
			owner_area = null
		if area in gravity_areas:
			gravity_areas.erase(area)

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		behaivor = ROTATION_BASED
	else:
		behaivor = GRAVITY_BASED
		
	if event.is_action_pressed("weapon_1"):
		sel_weapon = WEAPON_LASER
	if event.is_action_pressed("weapon_2"):
		sel_weapon = WEAPON_BLASTER
	if event.is_action_pressed("weapon_3"):
		sel_weapon = WEAPON_ROCKET_LOUNCHER
		
	if event.is_action_pressed("magnet"):
		$Magnet/CollisionShape2D.disabled = false
	if event.is_action_released("magnet"):
		$Magnet/CollisionShape2D.disabled = true
		
	if event.is_action_pressed("shoot"):
		var dir = (get_global_mouse_position() - global_position).normalized()
		spawn_projectile.emit(global_position + dir * 30, dir.angle(), velocity.length())

		
	if event.is_action_pressed("up"):
		up_force = Vector2.UP * 400
	if event.is_action_released("up"):
		up_force = Vector2.ZERO
		
	if event.is_action_pressed("right"):
		#physics_material_override.friction = 0.3
		#if owner_area:
		forward_force = Vector2.RIGHT * 400
	if event.is_action_released("right"):
		#physics_material_override.friction = 1000
		#if owner_area:
		forward_force = Vector2.ZERO
	
	if event.is_action_pressed("left"):
		#physics_material_override.friction = 0.3
		#if owner_area:
		backward_force = Vector2.LEFT * 400
	if event.is_action_released("left"):
		#physics_material_override.friction = 1000
		#if owner_area:
		backward_force = Vector2.ZERO
		
	if event.is_action_pressed("force"):
		acceleration_force = Vector2.UP * 1200
	if event.is_action_released("force"):
		acceleration_force = Vector2.ZERO
	if event.is_action_pressed("back_force"):
		back_force = Vector2.DOWN * 400
	if event.is_action_released("back_force"):
		back_force = Vector2.ZERO
	if event.is_action_pressed("rotate_ccw"):
		rot_force = -10
	if event.is_action_released("rotate_ccw"):
		rot_force = 0
	if event.is_action_pressed("rotate_cw"):
		rot_force = 10
	if event.is_action_released("rotate_cw"):
		rot_force = 0
		


func _on_tree_entered() -> void:
	print("Parent: ", get_parent().name)
	pass # Replace with function body.


func _on_dock_body_entered(body: Node2D) -> void:
	if body is Rocket:
		body.queue_free()
