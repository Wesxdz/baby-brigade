extends Node

var basis : Vector2
var snap : float
var snap_scale : Vector2
signal snap_changed

func _enter_tree():
	basis = Vector2(320, 480) # iPhone 1
	resize()
	get_node("/root").connect("size_changed", self, "resize")
	
func resize():
	var prev_snap : float = snap
	snap = max(1.0, round(OS.get_window_safe_area().size.length()/basis.length()))
	snap_scale = Vector2(snap, snap)
	if prev_snap != snap:
		emit_signal("snap_changed")
