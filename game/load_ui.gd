extends Viewport

func _enter_tree():
	var menu_ui = preload("res://menu.tscn")
	var menu = menu_ui.instance()
	add_child(menu)


func _input(event):
	if $"menu/start".visible and event is InputEventScreenTouch:
		$"menu/start/foreground/start_game".start_game()
