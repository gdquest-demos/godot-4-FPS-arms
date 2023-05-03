extends Node

@onready var player = %FpsController
@onready var cross_hair = %CrossHair

func _ready():
	player.connect("shoot", func(_gun_end_position):
			cross_hair.bump()
			)
