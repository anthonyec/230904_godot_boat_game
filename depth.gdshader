shader_type spatial;
uniform sampler2D depth_texture: hint_depth_texture;

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).r;
	
	depth = depth * 2.0 - 1.0;
	depth = pow(depth, 6.0);
	
	ALBEDO = vec3(-depth);
}
