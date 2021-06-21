extends Panel

var time = 0.0

func _process(delta):
	time = time + delta
	if time >= 1.0:
		visible = false
