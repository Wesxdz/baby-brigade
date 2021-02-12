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
var last_closest = null
var storage
var ingredient_prefab = preload("res://ingredient.tscn")

func _enter_tree():
	storage = $"../popup/center/storage"
	snap_inventory()

func _input(event):
	if event is InputEventMouseButton:
		if placing and not event.pressed:
				angle_offset = spawn_offset 
				height_offset = spawn_height
				var place = last_closest.item.spawn.instance()
				place.get_node("setup").emit_signal("spawn", last_closest.item)
				place.set_translation(ground.position + ground.normal)
				get_node("/root/nodes/gameplay/hill").add_child(place)
				drop.free()
				placing = false
		if event.pressed:
			var rect : Rect2 = $selection.get_global_rect()
			rect.size *= $selection.rect_scale.x
			if rect.has_point(event.position):
				var can_place = false
				var item = last_closest.item.id
				if $"/root/inventory".is_resource(item):
					can_place = $"/root/inventory".get_stock(item) > 0
					if can_place:
						$"/root/inventory".change_resource(item, -1)
				else:
					can_place = $"/root/inventory".can_craft(item)
					if can_place:
						$"/root/inventory".craft(item)
				if can_place:
					placing = true
					drop = itemDrop.instance()
					drop.material_override.set_texture(0, last_closest.texture) # TEXTURE_ALBEDO
					get_node("/root/nodes/gameplay/hill").add_child(drop)
					$purchase.play()
			elif get_global_rect().has_point(event.position):
				dragging = true
			if get_global_rect().has_point(event.position):
				$"/root/nodes/gameplay/hill/banner/controller".set_spin_enabled(false)
		else:
			if dragging:
				dragging = false
				$items_target.rect_position = $items.rect_position
			$"/root/nodes/gameplay/hill/banner/controller".set_spin_enabled(true)
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
		select(closest.item)
	$items.set_global_position($selection.get_global_rect().position + ($items.get_global_rect().position - closest.get_global_rect().position))

func select(var item):
	for prev_ing in $"../popup/recipe".get_children():
		prev_ing.free()
	$selection.self_modulate = item.outline_color
	if $"/root/inventory".is_resource(item.id):
		storage.visible = true
		storage.popup(item)
	else:
		storage.visible = false
		var last_ing = null
		print($"/root/inventory".num_ingredients(item.id))
		var ing_items = $"/root/inventory".get_ingredient_items(item.id)
		var ing_counts = $"/root/inventory".get_ingredient_counts(item.id)
		for i in range(0, $"/root/inventory".num_ingredients(item.id)):
			var ingredient = ingredient_prefab.instance()
			ingredient.prev = last_ing
			ingredient.setup($"/root/inventory".items[ing_items[i]], ing_counts[i])
			$"../popup/recipe".add_child(ingredient)
			last_ing = ingredient

func _physics_process(delta):
	if placing:
		var banner = get_node("/root/nodes/gameplay/hill/banner")
		var y_pos = banner.get_y_pos() + height_offset
		var angle = banner.get_angle() + angle_offset
		var rotation = Vector3(banner.get_radius() * cos(angle), y_pos, banner.get_radius() * sin(angle))
		ground = get_node("/root/nodes/gameplay/hill").get_world().get_direct_space_state().intersect_ray(rotation, Vector3(0.0, y_pos- 200.0, 0.0), Array(), 1)
		if not ground.empty():
			if ground.collider == null:
				var rot_offset = rotation
				rot_offset.y = 0
				rot_offset = rot_offset.normalized()
				var drop_pos = ground.position + rot_offset * 30.0
				drop.look_at(drop_pos + Vector3(0.0, -100.0, 0.0), rotation)
				drop.set_translation(drop_pos)
		# Raycast from world_pos y onto ground and then project drop to constant height above terrain
