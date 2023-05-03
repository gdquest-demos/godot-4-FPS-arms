shader_type spatial;

uniform vec3 skin_color : source_color;
uniform vec3 extremity_color : source_color;
uniform vec3 nails_color : source_color;

void fragment() {
	float nail_mask = smoothstep(1.0, 0.8, COLOR.x);
	vec3 base_color = mix(skin_color * extremity_color, skin_color, UV.y);
	ALBEDO.rgb = mix(nails_color, base_color, nail_mask);
	ROUGHNESS = 0.75;

}
