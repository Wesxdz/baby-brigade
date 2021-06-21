shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled;

uniform sampler2D repeating_tiles;
uniform float scroll_x_speed = 0.0;
uniform float scroll_y_speed = 0.1;
uniform int repeat_u_count = 1;
uniform int repeat_v_count = 3;

varying vec2 tex_pos;

void vertex()
{
	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(CAMERA_MATRIX[0],CAMERA_MATRIX[1],CAMERA_MATRIX[2],WORLD_MATRIX[3]);
	tex_pos = VERTEX.xy;
}

void fragment()
{
	vec4 v = texture(repeating_tiles, vec2(mod(UV.x + 1.0 * scroll_x_speed, 1.0f) * float(repeat_u_count), mod(UV.y + TIME * scroll_y_speed, 1.0f) * float(repeat_v_count)));
//	vec4 v = texture(repeating_tiles, tex_pos);
	ALBEDO = v.xyz;
	ALPHA = v.w;
}