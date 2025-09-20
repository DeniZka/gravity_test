//https://youtu.be/Atu_Keasbjk?si=LKzl9NoHwNijXVv0
shader_type canvas_item;
uniform sampler2D noise: hint_default_white;
uniform float power: hint_range(0.1, 10.0, 0.01) = 1.0;
uniform float radius: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float crop_edge: hint_range(0.0, 1.0, 0.01) = 0.12;
uniform float rotate_speed: hint_range(0.0, 1.0, 0.01) = 0.1;


vec2 rotateUVmatrinx(vec2 uv, vec2 pivot, float rotation)
{
	mat2 rotation_matrix=mat2(	vec2(sin(rotation),-cos(rotation)),
								vec2(cos(rotation),sin(rotation))
								);
    uv -= pivot;
    uv= uv*rotation_matrix;
    uv += pivot;
    return uv;
}

void fragment() {
	// Called for every pixel the material is visible on.
    vec2 uv = UV;
	uv = rotateUVmatrinx(UV, vec2(0.5), TIME*rotate_speed);
	
	vec2 resolution = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 aspect_uv = UV;
	aspect_uv.x *= resolution.x / resolution.y;
	vec2 center = vec2(0.5, 0.5);
	vec2 eye_uv = center; // Центр экрана
	eye_uv.x *= resolution.x / resolution.y;
	float dist = distance(eye_uv, aspect_uv);
	float wrap = clamp(0.5 - pow(dist / radius, 5.0), 0.0, 1.0);
	float mag_factor = pow(wrap, 1.0 / power);
	// Получение цвета из искаженной текстуры
	if (dist < radius) {
		uv += mag_factor * (center - uv); 
	}
	
	COLOR = texture(noise, uv);
	COLOR.a = COLOR.r * .7;
	if (dist > radius - crop_edge) {
		COLOR.a = 0.0;
	}
}

