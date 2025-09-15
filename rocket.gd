extends RigidBody2D
class_name Rocket

signal Despawn(ref)
signal boom(strike: StrikeInfo)

var angle: float = 0
var vdir: Vector2 = Vector2.ZERO
@onready var ray: RayCast2D = $Rocket/RayCast2D

func spawn(pos : Vector2, rot : float, force: float) -> void:
	visible = true
	global_position = pos
	global_rotation = rot
	self.vdir = Vector2.RIGHT.rotated(rot) * force
	
	set_process(true)
	set_physics_process(true)


func despawn() -> void:
	visible = false
	set_process(false)
	set_physics_process(false)
	
func _process(delta: float) -> void:
	$Rocket.rotation = angle
	
func _physics_process(delta: float) -> void:
	apply_central_force(self.vdir)
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider is Planet:
			var pf = PolygonFracture.new()
			var strike = StrikeInfo.new()
			strike.poly = pf.generateRandomPolygon( Vector2.ONE * 50, Vector2.ONE *3, global_position)
			strike.transform = Transform2D(0, global_position)
			collider.append_strike(strike)
			emit_signal("boom", strike)
			queue_free()
			emit_signal("Despawn")
