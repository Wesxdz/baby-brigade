extends Spatial

export var idle : AnimatedTexture
export var walk : AnimatedTexture

func start_idle():
	$"../baby_quad/baby_quad".material_override.set_shader_param("image", idle)

func start_walk():
	$"../baby_quad/baby_quad".material_override.set_shader_param("image", walk)
	
