extends Button


func _on_exit_pressed():
	$"/root/nodes/box/ui/start/foreground/start_game".hill.queue_free()
	$"/root/nodes/box/ui/start/foreground/start_game".restart_menu()
