shader_type canvas_item;

uniform sampler2D lookup_texture;
uniform sampler2D color_texture;

uniform uvec4 selected_color;

void fragment() {
	vec4 uv = texture(lookup_texture, UV);
	COLOR = texture(color_texture, uv.xy * 255.0 / 256.0 + vec2(0.001953125, 0.001953125));
	
	// convert float 0.0-1.0 value to int 0-255 value to then compare
	uvec4 color = uvec4(uint(round(uv.r * 255.0)), uint(round(uv.g * 255.0)), uint(round(uv.b * 255.0)), 255);
	if (color == selected_color) {
		COLOR = mix(COLOR, vec4(1.0, 1.0, 1.0, 1.0), 0.8);
	}
	
	vec4 c1 = texture(lookup_texture, vec2(UV.x + TEXTURE_PIXEL_SIZE.x, UV.y));
	vec4 c2 = texture(lookup_texture, vec2(UV.x - TEXTURE_PIXEL_SIZE.x, UV.y));
	vec4 c3 = texture(lookup_texture, vec2(UV.x, UV.y + TEXTURE_PIXEL_SIZE.y));
	vec4 c4 = texture(lookup_texture, vec2(UV.x, UV.y - TEXTURE_PIXEL_SIZE.y));
	
	if (c1 != uv || c2 != uv || c3 != uv || c4 != uv) {
		COLOR = mix(COLOR, vec4(0.0, 0.0, 0.0, 1.0), 0.25);
	}
}
