// NOTE: Shader automatically converted from Godot Engine 3.5.stable's SpatialMaterial.

shader_type spatial;
render_mode async_visible,blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform sampler2D texture_metallic : hint_white;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_white;
uniform vec4 roughness_texture_channel;
uniform sampler2D texture_normal : hint_normal;
uniform float normal_scale : hint_range(-16,16);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform mat4 xform;
uniform mat4 inv_xform;
uniform float perspective_correct = 0.5;

uniform sampler2D texture_base_emission : hint_black_albedo;
uniform sampler2D texture_engine_emission : hint_black_albedo;
uniform sampler2D texture_weapon_emission : hint_black_albedo;


uniform vec4 emission : hint_color;
uniform float emission_energy;


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
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	NORMALMAP = texture(texture_normal,base_uv).rgb;
	NORMALMAP_DEPTH = normal_scale;
	
	vec3 base_emission_tex = texture(texture_base_emission,base_uv).rgb;
	vec3 weapon_emission_tex = texture(texture_weapon_emission,base_uv).rgb;
	vec3 engine_emission_tex = texture(texture_engine_emission,base_uv).rgb;
	
	
	EMISSION = (
		emission.rgb+
		base_emission_tex+
		weapon_emission_tex+
		engine_emission_tex
	)*emission_energy;
}
