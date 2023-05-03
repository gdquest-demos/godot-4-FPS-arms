shader_type spatial;
varying vec4 custom;
uniform sampler2D waves_sample : repeat_disable;
uniform vec3 base_color : source_color;
uniform float energy = 1.0;
void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0), vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	custom = INSTANCE_CUSTOM;
}

void fragment(){
	float dist = texture(waves_sample, vec2(distance(UV, vec2(0.5)) * 2.0, 0.0)).x;
	ALBEDO.rgb = base_color;
	EMISSION = base_color * energy;
	ALPHA = dist * (COLOR.a);
}