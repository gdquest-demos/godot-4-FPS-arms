extends Node3D

@onready var gpu_particles_3d = %GPUParticles3D

func _ready():
	gpu_particles_3d.emitting = true
	await get_tree().create_timer(1.0).timeout
	queue_free()
