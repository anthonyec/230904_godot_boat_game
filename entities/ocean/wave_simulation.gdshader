shader_type canvas_item;
render_mode blend_mix;

uniform vec2 direction = vec2(1.0, 0.0);
uniform float offset = 2.0;
uniform float amplitude = 0.1;
uniform float frequency = 1.0;

void fragment() {
	vec2 position = POINT_COORD;
	
	float displacement = dot(POINT_COORD, direction) * offset;
//	float wave = amplitude * sin(2.0 * PI * frequency * (FRAGCOORD.y + displacement));
	float wave = amplitude * sin(2.0 * PI * frequency * (SCREEN_UV.x + displacement));
	
	COLOR = vec4(vec3(wave), 1.0);
	
//	COLOR.rgb = vec3(dot_product, dot_product, 0.0);
}
