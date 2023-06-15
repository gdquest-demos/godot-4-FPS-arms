extends Area3D
class_name HitZone

@export var main_focus_manager : FocusManager
signal hit
signal blured
signal focused

func _ready():
	main_focus_manager.connect("blur_node", on_blur_node)
	main_focus_manager.connect("focus_node", on_focus_node)
	main_focus_manager.connect("node_hit", on_node_hit)

func on_blur_node(node : Node):
	if node == self: blured.emit()
	
func on_focus_node(node : Node):
	if node == self: focused.emit()
	
func on_node_hit(node : Node3D):
	if node == self: hit.emit()
