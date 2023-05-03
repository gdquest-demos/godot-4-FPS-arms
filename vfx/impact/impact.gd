extends Node3D

@onready var animation_player = %AnimationPlayer
@onready var impact_sound = %ImpactSound


func _ready():
	impact_sound.pitch_scale = randfn(1.0, 0.1)
	impact_sound.play()
	animation_player.play("default")
	await get_tree().create_timer(1.0).timeout
	queue_free()
	
