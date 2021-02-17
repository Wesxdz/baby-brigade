extends Spatial


# Declare member variables here. Examples:
export(NodePath) var banner
var target_fov : float
var target_pos : Vector3

func _physics_process(delta):
	if has_node(banner):
#		target_fov = 40.0 + get_node(sled).linear_velocity.length()/10.0
		target_pos = get_node(banner).translation
		var circle = Vector2(target_pos.x, target_pos.z).normalized() * 152.789
		var adjust_pos = Vector3(circle.x, target_pos.y, circle.y)
		translation = translation.linear_interpolate(adjust_pos, delta * 4.0)
#	var t = delta
#	$"peak_rotator".sled_push = get_node(sled).rotation * 40.0
#	$"peak_rotator/cam".fov = $"peak_rotator/cam".fov + (target_fov - $"peak_rotator/cam".fov) * t
