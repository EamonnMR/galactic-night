shader_type canvas_item;

uniform vec2 position;
uniform sampler2D nebula;
const int LAYERS = 5;
const float DEPTH_FACTOR = 0.7;
const float DEPTH_OFFSET = 0.0;

void fragment(){
	COLOR = vec4(0,0,0,0);
	vec2 shifted_uv_front = UV;
	for (int i = 1; i <= LAYERS; i ++){
		
		// Offset stars by player position
		vec2 shifted_uv = UV;
		shifted_uv.x += (
			position.x / (DEPTH_OFFSET + float(i) / DEPTH_FACTOR) * TEXTURE_PIXEL_SIZE.x
		);
		shifted_uv.y += (
			position.y / (DEPTH_OFFSET + float(i) / DEPTH_FACTOR) * TEXTURE_PIXEL_SIZE.y
		);

		// Extra offset to avoid stacking
		shifted_uv += (TEXTURE_PIXEL_SIZE * float(i) * 250.0);

		shifted_uv.x = fract(shifted_uv.x);
		shifted_uv.y = fract(shifted_uv.y);
		
		// Invert every other layer
		if(bool(i % 2)){
			shifted_uv.x = 1.0 - shifted_uv.x;
			shifted_uv.y = 1.0 - shifted_uv.y;
		}
		if(bool(i % 3)){
			if (shifted_uv.x > 1.0 || shifted_uv.y < 0.0 || shifted_uv.y > 1.0 || shifted_uv.y < 0.0){
				//COLOR = vec4(1,1,1,1)
			}
			COLOR += texture(nebula, shifted_uv) / (float(i) + 0.5)
		} else {
			COLOR += texture(TEXTURE, shifted_uv) / (float(i) + 0.5)
		}
	}
}
