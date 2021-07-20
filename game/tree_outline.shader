shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D image;
uniform float trans;

// https://github.com/godotengine/godot/issues/25142 GLES3 requires manual color change
vec3 adjust_rgb(vec3 color){
	return mix(pow((color + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),color * (1.0 / 12.92),lessThan(color,vec3(0.04045)));
}

void vertex()
{
	VERTEX.y -= pow(abs(VERTEX.x), 1.4) * 0.1 + (float(VERTEX.z < 30.0) * sin(TIME * 8.0 * (VERTEX.z/100.0)) * 50.0 *  texture(image, UV).g) + (float(VERTEX.z < 0.0) * pow(abs(VERTEX.z), 1.4) * 0.1);
}

void fragment()
{
	vec4 original_color = texture(image, UV);
	vec3 color = adjust_rgb(original_color.xyz);
	ALBEDO = color;
	
	ALPHA = original_color.w * trans;
}