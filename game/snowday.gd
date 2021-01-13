extends MeshInstance

export (Color) var snow_color;
export (Color) var compressed_color;

#func _process(delta):
#	mesh.surface_get_material(0).set_shader_param("snow_color", Vector3(snow_color.r, snow_color.g, snow_color.b))
#	mesh.surface_get_material(0).set_shader_param("compressed_color", Vector3(compressed_color.r, compressed_color.g, compressed_color.b))
