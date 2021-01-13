extends Spatial

# Snow affector
export(float) var snow_radius
var snow
var distance_between_samples = 1.0
var last_sample_pos = Vector3.ZERO

#func init(terrain):
#	snow = terrain;
#	last_sample_pos = get_global_transform().origin
#
#func _process(delta):
#	if snow == null: return
#	var sample_dist = (last_sample_pos - get_global_transform().origin).length()
#	if sample_dist >= distance_between_samples:
#		snow.add_sample(get_global_transform().origin, snow_radius)
#		last_sample_pos = get_global_transform().origin
