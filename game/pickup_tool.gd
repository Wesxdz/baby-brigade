extends Area

var career_begin_fx_prefab = preload("res://career_begin_fx.tscn")
export var career_anim : AnimatedTexture
var canPickup = true

func _on_pickup_area_entered(area):
	if area.is_in_group("baby") and canPickup:
		area.get_node("../baby_quad/career").visible = true
		area.get_node("../baby_quad/career").material_override.albedo_texture = career_anim
		var fx = career_begin_fx_prefab.instance()
		$"/root".add_child(fx)
		get_parent().get_parent().queue_free()
		canPickup = false
