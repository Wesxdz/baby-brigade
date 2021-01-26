extends Control

# Scale children nodes based on native screen resolution
var start_size
var hud_scale

func _enter_tree():
	start_size = Vector2(393, 786)
	print(OS.get_window_safe_area())
	print(OS.window_size)
	resize()
	get_node("/root").connect("size_changed", self, "resize")

func resize():
	set_size(get_node("/root").size)
	var snap = max(1.0, round(get_rect().size.length()/start_size.length())) + 1
	hud_scale = Vector2(snap, snap)
	print(hud_scale)
	$recipe.rect_scale = hud_scale
	$top.rect_scale = Vector2(1.0, hud_scale.y)
	$top/right.rect_scale = Vector2(hud_scale.x, 1.0)
	$top/left.rect_scale = Vector2(hud_scale.x, 1.0)
	$canvas/matrix/work/zone/items.rect_scale = hud_scale
	$canvas/matrix/work/zone/selection.rect_scale = hud_scale
	$smoke/viewport.size = OS.window_size/hud_scale
	$select/viewport.size = OS.window_size/hud_scale
#	$matrix.rect_scale = Vector2(1.0, hud_scale.y + 1)
#	$matrix/craft.rect_scale = Vector2(hud_scale.x + 1, 1.0)
