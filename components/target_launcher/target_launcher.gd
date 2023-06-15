extends Node3D

@onready var target = %Target
@onready var timer = %Timer
@onready var throw_sound = %ThrowSound
@onready var body = %Body

var confettis_scene = preload("res://vfx/confettis/confettis.tscn")
var tween : Tween = null

func _ready():
	start_rand_timer()
	target.hit_zone.connect("hit", on_target_hit)
	timer.connect("timeout", launch_target)
	
func on_target_hit():
	var confettis = confettis_scene.instantiate()
	add_sibling(confettis)
	confettis.global_position = target.global_position
	
	if tween.is_valid(): tween.kill()
	target.position.y = -0.5
	start_rand_timer()
	
func launch_target():
	var t = create_tween()
	for i in range(4):
		var v = ((i % 2) - 0.5) * 2.0
		t.tween_property(body, "position:x", v * 0.1, 0.1)
	await t.finished
	body.position.x = 0.0
	
	throw_sound.pitch_scale = randfn(0.8, 0.1)
	throw_sound.play()
	var launch_height = randf_range(4.0, 8.0)
	var launch_time = launch_height / 6.0

	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(target, "position:y", launch_height, launch_time).from(-0.5).set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "position:y", -0.5, launch_time).set_ease(Tween.EASE_IN)
	
	tween.tween_callback(start_rand_timer)

func start_rand_timer():
	timer.start(randf_range(2.0, 10.0))
