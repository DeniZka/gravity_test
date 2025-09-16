extends Area2D
class_name BlasterBullet

signal Despawn(ref)

@export var strike: StrikeInfo = null
@onready var _timer: Timer = $Timer
var linear_velocity: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	var pf = PolygonFracture.new(Time.get_ticks_usec())
	strike.poly = pf.generateRandomPolygon(strike.size, Vector2.ONE * 40)

func spawn(pos : Vector2, rot : float, initial_vel: float) ->  void:
	visible = true
	linear_velocity = Vector2.RIGHT.rotated(rot) * initial_vel
	global_position = pos
	global_rotation = rot
	set_process(true)
	set_physics_process(true)
	_timer.start()
	
func despawn() -> void:
	visible = false
	linear_velocity = Vector2.ZERO
	_timer.stop()
	set_process(false)
	set_physics_process(false)
	
func _physics_process(delta: float) -> void:
	var pos = Vector2.RIGHT.rotated(global_rotation) * strike.force * delta
	global_position += pos

func _on_timer_timeout() -> void:
	Despawn.emit(self)

func _on_body_entered(body: Node) -> void:
	if body is Planet:
		strike.transform = Transform2D(0, global_position)
		body.append_strike(strike)
		Despawn.emit(self)
