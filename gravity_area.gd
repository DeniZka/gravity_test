extends Area2D
class_name  GravityArea


@export var gravity_power: float = 100
var master: PhysicsBody2D = null

func set_master(node: PhysicsBody2D):
	master = node
	
func get_master() -> PhysicsBody2D:
	return self.master
