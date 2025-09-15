extends RigidBody2D
class_name Rocket

signal Despawn(ref)

var angle: float = 0
var vdir: Vector2 = Vector2.ZERO
@onready var ray: RayCast2D = $Rocket/RayCast2D
@onready var _timer: Timer = $Timer
var strike: StrikeInfo = null

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	var pf = PolygonFracture.new(Time.get_unix_time_from_system())
	strike = StrikeInfo.new()
	strike.poly = pf.generateRandomPolygon( Vector2(30, 30), Vector2.ONE *40)
	

func spawn(pos : Vector2, rot : float, force: float) -> void:
	visible = true
	global_position = pos
	global_rotation = rot
	self.vdir = Vector2.RIGHT.rotated(rot) * force
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
	
func _process(delta: float) -> void:
	$Rocket.rotation = angle
	
func _physics_process(delta: float) -> void:
	apply_central_force(self.vdir)

func _on_body_entered(body: Node) -> void:
	if body is Planet:
		strike.transform = Transform2D(0, global_position)
		body.append_strike(strike)
		Despawn.emit(self)


func _on_timer_timeout() -> void:
	Despawn.emit(self)
