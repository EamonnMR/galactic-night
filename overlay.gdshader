shader_type canvas_item;

uniform float warp_factor = 0;
uniform float warp_factor_scale = 10;
uniform float warp_angle;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	COLOR = (1.0 + (warp_factor * warp_factor_scale)) * textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
}
