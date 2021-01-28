extends CPUParticles2D

var timer = 0.0
var despawn_time = 2.0

func _process(delta):
	timer += delta
	if timer >= despawn_time:
		queue_free()
