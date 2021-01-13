extends Spatial

func _process(delta):
	set_rotation(Vector3(0.0, atan2(global_transform.origin.x, global_transform.origin.z), 0.0))
