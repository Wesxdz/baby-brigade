extends Node

var fight_fx_prefab = preload("res://fight_sfx.tscn")

func _on_combat_lost(other):
	if rand_range(0, 2) > 1:
		$"../anim".play("baby_defeated_right")
	else:
		$"../anim".play("baby_defeated_left")
	$"../combat".monitoring = false
	$"../combat".monitorable = false
	get_parent().leave_boid_field()
#	$"../boid_repel".free()

func complete_despawn():
	get_parent().queue_free()

func _on_combat_evaluate(other):
	var fight = fight_fx_prefab.instance()
	$"/root/".add_child(fight)
