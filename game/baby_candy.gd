extends CPUParticles2D

func _ready():
	resize()
	_on_pixel_snap_changed()
	$"/root/pixel".connect("snap_changed", self, "_on_pixel_snap_changed")
	get_node("/root").connect("size_changed", self, "resize")

func _on_pixel_snap_changed():
	scale_amount = $"/root/pixel".snap
	speed_scale = $"/root/pixel".snap
	transform.origin.y = -32 * $"/root/pixel".snap

func resize():
	transform.origin.x = OS.get_window_safe_area().position.x + OS.get_window_safe_area().size.x/2.0
	emission_rect_extents = Vector2(OS.get_window_safe_area().size.x/2.0, 1.0)
