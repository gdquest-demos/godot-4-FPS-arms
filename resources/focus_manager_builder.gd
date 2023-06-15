extends Resource
class_name FocusManager

signal focus_node(node)
signal blur_node(node)
signal node_hit(target_node : Node3D)

func focus(node):
	focus_node.emit(node)

func blur(node):
	blur_node.emit(node)

func hit(target_node : Node3D):
	node_hit.emit(target_node)
