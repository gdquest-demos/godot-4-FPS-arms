extends Resource
class_name WeaponData

@export var weapon_name = ""
@export var max_ammo : int
var ammo : int 

signal reloaded
signal used

func _init():
	call_deferred("ready")

func ready():
	ammo = max_ammo
	
func has_ammo():
	return ammo > 0
	
func use():
	ammo = max(0, ammo - 1)
	used.emit()

func reload():
	if ammo == max_ammo: return
	ammo = max_ammo
	reloaded.emit()
	
