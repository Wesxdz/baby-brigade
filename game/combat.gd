extends Area

export var resolve : float
signal won(other)
signal evaluate(other)
signal lost(other)
export var item_pickup_fx_prefab : PackedScene

func _on_combat_area_entered(area):
	if area.is_in_group("combat"):
		emit_signal("evaluate", area)
		if rand_range(0.0, resolve) > rand_range(0.0, area.resolve):
			emit_signal("won", area)
			area.emit_signal("lost", self)
		else:
			emit_signal("lost", area)
			area.emit_signal("won", self)
	elif area.is_in_group("resource"):
		if not area.pickedUp:
			var pickup = item_pickup_fx_prefab.instance()
			pickup.get_child(0).set_stream(area.get_node("../../item_resource").item_data.pickup_sfx)
			$"/root".add_child(pickup)
			$"/root/inventory".change_resource(area.get_node("../../item_resource").item_data.id, 1)
			area.get_parent().get_parent().queue_free()
			area.pickedUp = true
