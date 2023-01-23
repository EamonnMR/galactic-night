shader_type canvas_item;

uniform vec2 center = vec2(0,0);
uniform int radius;

void fragment() {
	float real_radius = float(radius) * TEXTURE_PIXEL_SIZE.x;
	vec2 real_center = (center * TEXTURE_PIXEL_SIZE) + vec2(0.5, 0.5);
	if (distance(real_center, UV) > real_radius){
		COLOR = texture(TEXTURE, UV); //read from texture
		COLOR.a = length(COLOR.rgb);
	} else {
		COLOR = texture(TEXTURE, UV);
	}
}
