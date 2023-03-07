vec3 adjust_for_perspective(vec3 vertex, float factor, mat4 mesh_transform, mat4 mesh_transform_inverted) {
	//https://discord.com/channels/212250894228652034/408555922349359105/988915027035693186
	
	mat4 reflection = mat4(
		vec4(-1, 0, 0, 0),
		vec4(0, 1, 0, 0),
		vec4(0, 0, -1, 0),
		vec4(0, 0, 0, 1)
	);
	
	mat4 projection = mat4(
		vec4(1,0,0,0),
		vec4(0,1,0,0),
		vec4(0,0,1,-factor),
		vec4(0,0,0,1)
	);
	vec4 tmpvertex = vec4(vertex, 1);
	
	tmpvertex = 
		mesh_transform_inverted *
		projection *
		mesh_transform *
		reflection *
		tmpvertex;
	
	return tmpvertex.xyz / tmpvertex.w;
}
