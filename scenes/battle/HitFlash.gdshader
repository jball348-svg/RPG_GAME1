shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0, 0.84, 0.78, 1.0);
uniform float flash_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 base_color = texture(TEXTURE, UV) * COLOR;
	vec3 flashed = mix(base_color.rgb, flash_color.rgb, flash_strength);
	COLOR = vec4(flashed, base_color.a);
}
