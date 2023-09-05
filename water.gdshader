shader_type spatial;
render_mode depth_draw_always;

uniform sampler2D wave;

uniform float wave_time = 0;
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.025;
uniform float wave_speed = 1;
uniform float noise_scale = 100;
uniform float height_scale = 1;

varying vec3 world_pos;
varying float height;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave, world_pos.xz / noise_scale + wave_time * wave_speed).r;
	VERTEX.y += height * height_scale;
}

void fragment() {
	vec4 pixel_color = texture(wave, world_pos.xz / noise_scale + wave_time * wave_speed);
	ALBEDO = pixel_color.rgb;
}
