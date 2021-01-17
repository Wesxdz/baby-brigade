extends TextureButton

var isDragging = false
var itemDrop = preload("item_drop.tscn")
var drop
var mouse_pos

func _on_babybox_button_down():
	isDragging = true
	drop = itemDrop.instance()
	get_node("/root/nodes/gameplay/hill").add_child(drop)

func _input(event):
	if event is InputEventMouse:
		mouse_pos = (event as InputEventMouse).position
		print(mouse_pos)
	if isDragging:
		if event is InputEventMouseButton:
			isDragging = (event as InputEventMouseButton).pressed
			drop.queue_free()

func _physics_process(delta):
	if isDragging:
		var banner = get_node("/root/nodes/gameplay/hill/banner")
		var cam = get_node("/root/nodes/gameplay/hill/target/peak_rotator/cam")
		var world_pos = cam.project_position(mouse_pos, 300.0)
		var ground = get_node("/root/nodes/gameplay/hill").get_world().get_direct_space_state().intersect_ray(world_pos, Vector3(0.0, world_pos.y + 200.0, 0.0))
		if not ground.empty():
			drop.set_translation(ground.position + ground.normal * 50.0)
			
		# Raycast from world_pos y onto ground and then project drop to constant height above terrain
