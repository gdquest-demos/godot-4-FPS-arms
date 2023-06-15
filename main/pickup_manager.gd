extends Node

@onready var weapon_data = preload("res://resources/laser_gun_data.tres")

func _ready():
	var pickups = get_tree().get_nodes_in_group("pickup")
	for pickup in pickups:
		pickup.connect("picked", on_picked.bind(pickup.pickup_type))
	
func on_picked(type : String):
	match type:
		"ammo":
			weapon_data.restore()
