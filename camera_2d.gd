extends Camera2D

var lock: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		zoom += zoom / 10
	if event.is_action_pressed("zoom_out"):
		zoom -= zoom / 10
