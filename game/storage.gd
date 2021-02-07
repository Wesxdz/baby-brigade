extends NinePatchRect

func _enter_tree():
	resize()
	get_node("/root").connect("size_changed", self, "resize")

func resize():
	rect_position = Vector2(0.0, -50 * $"/root/pixel".snap)
	rect_scale = $"/root/pixel".snap_scale

func popup(var item):
	self_modulate = item.outline_color
	$popup.self_modulate = item.outline_color
	$cost.self_modulate = item.text_color
	var item_count = str($"/root/inventory".get_stock(item.id))
	margin_right = 29 + len(item_count) * 15
	$cost.bbcode_text = "[center]" + item_count + "[/center]"
