extends Control

# Scale children nodes based on native screen resolution
var hud_scale

func _enter_tree():
	resize()
	get_node("/root").connect("size_changed", self, "resize")

func resize():
	set_size(get_node("/root").size)
	hud_scale = $"/root/pixel".snap_scale
	$top.rect_scale = Vector2(1.0, hud_scale.y)
	$top/right.rect_scale = Vector2(hud_scale.x, 1.0)
	$top/left.rect_scale = Vector2(hud_scale.x, 1.0)
	$canvas/matrix/work/zone/items.rect_scale = hud_scale
	$canvas/matrix/work/zone/selection.rect_scale = hud_scale
	$smoke/viewport.size = OS.window_size/hud_scale
	$select/viewport.size = OS.window_size/hud_scale
#	$matrix.rect_scale = Vector2(1.0, hud_scale.y + 1)
#	$matrix/craft.rect_scale = Vector2(hud_scale.x + 1, 1.0)
