shader_type spatial;
render_mode unshaded, world_vertex_coords;

const float biomeTransitionSize = 0.0; // GDArcProcHill::biomeTransitionSize
uniform float startTransitionY = 0.0;
uniform sampler2D ramp_start;
uniform sampler2D ramp_end;
uniform sampler2D base_UV;
uniform sampler2D trans_UV;

const float PI = 3.14159265358979323846264338327950288419716939937510;

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
	vec2 tile = vec2(UV2.x/4.0 + float(int(UV.x * 4.0))/4.0, UV2.y);
//	vec4 color = texture(base_UV, tile);
//	vec4 color = vec4(UV2.x, 0.0, UV2.y, 1.0); // debug
	float theta = atan(-world_pos.z, world_pos.x);
	float t = 32.0; // wrapped tile count
	float s = 16.0; // tile size
	float wrap = theta/(2.0 * PI) * t;
	float y_to_x = -world_pos.y/s - floor(-world_pos.y/s); // y_to_x + wrap
	vec4 base = texture(base_UV, tile);
	float together = y_to_x + (wrap - floor(wrap));
	vec4 overlay = texture(trans_UV, vec2((wrap - floor(wrap)), 1.0 - ( UV.x * 4.0 - floor(UV.x * 4.0)) ));
	vec4 color = overlay * overlay.a + base * (1.0 - overlay.a);
	ALBEDO = vec3(color.r, color.g, color.b);
//	ALPHA = color.a;
}