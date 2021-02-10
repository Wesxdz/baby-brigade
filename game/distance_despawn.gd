extends Node

export var despawn_distance = 200.0

func _process(delta):
	if get_parent().get_y_pos() > $"../../banner".get_y_pos() + despawn_distance:
		get_parent().queue_free()
