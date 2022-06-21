shader_type spatial;
// render_mode unshaded;
const float DEPTH_FACTOR = 0.9;
uniform vec3 mesh_position;
uniform vec3 camera_position = vec3(-1,-1,-1);

void vertex() {
	//https://discord.com/channels/212250894228652034/408555922349359105/988915027035693186
	mat4 my_special_projection = mat4(
		vec4(),
		vec4(),
		vec4(),
		vec4()
	);
	vec4 tmpvertex = (my_special_projection * vec4(VERTEX, 1));
	VERTEX = tempvertex.xyz / tempvertex.w;
}
