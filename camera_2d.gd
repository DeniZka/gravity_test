extends Camera2D

var lock: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		zoom += zoom / 10
	if event.is_action_pressed("back_force"):
		zoom -= zoom / 10
