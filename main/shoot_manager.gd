extends Node3D

@onready var player = %FpsController
@onready var laser_sound = %LaserSound
@export var impact_decal_scene : PackedScene
@export var impact_scene : PackedScene
@export var shot_scene : PackedScene
@export var projectile_scene : PackedScene
@onready var impact_manager = %ImpactManager
@export var main_focus_manager : FocusManager

func _ready():
	player.connect("shoot", on_player_shoot)

func on_player_shoot(origin : Vector3, normal : Vector3, gun_end_position : Vector3, weapon_range : float, collision : Dictionary):
	var end_position = origin + normal * weapon_range
	var collide = collision != {}
	
	var shot : Node3D = shot_scene.instantiate()
	shot.position = gun_end_position
	add_child(shot)
	
	laser_sound.pitch_scale = randfn(1.0, 0.1)
	laser_sound.play()

	if collide: end_position = collision.position
	var duration = end_position.distance_to(gun_end_position) / weapon_range
	duration *= 0.2
	
	var projectile = projectile_scene.instantiate()
	projectile.position = gun_end_position
	add_child(projectile)
	projectile.transform = align_with_y(projectile.transform, normal)
	projectile.transparency = 1.0
	var t = create_tween().set_parallel(true)
	t.tween_property(projectile, "position", end_position, duration)
	t.tween_method(node_3d_alpha.bind(projectile), 0.0, 1.0, duration)
	t.chain().tween_callback(projectile.queue_free)
	
	if !collide: return
	
	main_focus_manager.hit(collision.collider)
	
	end_position = collision.position
	await get_tree().create_timer(duration).timeout
	var impact : Node3D = impact_scene.instantiate()
	impact.position = collision.position
	add_child(impact)
	impact.transform = align_with_y(impact.transform, collision.normal)
	
	if !collision.collider or collision.collider is Area3D: return
	
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
