extends Button


func _on_exit_pressed():
	$"/root/nodes/start/foreground/start_game".hill.queue_free()
	$"/root/nodes/start/foreground/start_game".restart_menu()
