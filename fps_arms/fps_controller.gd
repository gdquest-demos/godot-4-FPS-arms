extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera = %Camera3D
@onready var arms_view = %ArmsView
@onready var foot_step = %FootStep
@onready var landing = %Landing

@onready var weapon_data = preload("res://resources/laser_gun_data.tres")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

signal shoot(gun_position)

func _ready():
	weapon_data.connect("reloaded", func():
		arms_view.reload()
		)
	arms_view.copy_pos_rot(camera.global_position, camera.rotation)

func on_footstep():
	foot_step.pitch_scale = randfn(0.8, 0.1)
	foot_step.play()

func _unhandled_input(event):
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if event is InputEventMouseMotion:
		camera.rotation.y -= event.relative.x * 0.005
		camera.rotation.x -= event.relative.y * 0.005
		camera.rotation.x = clamp(camera.rotation.x, -1.0, 0.8)

func get_gun_end_position():
	var depth = arms_view.camera.to_local(arms_view.gun_end.global_position).length()
	var screen_pos = arms_view.camera.unproject_position(arms_view.gun_end.global_position)
	return (camera.project_position(screen_pos, depth))
	
func _physics_process(delta):
	if Input.is_action_just_pressed("shoot") && weapon_data.has_ammo():
		weapon_data.use()
		arms_view.fire()
		shoot.emit(get_gun_end_position())
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = input_dir.rotated(-camera.rotation.y)
	if direction:
		var a = Vector2(velocity.x, velocity.z).lerp(direction * SPEED, SPEED * 0.1)
		velocity.x = a.x
		velocity.z = a.y
	else:
		var d = velocity.lerp(Vector3.ZERO, SPEED * 0.05)
		velocity.x = d.x
		velocity.z = d.z
		
	var in_air = !is_on_floor()
	var fall_velocity = velocity.y
	move_and_slide()
	var on_floor = is_on_floor()
	if in_air and on_floor:
		var impact_speed = remap(clamp(abs(fall_velocity), 0.0, SPEED * 2.0),
		0.0, SPEED * 2.0, 0.0, 1.0)
		landing.volume_db = -20.0 + impact_speed * 10.0
		landing.pitch_scale = randfn(1.0, 0.1)
		landing.play()
	
	var is_moving = Vector2(velocity.x, velocity.z).length() > 0.0
	arms_view.is_walking = direction.length() > 0.0 && is_on_floor() && is_moving
