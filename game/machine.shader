shader_type canvas_item;

uniform sampler2D background;
uniform sampler2D item;

void fragment()
{
	vec4 item_tex = texture(item, UV);
	COLOR = item_tex * item_tex.a + texture(background, UV) * (1.0 - item_tex.a);
}