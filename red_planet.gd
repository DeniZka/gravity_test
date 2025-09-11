extends AnimatableBody2D

func _ready() -> void:
	$GravityArea.set_master(self)
	$OwnerArea.set_master(self)
