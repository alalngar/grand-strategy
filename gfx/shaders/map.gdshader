shader_type canvas_item;
render_mode blend_disabled;

uniform sampler2D lookup_texture;
uniform sampler2D color_texture;
uniform uvec4 selected_color;


void fragment() {
	vec2 texture_size = vec2(textureSize(lookup_texture, 0).xy);
	vec4 uv = texelFetch(lookup_texture, ivec2(UV.xy * texture_size), 0);
	vec4 country_color = texelFetch(color_texture, ivec2(uv.xy * vec2(255.0)), 0);
	COLOR = country_color;
	
	uvec4 color = uvec4(uv.rgba * 255.0);
	if (color == selected_color) {
		COLOR = mix(COLOR, vec4(1.0, 1.0, 1.0, 1.0), 0.75);
	}
	
	// for later
	vec2 cborder_width = TEXTURE_PIXEL_SIZE.xy;
	vec2 pborder_width = TEXTURE_PIXEL_SIZE.xy;
	
	vec4 _cb1 = texelFetch(lookup_texture, ivec2(vec2((UV.x + cborder_width.x) * texture_size.x, UV.y * texture_size.y)), 0);
	vec4 cb1 = texelFetch(color_texture, ivec2(_cb1.xy * vec2(255.0)), 0);
	vec4 _cb2 = texelFetch(lookup_texture, ivec2(vec2((UV.x - cborder_width.x) * texture_size.x, UV.y * texture_size.y)), 0);
	vec4 cb2 = texelFetch(color_texture, ivec2(_cb2.xy * vec2(255.0)), 0);
	vec4 _cb3 = texelFetch(lookup_texture, ivec2(vec2(UV.x * texture_size.x, (UV.y + cborder_width.y) * texture_size.y)), 0);
	vec4 cb3 = texelFetch(color_texture, ivec2(_cb3.xy * vec2(255.0)), 0);
	vec4 _cb4 = texelFetch(lookup_texture, ivec2(vec2(UV.x * texture_size.x, (UV.y - cborder_width.y) * texture_size.y)), 0);
	vec4 cb4 = texelFetch(color_texture, ivec2(_cb4.xy * vec2(255.0)), 0);
	if (cb1 != country_color || cb2 != country_color || cb3 != country_color || cb4 != country_color) {
		COLOR = mix(COLOR, vec4(0.0, 0.0, 0.0, 1.0), 0.4);
	} else {
		vec4 pb1 = texelFetch(lookup_texture, ivec2(vec2((UV.x + pborder_width.x) * texture_size.x, UV.y * texture_size.y)), 0);
		vec4 pb2 = texelFetch(lookup_texture, ivec2(vec2((UV.x - pborder_width.x) * texture_size.x, UV.y * texture_size.y)), 0);
		vec4 pb3 = texelFetch(lookup_texture, ivec2(vec2(UV.x * texture_size.x, (UV.y + pborder_width.y) * texture_size.y)), 0);
		vec4 pb4 = texelFetch(lookup_texture, ivec2(vec2(UV.x * texture_size.x, (UV.y - pborder_width.y) * texture_size.y)), 0);
		if (pb1 != uv || pb2 != uv || pb3 != uv || pb4 != uv) {
			COLOR = mix(COLOR, vec4(0.0, 0.0, 0.0, 1.0), 0.15);
		}
	}
}
