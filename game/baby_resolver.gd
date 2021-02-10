extends Node

var fight_fx_prefab = preload("res://fight_sfx.tscn")

func _on_combat_lost(other):
	print("Baby lost combat!")
	get_parent().queue_free()


func _on_combat_evaluate(other):
	var fight = fight_fx_prefab.instance()
	$"/root/".add_child(fight)
