shader_type spatial;
 
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D waves_sample : repeat_disable;
uniform float fade : hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float wave_offset : hint_range(-1.0, 1.0, 0.1)  = 0.0;
uniform vec3 base_color : source_color;
uniform float energy = 1.0;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0), vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}
void fragment() {
	float dist = distance(UV, vec2(0.5));
	float edge = smoothstep(0.5, 0.4, dist);
	float wave = texture(waves_sample, vec2(dist * 2.0 - wave_offset, 0.0)).x * fade * (1.0 - sin(UV.y * PI));

	vec3 screen_color = textureLod(screen_texture, SCREEN_UV, 4.0).rgb;
	ALBEDO.rgb = base_color;
	EMISSION = base_color * energy;
	ALPHA = wave * edge;
	SPECULAR = 0.0;
	ROUGHNESS = 1.0;
	

}
