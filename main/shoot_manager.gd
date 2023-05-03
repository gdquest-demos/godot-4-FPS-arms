extends Node3D

@onready var player = %FpsController
@onready var laser_sound = %LaserSound
@export var impact_decal_scene : PackedScene
@export var impact_scene : PackedScene
@export var shot_scene : PackedScene
@export var projectile_scene : PackedScene
@onready var impact_manager = %ImpactManager

var laser_range = 20.0

func _ready():
	player.connect("shoot", on_player_shoot)

func on_player_shoot(gun_end_position : Vector3):
	var viewport = get_viewport()
	var camera : Camera3D = viewport.get_camera_3d()
	var origin = camera.project_ray_origin(viewport.size * 0.1)
	var normal : Vector3 = camera.project_ray_normal(viewport.size / 2.0)
	normal = normal.rotated(Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized(), 0.05)
	var end_position = origin + normal * laser_range
	var query = PhysicsRayQueryParameters3D.create(origin, end_position)
	var collision = get_world_3d().direct_space_state.intersect_ray(query)
	var collide = collision != {}
	
	var shot : Node3D = shot_scene.instantiate()
	shot.position = gun_end_position
	add_child(shot)
	
	laser_sound.pitch_scale = randfn(1.0, 0.1)
	laser_sound.play()

	if collide: end_position = collision.position
	var duration = end_position.distance_to(gun_end_position) / laser_range
	duration *= 0.5
	
	var projectile = projectile_scene.instantiate()
	projectile.position = gun_end_position
	add_child(projectile)
	projectile.transform = align_with_y(projectile.transform, normal)
	projectile.transparency = 1.0
	var t = create_tween().set_parallel(true)
	t.tween_property(projectile, "position", end_position, duration)
	t.tween_method(node_3d_alpha.bind(projectile), 0.0, 1.0, duration)
	t.chain().tween_callback(projectile.queue_free)
	
	if collide:
		end_position = collision.position
		await get_tree().create_timer(duration).timeout
		var impact : Node3D = impact_scene.instantiate()
		impact.position = collision.position
		add_child(impact)
		impact.transform = align_with_y(impact.transform, collision.normal)
		
		var impact_decal = impact_decal_scene.instantiate()
		impact_decal.position = collision.position
		impact_manager.add_child(impact_decal)
		impact_decal.transform = align_with_y(impact_decal.transform, collision.normal)


# https://kidscancode.org/godot_recipes/3.x/3d/3d_align_surface/
func align_with_y(t, new_y):
	t.basis.y = new_y
	t.basis.x = -t.basis.z.cross(new_y)
	t.basis = t.basis.orthonormalized()
	return t

func node_3d_alpha(progress : float, node_3d : MeshInstance3D):
	node_3d.transparency = 1.0 - sin(progress * PI)
