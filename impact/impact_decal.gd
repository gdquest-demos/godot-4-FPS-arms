extends Decal

@export var diffuse : Array[Texture] = []
@export var normal : Array[Texture] = []

func _ready():
	var picked_texture_id = randi_range(0, diffuse.size() - 1)
	texture_albedo = diffuse[picked_texture_id]
	texture_normal = normal[picked_texture_id]

func fade_out():
	var t = create_tween()
	t.tween_property(self, "modulate:a", 0.0, 1.0)
	t.tween_callback(queue_free)
