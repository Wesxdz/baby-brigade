extends Node

var item_data

func _on_setup_spawn(item):
	$"../quad".material_override.albedo_texture = item.icon
	item_data = item
