extends SubViewportContainer

@onready var camera = %Camera3D
@onready var animation_tree = %AnimationTree
@onready var main_state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/MainState/playback")
@onready var fps_arms = %fps_arms
@onready var arms = %Arms
@onready var root = %Root
@onready var gun_end = %GunEnd

@onready var previous_pos = Vector3.ZERO
@onready var previous_rot = Vector3.ZERO
var is_walking = false : set = set_is_walking

var vel_x = 0
var vel_y = 0

signal footstep

func copy_pos_rot(pos, rot):
	previous_pos = pos
	previous_rot = rot
	
func set_is_walking(state : bool):
	var animation = "Walk" if state else "Idle"
	main_state_machine.travel(animation)
	main_state_machine.travel(animation)

func ground_impact():
	animation_tree.set("parameters/GroundImpactShot/request", true)

func fire():
	animation_tree.set("parameters/FireShot/request", true)

func reload():
	animation_tree.set("parameters/ReloadShot/request", true)

func _process(delta):
	vel_y += previous_rot.y - root.rotation.y
	vel_y = lerp_angle(vel_y, 0.0, 20.0 * delta)
	
	vel_x += (previous_rot.x - root.rotation.x)
	vel_x += (previous_pos.y - root.global_position.y)
	vel_x = lerp_angle(vel_x, 0.0, 20.0 * delta)
	
	fps_arms.rotation.x = -vel_x
	fps_arms.rotation.y = vel_y
	fps_arms.rotation.x = max(fps_arms.rotation.x, -deg_to_rad(10.0))

	previous_pos = root.global_position
	previous_rot = root.rotation
