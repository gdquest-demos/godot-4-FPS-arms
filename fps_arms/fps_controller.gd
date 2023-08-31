extends CharacterBody3D

## Default walk speed
@export_range(1.0, 10.0, 0.1) var SPEED = 5.0
## Default jump speed
@export_range(1.0, 10.0, 0.1) var JUMP_VELOCITY = 4.5
## Define how fast or slow the character can accelerate
@export_range(1.0, 10.0, 0.1) var BASE_ACCELERATION_SPEED = 8.0


@export var main_focus_manager : FocusManager

@onready var focus_cast : RayCast3D = %FocusCast
@onready var camera = %Camera3D
@onready var arms_view = %ArmsView
@onready var foot_step = %FootStep
@onready var landing = %Landing
@onready var no_ammo = %NoAmmo

@onready var weapon_data = preload("res://resources/laser_gun_data.tres")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var last_firing_time = 0

@export var weapon_meter_range = 20.0

var look_direction = Vector2.ZERO

signal shoot(origin : Vector3, normal : Vector3, gun_end_position : Vector3, weapon_range : float, collision : Dictionary)

func _ready():
	weapon_data.connect("reloaded", func():
		arms_view.reload()
		)
	arms_view.copy_pos_rot(camera.global_position, camera.rotation)
	arms_view.connect("footstep", on_footstep)
	focus_cast.target_position.z = -weapon_meter_range
	
func on_footstep():
	foot_step.pitch_scale = randfn(1.0, 0.05)
	foot_step.play()

func _unhandled_input(event):
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if event is InputEventMouseMotion:
		look_direction = event.relative * 0.0025

func check_look_motion(delta):
	var joy_look_vector = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if joy_look_vector.length() > 0.0:
		look_direction = joy_look_vector * 2.0 * delta

	camera.rotation.y -= look_direction.x
	camera.rotation.x -= look_direction.y
	camera.rotation.x = clamp(camera.rotation.x, -1.2, 1.2)
	
	look_direction = Vector2.ZERO

func get_gun_end_position():
	var depth = arms_view.camera.to_local(arms_view.gun_end.global_position).length()
	var screen_pos = arms_view.camera.unproject_position(arms_view.gun_end.global_position)
	return (camera.project_position(screen_pos, depth))

func get_focus_collision():
	if !focus_cast.is_colliding(): return {}
	return {
		"collider": focus_cast.get_collider(),
		"position": focus_cast.get_collision_point(),
		"normal": focus_cast.get_collision_normal()
	}

func check_gun():
	var shoot_time_diff = Time.get_ticks_msec() - last_firing_time
	var busy = arms_view.is_reloading or !(shoot_time_diff > 200)
	if Input.is_action_just_pressed("shoot") && !weapon_data.has_ammo():
		arms_view.shake()
		no_ammo.play()
		return
		
	if Input.is_action_pressed("shoot") && !busy:
		if weapon_data.should_reload():
			weapon_data.reload()
			return
		
		if weapon_data.has_ammo():
			last_firing_time = Time.get_ticks_msec()
			weapon_data.use()
			arms_view.fire()
			
			shoot.emit(
				camera.global_position,
				-camera.transform.basis.z,
				get_gun_end_position(),
				weapon_meter_range,
				get_focus_collision()
			)

var focused_node = null

func check_focus():
	var current_focus_node = focus_cast.get_collider()
	if focused_node == current_focus_node: return
	var last_focused_node = focused_node
	focused_node = current_focus_node
	if is_instance_valid(last_focused_node):
		main_focus_manager.blur(last_focused_node)
	main_focus_manager.focus(current_focus_node)
	
func apply_acceleration(direction : Vector2, acceleration_factor : float, delta : float):
	var a = Vector2(velocity.x, velocity.z).move_toward(direction * SPEED, SPEED * acceleration_factor * BASE_ACCELERATION_SPEED * delta)
	velocity.x = a.x
	velocity.z = a.y
	
func apply_drag(amount : float, delta : float):
	var d = velocity.move_toward(Vector3.ZERO, SPEED * amount * delta)
	velocity.x = d.x
	velocity.z = d.z
	
func _physics_process(delta):
	check_look_motion(delta)
	check_focus()
	check_gun()
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = input_dir.rotated(-camera.rotation.y)
	
	if direction.length() != 0.0: apply_acceleration(direction, 1.0 if is_on_floor() else 0.2, delta)
	else: apply_drag(4.0 if is_on_floor() else 2.0, delta)
		
	var in_air = !is_on_floor()
	var fall_velocity = velocity.y
	move_and_slide()
	var on_floor = is_on_floor()
	if in_air and on_floor:
		var impact_speed = remap(clamp(abs(fall_velocity), 0.0, SPEED * 2.0),
		0.0, SPEED * 2.0, 0.0, 1.0)
		landing.volume_db = impact_speed * 10.0
		landing.pitch_scale = randfn(1.0, 0.1)
		landing.play()
	
	var is_moving = Vector2(velocity.x, velocity.z).length() > 0.0
	arms_view.is_walking = direction.length() > 0.0 && is_on_floor() && is_moving
