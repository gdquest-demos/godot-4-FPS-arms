extends Node3D

@export var balloon_scene : PackedScene
@onready var spawn_timer = %SpawnTimer
@onready var holder = %Holder


func _ready():
	spawn_timer.connect("timeout", spawn)
	spawn()
	
func spawn():
	if holder.get_child_count() >= 10: return
	var balloon = balloon_scene.instantiate()
	holder.add_child(balloon)
	balloon.speed = randf_range(0.2, 1.0)
	balloon.scale = Vector3.ONE * randf_range(2.0, 8.0)
	balloon.rotation.y = randf_range(0.0, TAU)
	
	var p = Vector2.from_angle(randf_range(0.0, TAU)) * (15.0 + (10.0 * randf()))
	
	balloon.position = Vector3(p.x, 0.0, p.y)
