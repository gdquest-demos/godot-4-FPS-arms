extends TextureRect

func _ready():
	pivot_offset = size / 2.0

func bump():
	var t = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "scale", Vector2.ONE * 1.3, 0.1)
	t.tween_property(self, "scale", Vector2.ONE, 0.2)
