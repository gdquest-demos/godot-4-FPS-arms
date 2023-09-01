shader_type spatial;

uniform vec3 skin_color : source_color;
uniform vec3 extremity_color : source_color;
uniform vec3 nails_color : source_color;
uniform vec3 gloves_color : source_color;

vec3 fresnel_glow(float amount, float intensity, vec3 color, vec3 normal, vec3 view)
{
	return pow((1.0 - dot(normalize(normal), normalize(view))), amount) * color * intensity;
}


void fragment() {
	vec3 base_color = mix(skin_color, skin_color * extremity_color, COLOR.z);
	ALBEDO.rgb = mix(mix(base_color, nails_color, COLOR.y), gloves_color, COLOR.x);
	vec3 f = fresnel_glow(4.0, 4.5, ALBEDO.rgb, NORMAL, VIEW);
	ALBEDO.rgb += f * 0.8;
	ROUGHNESS = 0.75;
}
