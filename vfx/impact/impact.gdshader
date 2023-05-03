shader_type spatial;
render_mode particle_trails, cull_disabled;
varying vec4 custom;
void vertex(){
	custom = INSTANCE_CUSTOM;
}

void fragment() {
	float edge = sin(UV.x * PI) * sin(UV.y * PI);
	edge = step(custom.z, edge);
	EMISSION = vec3(1.0) * 4.0;
	ALPHA = edge * (1.0 - custom.x);
}
