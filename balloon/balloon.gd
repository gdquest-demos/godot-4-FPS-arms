extends Node3D

@onready var head = %Head
@export var colors : Array[Color] = []
@onready var hit_zone = %HitZone
@onready var outline_mat : ShaderMaterial = head.material_overlay
@onready var animation_player = %AnimationPlayer

@onready var confettis_scene = preload("res://vfx/confettis/confettis.tscn")

var speed = 0.5

func _ready():
	head.material_override.set_shader_parameter("albedo", colors.pick_random())
	hit_zone.connect("hit", explode)
	
	hit_zone.connect("focused", func():
		outline_mat.set_shader_parameter("alpha", 1.0)
		)
	hit_zone.connect("blured", func():
		outline_mat.set_shader_parameter("alpha", 0.0)
		)
	outline_mat.set_shader_parameter("alpha", 0.0)
	
	hit_zone.connect("area_entered", func(area : Area3D):
		if !area.is_in_group("limit"): return
		var t = create_tween().set_ease(Tween.EASE_OUT)
		t.tween_property(self, "scale", Vector3.ONE * 0.2, 0.1)
		t.tween_callback(queue_free)
		)
		
		
func explode():
	var confettis = confettis_scene.instantiate()
	add_sibling(confettis)
	confettis.global_position = global_position
	confettis.scale = scale * 0.3
	
	hit_zone.queue_free()
	outline_mat.set_shader_parameter("alpha", 0.0)
	animation_player.connect("animation_finished", func(_animation_name): queue_free())
	animation_player.play("boom")
	
func _process(delta):
	var t = Time.get_ticks_msec() / 1000.0
	head.rotation.x = sin(t) * 0.1
	head.rotation.z = sin(t * 0.5) * 0.1
	rotation.y += 0.1 * delta
	position.y += speed * delta
