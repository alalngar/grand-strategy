shader_type canvas_item;
render_mode blend_disabled;

uniform sampler2D lookup_texture;
uniform sampler2D color_texture;
uniform uvec4 selected_color;

const float a = 255.0 / 256.0;
const float b = 1.0 / 256.0 / 2.0;

void fragment() {
	vec2 texture_size = vec2(textureSize(lookup_texture, 0).xy);
	vec4 uv = texelFetch(lookup_texture, ivec2(UV.xy * texture_size), 0);
	COLOR = texelFetch(color_texture, ivec2(uv.xy * vec2(255.0)), 0);
	
	// convert float 0.0-1.0 value to int 0-255 value to then compare
	uvec4 color = uvec4(uint(round(uv.r * 255.0)), uint(round(uv.g * 255.0)), uint(round(uv.b * 255.0)), 255);
	if (color == selected_color) {
		COLOR = mix(COLOR, vec4(1.0, 1.0, 1.0, 1.0), 0.8);
	}
	
	// change all these to use texelFetch
	vec4 c1 = texture(lookup_texture, vec2(UV.x + TEXTURE_PIXEL_SIZE.x, UV.y));
	vec4 c2 = texture(lookup_texture, vec2(UV.x - TEXTURE_PIXEL_SIZE.x, UV.y));
	vec4 c3 = texture(lookup_texture, vec2(UV.x, UV.y + TEXTURE_PIXEL_SIZE.y));
	vec4 c4 = texture(lookup_texture, vec2(UV.x, UV.y - TEXTURE_PIXEL_SIZE.y));
	
	if (c1 != uv || c2 != uv || c3 != uv || c4 != uv) {
		COLOR = mix(COLOR, vec4(0.0, 0.0, 0.0, 1.0), 0.2);
	}
}
