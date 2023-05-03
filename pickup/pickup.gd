extends Node3D

@export_enum("health", "ammo") var pickup_type = "ammo"
@onready var root = %Root
@onready var area_3d = %Area3D

signal picked

var visuals = {
	"ammo": preload("./ammo_pickup.tscn"),
	"health": preload("./health_pickup.tscn")
}

func _ready():
	var visual = visuals[pickup_type].instantiate()
	root.add_child(visual)
	var t = create_tween().set_loops(0)
	t.tween_property(root, "rotation_degrees:y", 360.0, 8.0).from(0.0)
	area_3d.connect("body_entered", _on_area_body_entered)
	
	
func _on_area_body_entered(body : Node3D):
	if !body.is_in_group("player"): return
	picked.emit()
