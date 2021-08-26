extends Control

func _on_jukebox_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
			print("Hit col!")
			get_node("view/machine/slots").slot_hit()
