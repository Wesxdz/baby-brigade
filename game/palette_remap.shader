shader_type spatial;
render_mode unshaded;

uniform sampler2D image;
uniform sampler2D palette;
uniform float v_map;

// https://github.com/godotengine/godot/issues/25142 GLES3 requires manual color change
vec3 adjust_rgb(vec3 color){
	return mix(pow((color + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),color * (1.0 / 12.92),lessThan(color,vec3(0.04045)));
}

void fragment()
{
	vec4 original_color = texture(image, UV);
	vec4 remapped_color = texture(palette, vec2(original_color.r, v_map));
	remapped_color.w = original_color.w;
	ALBEDO = adjust_rgb(remapped_color.rgb);
	ALPHA = remapped_color.w;
}