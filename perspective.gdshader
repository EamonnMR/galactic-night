shader_type spatial;
uniform mat4 xform;
uniform mat4 inv_xform;
uniform mat4 cam_xform;
uniform mat4 inv_cam_xform;
uniform float S = 0.5;

void vertex() {
	//https://discord.com/channels/212250894228652034/408555922349359105/988915027035693186
	
	mat4 my_special_projection = mat4(
		vec4(1,0,0,0),
		vec4(0,1,0,0),
		vec4(0,0,1,-S),
		vec4(0,0,0,1)
	);
	vec4 tmpvertex = vec4(VERTEX, 1);
	
	tmpvertex = inv_xform * tmpvertex;
	
	tmpvertex = inv_cam_xform * tmpvertex;

	tmpvertex = my_special_projection * tmpvertex;

	tmpvertex = cam_xform * tmpvertex;

	tmpvertex = xform * tmpvertex;
	
	VERTEX = tmpvertex.xyz / tmpvertex.w;
}
