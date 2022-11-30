shader_type spatial;

#include "perspective.gdshaderinc"
#include "colorshift.gdshaderinc"

render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform sampler2D texture_albedo : source_color,filter_nearest,repeat_enable;
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_nearest,repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_nearest,repeat_enable;
uniform float specular;
uniform float metallic;
uniform sampler2D texture_normal : hint_roughness_normal,filter_nearest,repeat_enable;
uniform float normal_scale : hint_range(-16,16);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

uniform mat4 xform;
uniform mat4 inv_xform;
uniform float perspective_correct = 0.5;

uniform sampler2D texture_base_emission: source_color;
uniform sampler2D texture_engine_emission : source_color;
uniform sampler2D texture_weapon_emission : source_color;

uniform float emission_energy;

uniform float base_emission_factor = 1;
uniform float engine_emission_factor = 1;
uniform float weapon_emission_factor=  1;

uniform sampler2D texture_paint : source_color;

uniform float paint_hue: hint_range(0,1);
uniform float paint_saturation: hint_range(0,2);
uniform float paint_brightness: hint_range(-1,1);
uniform float base_brightness: hint_range(-1,1);

uniform float lights_hue: hint_range(0,1);
uniform float lights_saturation: hint_range(0,2);
uniform float lights_brightness: hint_range(0,2);
uniform float weapon_hue: hint_range(0,1);
uniform float weapon_saturation: hint_range(0,2);

void vertex() {
	//https://discord.com/channels/212250894228652034/408555922349359105/988915027035693186
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	VERTEX = adjust_for_perspective(VERTEX, perspective_correct, xform, inv_xform);
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	vec4 paint_tex = texture(texture_paint,base_uv);
	if (paint_tex.a > 0.5){
		vec3 paint_tex_hsv = rgb2hsv(paint_tex.rgb);
		paint_tex_hsv.x += paint_hue;
		paint_tex_hsv.y *= paint_saturation;
		paint_tex_hsv.z += paint_brightness;
		ALBEDO = hsv2rgb(paint_tex_hsv);
	} else {
		vec3 albedo_tex_hsv = rgb2hsv(albedo_tex.rgb);
		albedo_tex_hsv.z += base_brightness;
		ALBEDO = hsv2rgb(albedo_tex_hsv);
	}
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	//METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	NORMAL_MAP = texture(texture_normal,base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
	
	vec3 base_emission_hsv = rgb2hsv(texture(texture_base_emission,base_uv).rgb);
	base_emission_hsv.x += lights_hue;
	base_emission_hsv.y *= lights_saturation;
	base_emission_hsv.z *= lights_brightness;
	vec3 base_emission_tex = hsv2rgb(base_emission_hsv);
	vec3 weapon_emission_hsv = rgb2hsv(texture(texture_weapon_emission,base_uv).rgb);
	weapon_emission_hsv.x += weapon_hue;
	weapon_emission_hsv.y *= weapon_saturation;
	vec3 weapon_emission_tex = hsv2rgb(weapon_emission_hsv);
	
	vec3 engine_emission_tex = texture(texture_engine_emission,base_uv).rgb;
	
	EMISSION = albedo_tex.rgb * 6.0;
	EMISSION = (
		base_emission_tex * base_emission_factor +
		weapon_emission_tex * weapon_emission_factor +
		engine_emission_tex * engine_emission_factor
	)*emission_energy;
	
}
