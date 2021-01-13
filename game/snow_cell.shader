shader_type spatial;
render_mode unshaded;

uniform sampler2D ramp;

void vertex()
{
	
}

void fragment()
{
//	ALBEDO = vec3(float((int(UV.r * 4.0) % 4))/4.0);
	vec4 color = texture(ramp, UV);
	ALBEDO = vec3(color.r, color.g, color.b);
}