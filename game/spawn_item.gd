extends TextureButton

var isDragging = false
var itemDrop = preload("item_drop.tscn")
var drop
var mouse_pos
var spawn_offset = -0.4 
var angle_offset = spawn_offset
var spawn_height = 0.0
var height_offset = spawn_height

func _on_babybox_button_down():
	isDragging = true
	get_node("/root/nodes/gameplay/hill/banner").set_spin_enabled(false)
	drop = itemDrop.instance()
	get_node("/root/nodes/gameplay/hill").add_child(drop)
	print("Drag!")

func _input(event):
	if event is InputEventMouse:
		mouse_pos = (event as InputEventMouse).position
#		print(mouse_pos)
	if isDragging:
		if event is InputEventMouseButton:
			isDragging = (event as InputEventMouseButton).pressed
			if not isDragging:
				get_node("/root/nodes/gameplay/hill/banner").set_spin_enabled(true)
				angle_offset = spawn_offset 
				height_offset = spawn_height
				drop.queue_free()
		if event is InputEventMouseMotion:
			angle_offset -= event.relative.x * 0.003
			height_offset -= event.relative.y * 0.3

func _physics_process(delta):
	if isDragging:
		var banner = get_node("/root/nodes/gameplay/hill/banner")
		var y_pos = banner.get_y_pos() + height_offset
		var angle = banner.get_angle() + angle_offset
		var rotation = Vector3(banner.get_radius() * cos(angle), y_pos, banner.get_radius() * sin(angle))
		var ground = get_node("/root/nodes/gameplay/hill").get_world().get_direct_space_state().intersect_ray(rotation, Vector3(0.0, y_pos, 0.0))
		if not ground.empty():
			if ground.collider == null:
				var rot_offset = rotation
				rot_offset.y = 0
				rot_offset = rot_offset.normalized()
				var drop_pos = ground.position + rot_offset * 30.0
				drop.look_at(drop_pos + Vector3(0.0, -100.0, 0.0), rotation)
				drop.set_translation(drop_pos)
		# Raycast from world_pos y onto ground and then project drop to constant height above terrain
