extends RayCast3D

@export var main_focus_manager : FocusManager

var focused_node = null

func _physics_process(_delta):
	var current_focus_node = get_collider()
	if focused_node == current_focus_node: return
	var last_focused_node = focused_node
	focused_node = current_focus_node
	if is_instance_valid(last_focused_node):
		main_focus_manager.blur(last_focused_node)
	main_focus_manager.focus(current_focus_node)

func get_focus_collision():
	if !self.is_colliding(): return {}
	return {
		"collider": self.get_collider(),
		"position": self.get_collision_point(),
		"normal": self.get_collision_normal()
	}
