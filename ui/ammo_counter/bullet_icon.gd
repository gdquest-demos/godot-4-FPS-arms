extends ColorRect

var tween : Tween = null

func set_opacity(value : float, duration : float = 1.0, delay : float = 0.0):
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", value, duration).set_delay(delay)
