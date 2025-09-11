extends Area2D
class_name OwnerArea


var master: PhysicsBody2D = null

func set_master(node: PhysicsBody2D):
	master = node
	
func get_master() -> PhysicsBody2D:
	return self.master
