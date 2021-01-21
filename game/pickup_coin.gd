extends Area

var drop = preload("res://resource_drop.tscn")

func _on_pickup_area_entered(area):
#	print("Pickup coin!")
	var camera = $"/root/nodes/gameplay/hill/target/peak_rotator/cam"
	var pos = camera.unproject_position(area.get_global_transform().origin)
#	print($"/root/nodes/box/ui".size)
	for i in range(rand_range(1, round(area.scale.x))):
		var resource = drop.instance()
		resource.position = pos
		$"/root/nodes/hud".add_child(resource);
	get_parent().queue_free()
