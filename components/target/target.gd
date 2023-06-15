extends Node3D

@onready var hit_zone = %HitZone
@onready var impact_sound = %ImpactSound

@onready var outline_mat : ShaderMaterial = $Visual/target/Cylinder.material_overlay

func _ready():
	hit_zone.connect("hit", on_hit)
	hit_zone.connect("focused", func():
		outline_mat.set_shader_parameter("alpha", 1.0)
		)
	hit_zone.connect("blured", func():
		outline_mat.set_shader_parameter("alpha", 0.0)
		)
	outline_mat.set_shader_parameter("alpha", 0.0)

func on_hit():
	var t = create_tween()
	t.tween_property(self, "scale", Vector3.ONE * 1.1, 0.1)
	t.tween_property(self, "scale", Vector3.ONE, 0.1)
	
	impact_sound.pitch_scale = randfn(1.0, 0.1)
	impact_sound.play()
