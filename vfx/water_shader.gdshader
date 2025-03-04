shader_type canvas_item;

uniform vec4 color : source_color;
uniform float color_strength = .5;
uniform sampler2D fast_noise : repeat_enable;
uniform sampler2D screen_content : hint_screen_texture;
uniform vec2 speed = vec2(0.03, 0.07);
uniform float wave_strength = 2;
uniform vec2 displacement = vec2(0.0, 0.0);
uniform vec2 scale = vec2(1.0, 1.0);

void fragment() {
    vec2 uv = displacement + scale * UV + speed * TIME;
	vec2 noise = texture(fast_noise, uv).rg;
	COLOR = mix(vec4(color.r, color.g, color.b, 1), vec4(noise.x, noise.y, 1, 1), color_strength);
	COLOR *= texture(screen_content, SCREEN_UV + noise * (wave_strength / 100.0));
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
}
