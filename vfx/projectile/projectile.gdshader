shader_type spatial;
render_mode cull_disabled;
uniform vec3 base_color : source_color;
uniform float energy = 1.0;
uniform sampler2D shape_curve;

void fragment() {
	float edge = sin(UV.x * PI) * texture(shape_curve, vec2(UV.y, 0.0)).x;
	ALBEDO = base_color;
	EMISSION = base_color * energy;
	ALPHA *= smoothstep(0.1, 1.0, edge) * (1.0-UV.y * sin((UV.x + TIME) * 10.0));
}
