shader_type spatial;
render_mode cull_disabled, unshaded;

uniform vec4 outline_color : source_color;
uniform float outline_width = 1.0;

varying vec3 v;

void vertex() {
	VERTEX += NORMAL * 0.1;
	v = VERTEX;
}

void fragment() {
	float wave = (1.0 + sin(v.y * 4.0 * PI + TIME)) / 2.0;
	ALPHA = step(wave, 0.6) * 0.4 + (1.0 - float(FRONT_FACING));
	ALBEDO = outline_color.rgb;
}