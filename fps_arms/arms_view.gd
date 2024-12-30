class_name ArmsViewport extends SubViewportContainer

@onready var camera: Camera3D = %Camera3D
@onready var animation_tree = %AnimationTree
@onready var main_state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/MainState/playback")
@onready var fps_arms = %FPSArms
@onready var arms = %Arms
@onready var root = %Root
@onready var gun_end: Node3D = %GunEnd

@onready var previous_pos = Vector3.ZERO
@onready var previous_rot = Vector3.ZERO

var is_reloading : bool = false
var is_walking : bool = false : set = set_is_walking

var vel_y = 0.0
var angular_velocity = Vector3.ZERO

signal footstep

func _ready():
	animation_tree.connect("animation_finished", func(animation_name : StringName):
			if animation_name == "ReloadMag":
				is_reloading = false
				)
	
func copy_pos_rot(pos, rot):
	previous_pos = pos
	previous_rot = rot
	
func set_is_walking(state : bool):
	if is_walking == state : return
	is_walking = state
	var animation = "Walk" if state else "Idle"
	main_state_machine.travel(animation)
	animation_tree.set("parameters/AddSteps/add_amount", float(is_walking))

func ground_impact():
	animation_tree.set("parameters/GroundImpactShot/request", true)

func fire():
	animation_tree.set("parameters/FireShot/request", true)

func shake():
	animation_tree.set("parameters/ShakeShot/request", true)


func reload():
	is_reloading = true
	animation_tree.set("parameters/ReloadShot/request", true)
	
func _process(delta):
	var current_pos = root.global_position
	var current_rot = root.rotation
	
	angular_velocity += Vector3(
		wrap_angle(previous_rot.x, current_rot.x) * 20.0 * delta,
		wrap_angle(previous_rot.y, current_rot.y) * 20.0 * delta,
		0.0
	)
	
	vel_y += (previous_pos.y - current_pos.y) * 20.0 * delta
	
	var max_x_angle = deg_to_rad(8.0)
	var max_y_angle = deg_to_rad(15.0)
	
	fps_arms.rotation.x = clamp(-(angular_velocity.x + vel_y), -max_x_angle, max_x_angle)
	fps_arms.rotation.y = clamp(angular_velocity.y, -max_y_angle, max_y_angle)
	
	angular_velocity = angular_velocity.slerp(Vector3.ZERO, 10.0 * delta)
	vel_y = lerpf(vel_y, 0.0, 10.0 * delta)
	
	previous_pos = root.global_position
	previous_rot = root.rotation

func wrap_angle(from, to) -> float:
	return fposmod(from - to + PI, PI*2) - PI
