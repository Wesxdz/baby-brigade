extends Node

var smoke_fx = preload("res://box_particles.tscn")
var baby_prefab = preload("res://baby.tscn")
var land_sfx = preload("res://babybox_land.tscn")

func _on_drop_landed():
	var spawn_pos = get_parent().transform.origin
	var smoke = smoke_fx.instance()
	smoke.emitting = true
	smoke.position = get_viewport().get_camera().unproject_position(spawn_pos)/$"/root/pixel".snap
	get_node("/root/nodes/hud/smoke/viewport").add_child(smoke)
	var land = land_sfx.instance()
	$"/root/inventory".add_child(land)
	for i in range(0, ceil(rand_range(1, 5))):
		var baby = baby_prefab.instance()
		get_node("/root/nodes/gameplay/hill").add_child(baby)
		baby.set_translation(spawn_pos + Vector3(spawn_pos.normalized().x, i, spawn_pos.normalized().z) )
	get_parent().queue_free()
