extends TextureRect

func _ready():
	rect_scale = $"/root/pixel".snap_scale
	$"/root/pixel".connect("snap_changed", self, "_on_pixel_snap_changed")
	
func _on_pixel_snap_changed():
	rect_scale = $"/root/pixel".snap_scale
