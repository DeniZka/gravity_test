extends Resource
class_name PlaneAreaSetup

const GRAVITY_CENTRAL = "central"
const GRAVITY_DIRECTIONAL = "direct"

@export var parentize_ship: bool = false
var master: Planet = null
@export_category("Gravity")
@export var gravity: bool = false
@export_enum("central", "direct") var gravity_type: String = "central"
@export var gravity_rotation: float = 0
@export var gravity_str: float = 100

func set_master(m: Planet):
	self.master = m
	print(self.master)

func get_master() -> Planet:
	return self.master 
