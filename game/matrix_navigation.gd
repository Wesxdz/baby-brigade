extends Panel

var dragging = false # drag matrix
var placing = false # place item in world
var itemDrop = preload("item_drop.tscn")
var drop
var mouse_pos
var spawn_offset = 0.0
var angle_offset = spawn_offset
var spawn_height = 0.0
var height_offset = spawn_height
var ground
var baby_prefab = preload("res://baby.tscn")
var smoke_fx = preload("res://box_particles.tscn")
var last_closest = null

func _input(event):
	if event is InputEventMouseButton:
		if placing and not event.pressed:
				angle_offset = spawn_offset 
				height_offset = spawn_height
#				$"../purchase".play()
				var smoke = smoke_fx.instance()
				smoke.emitting = true
				smoke.position = get_viewport().get_camera().unproject_position((ground.position))/$"/root/nodes/hud".hud_scale.x
				get_node("/root/nodes/hud/smoke/viewport").add_child(smoke)
				for i in range(0, 1):
					var baby = baby_prefab.instance()
					get_node("/root/nodes/gameplay/hill").add_child(baby)
					baby.set_translation(ground.position + ground.normal * i)
				drop.queue_free()
				placing = false
		if event.pressed:
			var rect : Rect2 = $selection.get_global_rect()
			rect.size *= $selection.rect_scale.x
			if rect.has_point(event.position):
				placing = true
				drop = itemDrop.instance()
				drop.material_override.set_texture(0, last_closest.texture) # TEXTURE_ALBEDO
				get_node("/root/nodes/gameplay/hill").add_child(drop)
			elif get_global_rect().has_point(event.position):
				dragging = true
			if get_global_rect().has_point(event.position):
				$"/root/nodes/gameplay/hill/banner".set_spin_enabled(false)
		else:
			if dragging:
				dragging = false
				$items_target.rect_position = $items.rect_position
			$"/root/nodes/gameplay/hill/banner".set_spin_enabled(true)
	if event is InputEventMouseMotion:
		if dragging:
			$items_target.rect_position += event.relative
			# Select item nearest to snap
			$items.rect_position = $items_target.rect_position
			snap_inventory()
		if placing:
			angle_offset -= event.relative.x * 0.003
			height_offset -= event.relative.y * 0.3
			

func snap_inventory():
	var closest = null
	var closest_len = 1000000
	for item in $items.get_children():
		var to_selection = item.get_global_rect().position - $selection.get_global_rect().position
		if to_selection.length_squared() < closest_len:
			closest = item
			closest_len = to_selection.length_squared()
	if closest != last_closest:
		$pop.play()
		last_closest = closest
	$items.set_global_position($selection.get_global_rect().position + ($items.get_global_rect().position - closest.get_global_rect().position))

func _physics_process(delta):
	if placing:
		var banner = get_node("/root/nodes/gameplay/hill/banner")
		var y_pos = banner.get_y_pos() + height_offset
		var angle = banner.get_angle() + angle_offset
		var rotation = Vector3(banner.get_radius() * cos(angle), y_pos, banner.get_radius() * sin(angle))
		ground = get_node("/root/nodes/gameplay/hill").get_world().get_direct_space_state().intersect_ray(rotation, Vector3(0.0, y_pos- 200.0, 0.0))
		if not ground.empty():
			if ground.collider == null:
				var rot_offset = rotation
				rot_offset.y = 0
				rot_offset = rot_offset.normalized()
				var drop_pos = ground.position + rot_offset * 30.0
				drop.look_at(drop_pos + Vector3(0.0, -100.0, 0.0), rotation)
				drop.set_translation(drop_pos)
		# Raycast from world_pos y onto ground and then project drop to constant height above terrain
