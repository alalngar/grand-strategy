shader_type canvas_item;
render_mode blend_disabled;

uniform sampler2D lookup_texture;
uniform sampler2D color_texture;
uniform uvec4 selected_color;

void fragment() {
	vec2 texture_size = vec2(textureSize(lookup_texture, 0).xy);
	vec4 uv = texelFetch(lookup_texture, ivec2(UV.xy * texture_size), 0);
	COLOR = texelFetch(color_texture, ivec2(uv.xy * vec2(255.0)), 0);
	
	uvec4 color = uvec4(uint(round(uv.r * 255.0)), uint(round(uv.g * 255.0)), uint(round(uv.b * 255.0)), 255);
	if (color == selected_color) {
		COLOR = mix(COLOR, vec4(1.0, 1.0, 1.0, 1.0), 0.8);
	}
	
	vec4 c1 = texelFetch(lookup_texture, ivec2(vec2((UV.x + TEXTURE_PIXEL_SIZE.x) * texture_size.x, UV.y * texture_size.y)), 0);
	vec4 c2 = texelFetch(lookup_texture, ivec2(vec2((UV.x - TEXTURE_PIXEL_SIZE.x) * texture_size.x, UV.y * texture_size.y)), 0);
	vec4 c3 = texelFetch(lookup_texture, ivec2(vec2(UV.x * texture_size.x, (UV.y + TEXTURE_PIXEL_SIZE.y) * texture_size.y)), 0);
	vec4 c4 = texelFetch(lookup_texture, ivec2(vec2(UV.x * texture_size.x, (UV.y - TEXTURE_PIXEL_SIZE.y) * texture_size.y)), 0);
	if (c1 != uv || c2 != uv || c3 != uv || c4 != uv) {
		COLOR = mix(COLOR, vec4(0.0, 0.0, 0.0, 1.0), 0.2);
	}
}
