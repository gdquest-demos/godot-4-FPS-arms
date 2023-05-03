extends Node3D

var max_decals = 10
var visible_decals = []

func _ready():
	connect("child_entered_tree", check_childs)

func check_childs(decal : Decal):
	visible_decals.append(decal)
	if visible_decals.size() <= max_decals: return
	var first_visible_decal = visible_decals.pop_front()
	first_visible_decal.fade_out()
