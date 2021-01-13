extends Spatial

# Hill Terrain Procedural Generation 

export(NodePath) var terrain_path
var origin = Vector3(0.0, 0.0, 0.0)
var t

func _ready():
	t = get_node(terrain_path)

func _process(delta):
	# TODO: Get terrain section origin closest to this
	var frame_origin = Vector3(int(global_transform.origin.x/t.width), 0.0, int(global_transform.origin.z/t.depth))
#	if frame_origin != origin:
#		if frame_origin.x > origin.x:
#			shift_right()
#		elif frame_origin.x < origin.x:
#			shift_left()
#		if frame_origin.z > origin.z:
#			shift_up()
#		elif frame_origin.z < origin.z:
#			shift_down()
#		origin = frame_origin

func shift_up():
	for chunk in t.chunks[0]:
		t.remove_child(chunk)
	t.chunks.remove(0)
	var row = []
	row.resize(t.spawn_sections * 2 + 1)
	t.chunks.push_back(row)
	for x in range(-t.spawn_sections, t.spawn_sections + 1):
		var pos = Vector3((origin.x + x) * t.width, 0.0, (origin.z + t.spawn_sections + 1) * t.depth)
#		t.spawn_terrain_section(pos)
		t.buffer_spawn_terrain_section(pos, t.spawn_sections + x, t.chunks.size() - 1)
#		t.spawn_terrain_section_multithreaded(pos, index)
	print("Shift up")

func shift_down():
	for chunk in t.chunks.pop_back():
		t.remove_child(chunk)
	var row = []
	row.resize(t.spawn_sections * 2 + 1)
	t.chunks.push_front(row)
	for x in range(-t.spawn_sections, t.spawn_sections + 1):
		var pos = Vector3((origin.x + x) * t.width, 0.0, (origin.z - t.spawn_sections) * t.depth)
		t.buffer_spawn_terrain_section(pos, t.spawn_sections + x, 0)
	print("Shift down")
	
func shift_right():
	for chunk_section in t.chunks:
		t.remove_child(chunk_section.pop_front())
	for z in range(0, (t.spawn_sections * 2) + 1):
		t.chunks[z].push_back(null)
		var pos = Vector3((origin.x + t.spawn_sections) * t.width, 0.0, (origin.z + z - t.spawn_sections + 1) * t.depth)
		t.buffer_spawn_terrain_section(pos, t.spawn_sections * 2, z)
	print("Shift right")

func shift_left():
	for chunk_section in t.chunks:
		t.remove_child(chunk_section.pop_back())
	for z in range(0, (t.spawn_sections * 2) + 1):
		t.chunks[z].push_front(null)
		var pos = Vector3((origin.x - t.spawn_sections - 1) * t.width, 0.0, (origin.z + z - t.spawn_sections + 1) * t.depth)
		t.buffer_spawn_terrain_section(pos, 0, z)
	print("Shift left")
	
