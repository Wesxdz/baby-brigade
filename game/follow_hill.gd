extends Spatial


# Declare member variables here. Examples:
export(NodePath) var sled
var target_fov : float
var target_pos : Vector3

func _physics_process(delta):
	if has_node(sled):
#		target_fov = 40.0 + get_node(sled).linear_velocity.length()/10.0
		target_pos = get_node(sled).translation
	translation = translation.linear_interpolate(target_pos, delta * 4.0)
#	var t = delta
#	$"peak_rotator".sled_push = get_node(sled).rotation * 40.0
#	$"peak_rotator/cam".fov = $"peak_rotator/cam".fov + (target_fov - $"peak_rotator/cam".fov) * t
