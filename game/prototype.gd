extends Spatial

var drop = preload("res://drop.tscn")

func _on_interact_body_entered(body):
	pass
#	var camera = $"/root/nodes/gameplay/hill/target/peak_rotator/cam"
#	var pos = camera.unproject_position(body.get_global_transform().origin)
##	print($"/root/nodes/box/ui".size)
#	var ratio = $"/root/nodes/box/ui".size/OS.window_size
#	for i in range(rand_range(1, round(body.scale.x))):
#		var resource = drop.instance()
#		resource.position = pos * ratio
#		$"/root/nodes/box/ui/hud".add_child(resource);
#	body.queue_free()
