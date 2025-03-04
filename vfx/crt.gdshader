shader_type canvas_item;

uniform float curvature = 7;
uniform float scan_lines_frequency = 720.0;
uniform float scan_lines_alpha = .25;
uniform float scan_lines_brightening = .25;
uniform sampler2D screen_texture: hint_screen_texture;


void fragment() {
	// curvature
	vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
	vec2 uv_offset = centered_uv.yx / curvature;
	vec2 warped_uv = centered_uv + centered_uv * uv_offset * uv_offset;
	vec3 cutoff = vec3(step(abs(warped_uv.x), 1.0) * step(abs(warped_uv.y), 1.0));

	// scan lines
	vec3 scan_lines = vec3(sin(warped_uv.y * scan_lines_frequency)) * scan_lines_alpha + scan_lines_brightening;

	vec3 screen_color = texture(screen_texture, (warped_uv + 1.0) / 2.0).rgb * cutoff * scan_lines;
	COLOR = vec4(screen_color, 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
