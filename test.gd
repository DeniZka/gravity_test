extends Node2D

@onready var sc: ShapeCast2D = $ShapeCast2D
@onready var line: Line2D = $Line2D

var selected: bool = false
var dsel: Vector2 = Vector2.ZERO
var src_pos: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if selected:
		$ShapeCast2D.position = src_pos + (get_local_mouse_position() - dsel)
	var cc = sc.get_collision_count()
	print(cc)
	if cc > 0:
		line.points[0] = sc.get_collision_point(0)
		line.points[1] = line.points[0] + sc.get_collision_normal(0) * 10


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("select"):
		dsel = get_local_mouse_position()
		selected = true
		src_pos = $ShapeCast2D.position
	if event.is_action_released("select"):
		selected = false
		

		
	pass # Replace with function body.
