extends Sprite2D
class_name PlanetCore

@export var angle_speed: float = 0.1

func _process(delta: float) -> void:
	self.rotate(angle_speed * delta)
