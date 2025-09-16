extends RigidBody2D
class_name Rocket

signal Despawn(ref)

const MODE_PROJECTILE = "Projectile"
const MODE_ITEM = "Item"

@onready var ray: RayCast2D = $Rocket/RayCast2D
@onready var _timer: Timer = $Timer
@export_enum("Projectile", "Item") var mode: String = MODE_PROJECTILE:
	set(val):
		mode = val
		if val == MODE_PROJECTILE:
			collision_layer = 1
			collision_mask = 1
			linear_damp = 0.0
		else:
			collision_layer = 0
			collision_mask = 0
			linear_damp = 1.0
			set_collision_layer_value(5, true)
			set_collision_mask_value(4, true)
		
@export var strike: StrikeInfo = null

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	#var pl = PolygonLib.new()
	#pl.createSupershape2DPolygon(50, 150, 4, 1/6, 4, 2, 4)
	var pf = PolygonFracture.new(Time.get_ticks_usec())
	strike.poly = pf.generateRandomPolygon(strike.size, Vector2.ONE * 40)

func spawn(pos : Vector2, rot : float, initial_vel: float) -> void:
	visible = true
	global_position = pos
	global_rotation = rot
	linear_velocity = Vector2.RIGHT.rotated(rot) * initial_vel
	set_process(true)
	set_physics_process(true)
	collision_layer = 1
	collision_mask = 1
	_timer.start(3)


func despawn() -> void:
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	collision_layer = 0
	collision_mask = 0
	visible = false
	set_process(false)
	set_physics_process(false)
	_timer.stop()
	
	
func _physics_process(delta: float) -> void:
	apply_central_force(Vector2.RIGHT.rotated(global_rotation) * strike.force)

func _on_body_entered(body: Node) -> void:
	if body is Planet:
		strike.transform = Transform2D(0, global_position)
		body.append_strike(strike)
		Despawn.emit(self)


func _on_timer_timeout() -> void:
	Despawn.emit(self)
