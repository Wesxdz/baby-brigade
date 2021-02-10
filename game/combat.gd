extends Area

export var resolve : float
signal won(other)
signal evaluate(other)
signal lost(other)

func _on_combat_area_entered(area):
	if area.is_in_group("combat"):
		emit_signal("evaluate", area)
		if rand_range(0.0, resolve) > rand_range(0.0, area.resolve):
			emit_signal("won", area)
			area.emit_signal("lost", self)
		else:
			emit_signal("lost", area)
			area.emit_signal("won", self)
