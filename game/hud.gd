extends Control

func _enter_tree():
	resize()
	get_node("/root").connect("size_changed", self, "resize")

func resize():
	set_size(get_node("/root").size)
	var hud_scale = $"/root/pixel".snap_scale
	$canvas/matrix/work/zone/items.rect_scale = hud_scale
	$canvas/matrix/work/zone/selection.rect_scale = hud_scale
	$smoke/viewport.size = OS.window_size/hud_scale
	$select/viewport.size = OS.window_size/hud_scale
