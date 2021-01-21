shader_type spatial;
render_mode unshaded;

uniform sampler2D image;
uniform sampler2D palette;
uniform float v_map;

void fragment()
{
	vec4 original_color = texture(image, UV);
	vec4 remapped_color = texture(palette, vec2(original_color.r, v_map));
	remapped_color.w = original_color.w;
	ALBEDO = remapped_color.xyz;
	ALPHA = remapped_color.w;
}