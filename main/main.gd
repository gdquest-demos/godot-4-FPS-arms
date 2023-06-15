extends Node

@onready var player = %FpsController
@onready var cross_hair = %CrossHair
@onready var bottom_area = %BottomArea

@onready var start_position = player.global_position

func _ready():
	player.connect("shoot", func(_o, _n, _g_e, _w_r, _c):
			cross_hair.bump()
			)
	bottom_area.connect("body_entered", func(body):
			if body == player:
				player.global_position = start_position
			)
