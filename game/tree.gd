extends Spatial

onready var field = get_node("/root/nodes/gameplay/boid_field")
export(int, FLAGS, "Baby, Obstacle, Item, Banner, Enemy, Foilage") var trans;

var target_transparency = 1.0
var transparency = 1.0

func _process(delta):
	var neighbors = field.get_neighbors(get_global_transform().origin, 64.0, trans)
	var found = false
	for neighbor in neighbors:
		var p = neighbor as Spatial
		if p.get_global_transform().origin.y > get_parent().get_global_transform().origin.y:
			target_transparency = 0.3
			found = true
			break
	if not found:
		target_transparency = 1
	transparency = transparency + (target_transparency - transparency) * min(1.0, delta * 2.0)
	$"../tree_mesh".material_override.set_shader_param("trans", transparency)
