shader_type canvas_item;
render_mode blend_disabled;

uniform sampler2D lookup_texture;
uniform sampler2D color_texture;
uniform uvec4 selected_color;

void fragment() {
	vec2 tex_size = vec2(textureSize(lookup_texture, 0).xy);
	vec4 l_color = texelFetch(lookup_texture, ivec2(UV.xy * tex_size), 0);
	vec4 c_color = texelFetch(color_texture, ivec2(l_color.xy * vec2(255.0)), 0);
	COLOR = c_color;
	
	uvec4 ul_color = uvec4(l_color.rgba * 255.0);
	if (ul_color == selected_color) {
		COLOR = mix(COLOR, vec4(1.0, 1.0, 1.0, 1.0), 0.75);
	}
	
	vec4 lr_border = texelFetch(lookup_texture, ivec2(UV.xy * tex_size.xy) + ivec2(1, 0), 0);
	vec4 ll_border = texelFetch(lookup_texture, ivec2(UV.xy * tex_size.xy) - ivec2(1, 0), 0);
	vec4 ld_border = texelFetch(lookup_texture, ivec2(UV.xy * tex_size.xy) + ivec2(0, 1), 0);
	vec4 lu_border = texelFetch(lookup_texture, ivec2(UV.xy * tex_size.xy) - ivec2(0, 1), 0);
	
	vec4 cr_border = texelFetch(color_texture, ivec2(lr_border.xy * 255.0), 0);
	vec4 cl_border = texelFetch(color_texture, ivec2(ll_border.xy * 255.0), 0);
	vec4 cd_border = texelFetch(color_texture, ivec2(ld_border.xy * 255.0), 0);
	vec4 cu_border = texelFetch(color_texture, ivec2(lu_border.xy * 255.0), 0);
	
	if (cr_border != c_color || cl_border != c_color || cd_border != c_color || cu_border != c_color) {
		COLOR = mix(COLOR, vec4(0.0, 0.0, 0.0, 1.0), 0.4);
	} else if (lr_border != l_color || ll_border != l_color || ld_border != l_color || lu_border != l_color) {
		COLOR = mix(COLOR, vec4(0.0, 0.0, 0.0, 1.0), 0.15);
	}
}
