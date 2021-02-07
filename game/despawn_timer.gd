extends AudioStreamPlayer

export var despawn_time = 5.0
var timer = 0.0

func _process(delta):
	timer += delta
	if timer >= despawn_time:
		queue_free()
