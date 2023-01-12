shader_type canvas_item;

#include "colorshift.gdshaderinc"

uniform vec2 position;
const int LAYERS = 1;
const float DEPTH_FACTOR = 0.7;
const float DEPTH_OFFSET = 0.0;

//render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;
uniform sampler2D texture_albedo : source_color,filter_nearest,repeat_enable;
uniform sampler2D second_texture_albedo : source_color,filter_nearest,repeat_enable;


uniform float color_shift;

void broken_fragment(){
	COLOR = vec4(0,0,0,1);
	for (int i = 1; i <= LAYERS; i ++){
	               
		// Offset stars by player position
		vec2 shifted_uv = UV;
		shifted_uv.x += (
			position.x / (DEPTH_OFFSET + float(i) / DEPTH_FACTOR)
		);
		shifted_uv.y += (
			position.y / (DEPTH_OFFSET + float(i) / DEPTH_FACTOR)
		);
		shifted_uv.x = fract(shifted_uv.x);
		shifted_uv.y = fract(shifted_uv.y);
	               
		// Invert every other layer
		if(bool(i % 2)){
			shifted_uv.x = 1.0 - shifted_uv.x;
			shifted_uv.y = 1.0 - shifted_uv.y;
		}
		if(bool(i % 3)){
			if (shifted_uv.x > 1.0 || shifted_uv.y < 0.0 || shifted_uv.y > 1.0 || shifted_uv.y < 0.0){
				//COLOR = vec4(1,1,1,1);
			}
			COLOR += texture(second_texture_albedo, shifted_uv).rgba;
		}
		else {
			COLOR += texture(texture_albedo, shifted_uv).rgba;
		}
	}
}
