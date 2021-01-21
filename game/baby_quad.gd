extends MeshInstance

func _ready():
	material_override.set_shader_param("v_map", (randi()%7)/6.0)
