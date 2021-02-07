extends Node

func _on_setup_spawn(item):
	$"../quad".material_override.albedo_texture = item.icon
