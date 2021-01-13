extends Button

func _on_replay_pressed():
	var hill = $"/root/nodes/box/ui/start/foreground/start_game".hill
	hill.queue_free()
	$"/root/nodes/box/ui/start/foreground/start_game".restart()
	$"/root".remove_child(hill)
