shader_type canvas_item;
//render_mode blend_add;

uniform sampler2D repeating_tiles;
uniform float scroll_x_speed = 0.1;
uniform float scroll_y_speed = 0.1;
uniform int repeat_uv_count = 10;

void fragment()
{
  COLOR = texture(repeating_tiles, vec2(mod(UV.x + 1.0 + cos(TIME) * scroll_x_speed, 1.0f) * float(repeat_uv_count), mod(UV.y + TIME * scroll_y_speed, 1.0f) * float(repeat_uv_count)));
}