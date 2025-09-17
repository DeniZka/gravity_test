extends Resource
class_name DestructionLevel

@export_node_path("Polygon2D") var poly: Array[NodePath]
@export_range(0, 100, 1, "percent of poly is shard") var percent = 50
var p: Polygon2D = null
var parent: Node2D = null
var initial_area: float = 0

func _init() -> void:
	resource_local_to_scene = true
	
func _setup_local_to_scene():
	parent = get_local_scene()
	p = parent.get_node(poly[0])
	initial_area = PolygonLib.getPolygonArea( p.polygon )
	
	#cp = parent.get_node(collision_poly)
	#cp.set_deferred("disabled", true)

func get_poly() -> PackedVector2Array:
	return []
	
