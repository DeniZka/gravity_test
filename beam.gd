extends Line2D
@onready var mat: ParticleProcessMaterial = $GPUParticles2D.process_material

func _ready() -> void:
	$GPUParticles2D.emitting = false

func _process(delta: float) -> void:
	pass
