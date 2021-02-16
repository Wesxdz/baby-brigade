shader_type spatial;
render_mode unshaded, world_vertex_coords;

const float biomeTransitionSize = 0.0; // GDArcProcHill::biomeTransitionSize
uniform float startTransitionY = 0.0;
uniform sampler2D ramp_start;
uniform sampler2D ramp_end;

varying vec3 world_pos;
//varying vec3 start_pos;

void vertex()
{
//	start_pos = (WORLD_MATRIX * vec4(0.0, startTransitionY, 0.0, 0.0)).xyz;
	world_pos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment()
{
//	ALBEDO = vec3(float((int(UV.r * 4.0) % 4))/4.0);
//	float interp  = clamp((startY)/biomeTransitionSize, 0.0, 1.0);
//	float interp = clamp(-(start_pos.y - world_pos.y)/biomeTransitionSize, 0.0, 1.0) * float(startTransitionY == 0.0);
//	vec4 color = texture(ramp_start, UV) * (1.0 - interp) + texture(ramp_end, UV) * interp;
	vec4 color = texture(ramp_start, UV);
	ALBEDO = vec3(color.r, color.g, color.b);
}