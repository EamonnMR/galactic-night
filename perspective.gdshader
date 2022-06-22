shader_type spatial;
// render_mode unshaded;
const float S = 0.9;
uniform vec3 camera_position;

void vertex() {
	//https://discord.com/channels/212250894228652034/408555922349359105/988915027035693186
	mat4 my_special_projection = mat4(
		vec4(S,0,0,0),
		vec4(0,S,0,0),
		vec4(0,0,1,-1),
		vec4(0,0,0,1)
	);
	vec4 tmpvertex = (my_special_projection * vec4(VERTEX, 1));
	VERTEX = tmpvertex.xyz / tmpvertex.w;
}
