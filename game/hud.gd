extends Control

# Scale children nodes based on native screen resolution
var start_size

func _enter_tree():
	start_size = get_rect().size
	resize()
	get_node("/root").connect("size_changed", self, "resize")

func resize():
	set_size(get_node("/root").size)
	var snap = max(1.0, round(get_rect().size.length()/start_size.length()))
	var scale = Vector2(snap, snap)
	$recipe.rect_scale = scale
	$top.rect_scale = scale
