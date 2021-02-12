extends NinePatchRect

var selected_item = -1

func _enter_tree():
	$"/root/inventory".connect("item_amount_changed", self, "update_change")
	resize()
	get_node("/root").connect("size_changed", self, "resize")

func resize():
	rect_position = Vector2(0.0, -50 * $"/root/pixel".snap)
	rect_scale = $"/root/pixel".snap_scale

func popup(var item):
	selected_item = item.id
	self_modulate = item.outline_color
	$popup.self_modulate = item.outline_color
	$cost.self_modulate = item.text_color
	update_count_text()
	
func update_count_text():
	var item_count = str($"/root/inventory".get_stock(selected_item))
	margin_right = 29 + len(item_count) * 15
	$cost.bbcode_text = "[center]" + item_count + "[/center]"
	
func update_change(item, amount):
	if item as int == selected_item:
		update_count_text()
