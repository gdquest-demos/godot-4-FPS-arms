extends CharacterBody3D

signal shoot(origin: Vector3, normal: Vector3, gun_end_position: Vector3, weapon_range: float, collision: Dictionary)

@export_range(1.0, 10.0, 0.1) var speed := 5.0
@export_range(1.0, 10.0, 0.1) var jump_velocity := 4.5
@export_range(1.0, 10.0, 0.1) var base_acceleration_speed := 8.0

@onready var _focus_cast: RayCast3D = %FocusCast
@onready var _camera: Camera3D = %Camera3D
@onready var _arms_viewport: ArmsViewport = %ArmsView
@onready var _collision_shape: CollisionShape3D = %CollisionShape3D
@onready var _neck: Node3D = %Neck
@onready var _crouch_ceiling_cast: ShapeCast3D = %CrouchCeilingCast

@onready var _foot_step: AudioStreamPlayer = %FootStep
@onready var _landing: AudioStreamPlayer = %Landing
@onready var _no_ammo: AudioStreamPlayer = %NoAmmo

@onready var weapon_data = preload("res://resources/laser_gun_data.tres")

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var last_firing_time := 0
var weapon_meter_range := 20.0
var look_direction := Vector2.ZERO
var is_crouching := false: set = set_is_crouching


func _ready() -> void:
	weapon_data.connect("reloaded", func():
		_arms_viewport.reload()
	)
	_arms_viewport.copy_pos_rot(_camera.global_position, _camera.rotation)
	_arms_viewport.footstep.connect(func on_character_stepped() -> void:
			if is_crouching:
				return
			_foot_step.pitch_scale = randfn(1.0, 0.05)
			_foot_step.play()
	)
	_focus_cast.add_exception(self)
	_focus_cast.target_position.z = -weapon_meter_range


func set_is_crouching(value: bool) -> void:
	if is_crouching == value:
		return
	if not value and _crouch_ceiling_cast.is_colliding():
		return

	is_crouching = value

	_collision_shape.position.y = 0.5 if is_crouching else 1.0
	_collision_shape.shape.height = 1.0 if is_crouching else 2.0

	var crouch_tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	crouch_tween.tween_property(_neck, "position:y", 1.0 if is_crouching else 1.6, 0.25)




func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion:
		look_direction = event.relative * 0.0025


func get_gun_end_position() -> Vector3:
	var camera_depth := _arms_viewport.camera.to_local(_arms_viewport.gun_end.global_position).length()
	var screen_position := _arms_viewport.camera.unproject_position(_arms_viewport.gun_end.global_position)
	return _camera.project_position(screen_position, camera_depth)



func _physics_process(delta: float) -> void:
	# Look handling
	var joystick_look_vector := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if joystick_look_vector.length() > 0.0:
		look_direction = joystick_look_vector * 2.0 * delta

	_camera.rotation.y -= look_direction.x
	_camera.rotation.x -= look_direction.y
	_camera.rotation.x = clamp(_camera.rotation.x, -1.2, 1.2)

	look_direction = Vector2.ZERO

	if not is_on_floor():
		velocity.y -= gravity * delta

	if is_on_floor():
		is_crouching = Input.is_action_pressed("crouching")

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity

	var input_direction := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var movement_direction := input_direction.rotated(-_camera.rotation.y)

	if movement_direction.length() != 0.0:
		var walk_speed := speed
		if is_crouching:
			walk_speed *= 0.5
		var ground_velocity := Vector2(velocity.x, velocity.z)
		var velocity_change := speed * (1.0 if is_on_floor() else 0.2) * base_acceleration_speed * delta
		ground_velocity = ground_velocity.move_toward(movement_direction * walk_speed, velocity_change)
		velocity = Vector3(ground_velocity.x, velocity.y, ground_velocity.y)
	else:
		var drag_factor := 4.0 if is_on_floor() else 2.0
		var new_ground_velocity := velocity.move_toward(Vector3.ZERO, speed * drag_factor * delta)
		velocity = Vector3(new_ground_velocity.x, velocity.y, new_ground_velocity.z)

	var was_in_air := not is_on_floor()
	var vertical_velocity := velocity.y
	move_and_slide()
	var just_landed := was_in_air and is_on_floor()
	if just_landed:
		var impact_speed := remap(clamp(abs(vertical_velocity), 0.0, speed * 2.0),
		0.0, speed * 2.0, 0.0, 1.0)
		_landing.volume_db = impact_speed * 10.0
		_landing.pitch_scale = randfn(1.0, 0.1)
		_landing.play()

	var is_moving := Vector2(velocity.x, velocity.z).length() > 0.0
	_arms_viewport.is_walking = movement_direction.length() > 0.0 and is_on_floor() and is_moving

	# Weapon handling
	var time_since_last_shot := Time.get_ticks_msec() - last_firing_time
	var is_weapon_busy := _arms_viewport.is_reloading or not (time_since_last_shot > 200.0)
	if Input.is_action_just_pressed("shoot") and not weapon_data.has_ammo():
		_arms_viewport.shake()
		_no_ammo.play()
		return

	if Input.is_action_pressed("shoot") and not is_weapon_busy:
		if weapon_data.should_reload():
			weapon_data.reload()
			return

		if weapon_data.has_ammo():
			last_firing_time = Time.get_ticks_msec()
			weapon_data.use()
			_arms_viewport.fire()

			shoot.emit(
				_camera.global_position,
				-_camera.transform.basis.z,
				get_gun_end_position(),
				weapon_meter_range,
				_focus_cast.get_focus_collision()
			)
