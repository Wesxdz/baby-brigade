extends Node


func _on_combat_lost(other):
	get_parent().queue_free()
