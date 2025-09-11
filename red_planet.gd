extends AnimatableBody2D

func _ready() -> void:
	$Area2D.set_master(self)
