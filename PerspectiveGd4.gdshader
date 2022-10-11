// NOTE: Shader automatically converted from Godot Engine 4.0.beta1's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_nearest,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_nearest,repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_nearest,repeat_enable;
uniform float specular;
uniform float metallic;
uniform sampler2D texture_emission : source_color, hint_default_black,filter_nearest,repeat_enable;
uniform vec4 emission : source_color;
uniform float emission_energy;
uniform sampler2D texture_normal : hint_roughness_normal,filter_nearest,repeat_enable;
uniform float normal_scale : hint_range(-16,16);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform mat4 xform;
uniform mat4 inv_xform;
uniform float perspective_correct = 0.5;


void vertex() {
	//https://discord.com/channels/212250894228652034/408555922349359105/988915027035693186
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	
	mat4 reflection = mat4(
		vec4(-1, 0, 0, 0),
		vec4(0, 1, 0, 0),
		vec4(0, 0, -1, 0),
		vec4(0, 0, 0, 1)
	);
	
	mat4 projection = mat4(
		vec4(1,0,0,0),
		vec4(0,1,0,0),
		vec4(0,0,1,-perspective_correct),
		vec4(0,0,0,1)
	);
	vec4 tmpvertex = vec4(VERTEX, 1);
	
	tmpvertex = 
		inv_xform *
		projection *
		xform *
		reflection *
		tmpvertex;
	
	VERTEX = tmpvertex.xyz / tmpvertex.w;
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	NORMAL_MAP = texture(texture_normal,base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
	vec3 emission_tex = texture(texture_emission,base_uv).rgb;
	EMISSION = (emission.rgb+emission_tex)*emission_energy;
}
