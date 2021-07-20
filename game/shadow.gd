extends MeshInstance

export var shadows = []
export var step = 0.0

func height_to_opacity(var height):
	return min(1.0, 0.7 + height * 0.01)

func _process(delta):
	var height = get_parent().height
	transform.origin = Vector3(0.0, -height + 1.0, 0.0)
	var index = min(shadows.size() - 1, floor(height/step))
	material_override.set_texture(0, shadows[index])
	material_override.set_albedo(Color(1.0, 1.0, 1.0, height_to_opacity(height)))
