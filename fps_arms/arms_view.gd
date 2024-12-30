class_name ArmsViewport extends SubViewportContainer

signal footstep

@onready var camera: Camera3D = %Camera3D
@onready var animation_tree: AnimationTree = %AnimationTree
@onready var main_state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/MainState/playback")
@onready var fps_arms: Node3D = %FPSArms
@onready var arms: Node3D = %Arms
@onready var root: Node3D = %Root
@onready var gun_end: Node3D = %GunEnd

@onready var previous_position := Vector3.ZERO
@onready var previous_rotation := Vector3.ZERO

var is_reloading := false
var is_walking := false:
	set(state):
		if is_walking == state:
			return
		is_walking = state
		var animation := "Walk" if state else "Idle"
		main_state_machine.travel(animation)
		animation_tree.set("parameters/AddSteps/add_amount", float(is_walking))

var vertical_velocity := 0.0
var angular_velocity := Vector3.ZERO


func _ready() -> void:
	animation_tree.animation_finished.connect(func(animation_name: StringName) -> void:
		if animation_name == "ReloadMag":
			is_reloading = false
	)


func apply_position_and_rotation(target_global_transform: Transform3D) -> void:
	previous_position = target_global_transform.origin
	previous_rotation = target_global_transform.basis.get_euler()


func ground_impact() -> void:
	animation_tree.set("parameters/GroundImpactShot/request", true)


func fire() -> void:
	animation_tree.set("parameters/FireShot/request", true)


func shake() -> void:
	animation_tree.set("parameters/ShakeShot/request", true)


func reload() -> void:
	is_reloading = true
	animation_tree.set("parameters/ReloadShot/request", true)


func _process(delta: float) -> void:
	var current_position := root.global_position
	var current_rotation := root.rotation

	angular_velocity += Vector3(
		wrap_angle(previous_rotation.x, current_rotation.x) * 20.0 * delta,
		wrap_angle(previous_rotation.y, current_rotation.y) * 20.0 * delta,
		0.0
	)

	vertical_velocity += (previous_position.y - current_position.y) * 20.0 * delta

	const MAX_ANGLE_X := deg_to_rad(8.0)
	const MAX_ANGLE_Y := deg_to_rad(15.0)

	fps_arms.rotation.x = clamp(-(angular_velocity.x + vertical_velocity), -MAX_ANGLE_X, MAX_ANGLE_X)
	fps_arms.rotation.y = clamp(angular_velocity.y, -MAX_ANGLE_Y, MAX_ANGLE_Y)

	angular_velocity = angular_velocity.slerp(Vector3.ZERO, 10.0 * delta)
	vertical_velocity = lerpf(vertical_velocity, 0.0, 10.0 * delta)

	previous_position = root.global_position
	previous_rotation = root.rotation


func wrap_angle(from: float, to: float) -> float:
	return fposmod(from - to + PI, PI * 2) - PI
