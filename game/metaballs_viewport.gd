extends Viewport

func _ready():
	size = OS.window_size/$"/root/pixel".snap_scale
