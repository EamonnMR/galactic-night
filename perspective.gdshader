shader_type spatial;
render_mode unshaded;
const float DEPTH_FACTOR = 0.9;
uniform vec3 mesh_position;
uniform vec3 camera_position = vec3(-1,-1,-1);

void vertex() {
	VERTEX -= mesh_position;
	VERTEX -= camera_position;
	VERTEX.x = VERTEX.x * DEPTH_FACTOR;
	VERTEX.y = VERTEX.y * DEPTH_FACTOR;
	VERTEX += camera_position;
	VERTEX += mesh_position;
}
