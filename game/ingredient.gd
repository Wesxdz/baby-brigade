extends NinePatchRect

var prev
	
func _enter_tree():
	resize()
	get_node("/root").connect("size_changed", self, "resize")

func resize():
	margin_left = 4 * $"/root/pixel".snap
	margin_top = -16 * $"/root/pixel".snap
	margin_bottom = -4 * $"/root/pixel".snap
	rect_scale = $"/root/pixel".snap_scale

func setup(var item, var count):
	self_modulate = item.outline_color
	$cost.self_modulate = item.text_color
	$cost.text = str(count)
	$icon.texture = item.icon

func _process(delta):
	if prev:
		margin_left = prev.margin_left + (prev.rect_size.x + 4) * $"/root/pixel".snap
