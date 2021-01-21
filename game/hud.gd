extends Control

# Scale children nodes based on native screen resolution
var start_size
var hud_scale

func _enter_tree():
	start_size = get_rect().size
	resize()
	get_node("/root").connect("size_changed", self, "resize")

func resize():
	set_size(get_node("/root").size)
	var snap = max(1.0, round(get_rect().size.length()/start_size.length()))
	hud_scale = Vector2(snap, snap)
	$recipe.rect_scale = hud_scale
	$top.rect_scale = hud_scale
