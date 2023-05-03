extends MarginContainer

@onready var weapon_data = preload("res://resources/laser_gun_data.tres")
@onready var bullet_icon_scene = preload("./bullet_icon.tscn")
@onready var box = %Box

func _ready():
	for _i in weapon_data.max_ammo:
		var bullet_icon = bullet_icon_scene.instantiate()
		box.add_child(bullet_icon)
	weapon_data.connect("used", on_ammo_used)
	weapon_data.connect("reloaded", on_ammo_reloaded)

func on_ammo_used():
	var bullet_icon = box.get_child(weapon_data.ammo)
	bullet_icon.set_opacity(0.2, 0.1)

func on_ammo_reloaded():
	var bullet_icons = box.get_children()
	for bullet_icon_index in bullet_icons.size():
		var bullet_icon = bullet_icons[bullet_icon_index]
		bullet_icon.set_opacity(1.0, 0.1, bullet_icon_index * 0.05)
