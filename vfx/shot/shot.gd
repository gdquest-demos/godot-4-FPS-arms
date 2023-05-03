extends Node3D

@onready var wave = %Wave
@onready var particles = %Particles

func _ready():
	var random_duration = randf_range(0.2, 0.4)
	var top_duration = random_duration * 1.8
	particles.lifetime = top_duration
	particles.emitting = true
	var t = create_tween().set_parallel(true)
	t.tween_property(wave.material_override, "shader_parameter/fade", 0.0, random_duration).from(1.0)
	t.tween_property(wave.material_override, "shader_parameter/wave_offset", 0.2, random_duration).from(-0.5)
	t.tween_property(wave, "scale", Vector3.ONE * randf_range(1.4, 2.0), random_duration).from(Vector3.ONE * 0.5)
	await get_tree().create_timer(top_duration).timeout
	queue_free()
	
