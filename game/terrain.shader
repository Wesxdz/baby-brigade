shader_type spatial;
render_mode unshaded, world_vertex_coords;

const float biomeTransitionSize = 0.0; // GDArcProcHill::biomeTransitionSize
uniform float startTransitionY = 0.0;
uniform sampler2D ramp_start;
uniform sampler2D ramp_end;
uniform sampler2D base_UV;
uniform sampler2D trans_UV;

const float PI = 3.14159265358979323846264338327950288419716939937510;

// https://github.com/godotengine/godot/issues/25142 GLES3 requires manual color change
vec3 adjust_rgb(vec3 color){
	return mix(pow((color + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),color * (1.0 / 12.92),lessThan(color,vec3(0.04045)));
}

varying vec3 world_pos;
//varying vec3 start_pos;

void vertex()
{
//	start_pos = (WORLD_MATRIX * vec4(0.0, startTransitionY, 0.0, 0.0)).xyz;
	world_pos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment()
{
	float numTiles = 4.0;
//	ALBEDO = vec3(float((int(UV.r * 2.0) % 2))/2.0);
//	float interp  = clamp((startY)/biomeTransitionSize, 0.0, 1.0);
//	float interp = clamp(-(start_pos.y - world_pos.y)/biomeTransitionSize, 0.0, 1.0) * float(startTransitionY == 0.0);
//	vec4 color = texture(ramp_start, UV) * (1.0 - interp) + texture(ramp_end, UV) * interp;
	vec2 tile = vec2(UV2.x/numTiles + float(int(UV.x * numTiles))/numTiles, UV2.y);
	vec4 color = texture(base_UV, tile);
// vec4 color = vec4(UV2.x, 0.0, UV2.y, 1.0); // debug
	float theta = atan(-world_pos.z, world_pos.x);
	float t = 32.0; // wrapped tile count
	float s = 16.0; // tile size
	float wrap = theta/(2.0 * PI) * t;
	float y_to_x = -world_pos.y/s - floor(-world_pos.y/s); // y_to_x + wrap
	vec4 base = texture(base_UV, tile);
	float together = y_to_x + (wrap - floor(wrap));
	float past = (wrap - floor(wrap));
	// TODO Pixel perfect circle wrapping
	// atan(-y_to_x, past)
	// sin(past) * cos(y_to_x)
	vec4 overlay = texture(trans_UV, vec2(past, 1.0 - UV.x ));
	overlay.a = 0.0; // TODO reimplement overlay once you have time!
//	vec4 color = overlay * overlay.a + base * (1.0 - overlay.a);
	ALBEDO = adjust_rgb(color.rgb);
//	ALPHA = color.a;
}