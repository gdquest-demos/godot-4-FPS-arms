shader_type spatial;

void vertex() {
	VERTEX.x += sin(UV.y * 0.8 * PI - TIME) * (UV.y) * 0.08;
	VERTEX.z += sin(UV.y * 2.0 * PI - TIME) * (UV.y) * 0.1;
}
