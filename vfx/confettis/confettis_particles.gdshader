shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D shapes_sampler : filter_linear_mipmap, repeat_disable;
uniform sampler2D color_sampler;
varying vec4 custom;

void vertex() {
	custom = INSTANCE_CUSTOM;
}

void fragment() {
	float shape = texture(shapes_sampler, (UV + vec2(round(mod(COLOR.x * 3.0, 3)), 0.0)) * vec2(0.333, 1.0)).a;
	ALBEDO = texture(color_sampler, vec2(COLOR.x, 0.0)).rgb;
	ALPHA = shape;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
