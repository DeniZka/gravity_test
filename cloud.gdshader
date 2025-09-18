shader_type canvas_item;
uniform sampler2D noise: hint_default_white;
uniform float distortion;

void fragment() {
	// Called for every pixel the material is visible on.
    vec2 center = vec2(0.5, 0.5); // Центр экрана
	vec2 to_center = UV - center;
	float radius = length(to_center);
	vec2 distorted_uv = center + (to_center / (10.0 + radius * distortion));
	// Получение цвета из искаженной текстуры
	if (radius < 0.5) {
		COLOR = texture(noise, distorted_uv);
		COLOR.a = COLOR.r - 0.2;
	} else {
		discard;
	}
}

