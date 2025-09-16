extends Node2D

func _on_pnum_value_changed(value: float) -> void:
	var poly = PolygonLib.createSupershape2DPolygon(
		$CanvasLayer/Panel/HBoxContainer/pnum.value,
		$CanvasLayer/Panel/HBoxContainer/a.value,
		$CanvasLayer/Panel/HBoxContainer/b.value,
		$CanvasLayer/Panel/HBoxContainer/m.value,
		$CanvasLayer/Panel/HBoxContainer/n1.value,
		$CanvasLayer/Panel/HBoxContainer/n2.value, 
		$CanvasLayer/Panel/HBoxContainer/n3.value,
		)
	$Shape/Line2D.points = poly
	$Shape.polygon = poly
	queue_redraw()


func _on_panel_mouse_entered() -> void:
	$Shape/Camera2D.lock = true


func _on_panel_mouse_exited() -> void:
	$Shape/Camera2D.lock = false
