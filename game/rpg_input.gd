extends Spatial

export var cam : NodePath
export var banner : NodePath
var mouseDown = false
var target = Vector3()

func _enter_tree():
	Input.set_default_cursor_shape(Input.CURSOR_DRAG)

func _process(delta):
	if mouseDown:
			get_node(banner).set_target(target)

func _input(event):
	if event is InputEventMouseButton:
		mouseDown = event.pressed
	if event is InputEventMouse:
		var startRay = get_node(cam).project_ray_origin(event.position)
		var ground = get_world().direct_space_state.intersect_ray(startRay, startRay + get_node(cam).project_ray_normal(event.position) * 5000.0, Array(), 1)
		if ground.size() > 0:
			target = ground.position
