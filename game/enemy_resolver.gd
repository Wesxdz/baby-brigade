extends Node

signal despawn

func _on_combat_lost(other):
	emit_signal("despawn")
	get_parent().queue_free()
	# check if this is the last member of a banner group and if it is spawn loot at self origin
