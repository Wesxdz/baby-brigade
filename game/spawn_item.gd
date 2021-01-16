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
		var cam = get_node("/root/nodes/gameplay/hill/target/peak_rotator/cam")
		var world_pos = cam.project_position(mouse_pos, 400.0)
		# Raycast from world_pos y onto ground and then project drop to constant height above terrain
		drop.set_translation(world_pos)
