tool
extends Spatial
export(int) var width = 32
export(int) var depth = 32
export(float) var height_scale = 100.0
export(float) var slope = 3.0
var noise = OpenSimplexNoise.new()
var chunk_prefab = preload("res://terrain_section.tscn")
export(Material) var snow_material
var chunks = []
var start_location
var st = SurfaceTool.new()
var tree_prefab = preload("res://tree.tscn")
var snowman_prefab = preload("res://snowman_doll.tscn")
export(int) var spawn_sections = 3
var thread
var sections_to_spawn = []
var completed_section_buffer = []
var mutex

class SectionSpawnData:
	var pos : Vector3
	var x_index : int
	var z_index : int
	
class CompletedSectionData:
	var mesh
	var collision
	
func init_noise():
	randomize()
	noise.seed = randi()
	start_location = Vector2(randf() * 1000, randf() * 1000)
	start_location = Vector2(0.0, 0.0)
	print(start_location)
	noise.octaves = 1
	noise.period = 64.0
	noise.persistence = 0.8

func gen_terrain():
	for z in range(-spawn_sections, spawn_sections + 1):
		var row = []
		for x in range(-spawn_sections, spawn_sections + 1):
			row.push_back(spawn_terrain_section(Vector3(x * width, 0.0, z * depth)))
		chunks.push_back(row)
		
func buffer_spawn_terrain_section(var pos, var x, var z):
	var spawnData = SectionSpawnData.new()
	spawnData.pos = pos
	spawnData.x_index = x
	spawnData.z_index = z
	sections_to_spawn.push_back(spawnData)	

		
#func gen_terrain_buffer_spawn():
#	init_noise()
#	for z in range(-spawn_sections, spawn_sections + 1):
#		var row = []
#		for x in range(-spawn_sections, spawn_sections + 1):
#			var spawnData = SectionSpawnData.new()
#			spawnData.pos = Vector3(x * (width - 1), 0.0, z * (depth - 1))
#			spawnData.index = Vector2(z, x)
#		chunks.push_back(row)

func add_data(var row, var col, var offset, var surface, var chunk):
	var x = col + start_location.x + offset.x
	var y = row + start_location.y + offset.z
	var hill = noise.get_noise_2d(x, y);
	var point = Vector3(col, (hill * (height_scale + y * 0.01) - (slope * sqrt(pow(abs(offset.x + col), 2) + pow(abs(offset.z + row), 2)))), row) + offset
	surface.add_vertex(point)
#	#st.add_uv(Vector2(col/float(width), row/float(height)))

func clear_terrain():
	for y in range(0, chunks.size()):
		for x in range(0, chunks[y].size()):
			remove_child(chunks[y][x])
			chunks[y][x] = null

func _ready():
	pass
#	init_noise()
#	gen_terrain()
#	thread = Thread.new()
#	mutex = Mutex.new()

func spawn_terrain_section(var pos):
	var heights = []
	var chunk = chunk_prefab.instance()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var i = 0
	for row in range(0, depth):
		for col in range(0, width):
			var x = col + start_location.x + pos.x
			var y = row + start_location.y + pos.z
			var hill = noise.get_noise_2d(x, y);
			var point = Vector3(col, (hill * (height_scale + y * 0.01) - (slope * sqrt(pow(abs(pos.x + col), 2) + pow(abs(pos.z + row), 2)))), row) + pos
			heights.push_back(point)
			
			# TODO Optimize terrain gen into multithreaded GDNative script (either Rust or C++)
			# Don't use redundent get_noise calls
			add_data(row, col, pos, st, chunk)
			add_data(row, col+1, pos, st, chunk)
			add_data(row+1, col, pos, st, chunk)
			
			add_data(row, col+1, pos, st, chunk)
			add_data(row+1, col+1, pos, st, chunk)
			add_data(row+1, col, pos, st, chunk)
			
			var dist = abs(pos.x) + abs(pos.z)
			if dist > 50:
				if (int(hill * 10000) % int(max(2000, 5000 - dist)) == 1):
					var tree = tree_prefab.instance()
					tree.global_transform.origin = point
					# TODO: Set rotation to normal (this will make tiny hills look better
					tree.set_rotation(Vector3(0.0, atan2(pos.x, pos.z), 0.0))
					var tree_size = 2 + randf() * ((2 + dist)/400.0)
					tree.scale = Vector3(tree_size, tree_size, tree_size)
					chunk.add_child(tree)
				elif int(hill * 20000 + 5000) % 10000 == 1:
					var snowman = snowman_prefab.instance()
					snowman.global_transform.origin = point
					snowman.set_rotation(Vector3(0.0, atan2(pos.x, pos.z), 0.0))
					chunk.add_child(snowman)

	st.set_material(snow_material)
	var mesh = st.commit()
	
	chunk.set_mesh(mesh)

	var body = PhysicsServer.body_create(PhysicsServer.BODY_MODE_STATIC)
	PhysicsServer.body_set_space(body, get_world().space)
	PhysicsServer.body_set_collision_layer(body, 1)
	PhysicsServer.body_set_state(body, PhysicsServer.BODY_STATE_SLEEPING, false)
	PhysicsServer.body_set_state(body, PhysicsServer.BODY_STATE_TRANSFORM, Transform(Basis.IDENTITY, Vector3(0, 0, 0)))
	var poly = PhysicsServer.shape_create(PhysicsServer.SHAPE_CONVEX_POLYGON)
	PhysicsServer.shape_set_data(poly, heights)
	PhysicsServer.body_add_shape(body, poly)

	add_child(chunk)
	chunk.set_owner(self)
	
	return chunk
	
func spawn_terrain_section_multithreaded(var pos, var index : Vector2):
	var spawnData = SectionSpawnData.new()
	spawnData.pos = pos
	spawnData.index = index
	sections_to_spawn.push_back(spawnData)

func spawn_section_late(var spawnData):
	var chunk = chunk_prefab.instance()
	var heights = []
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var i = 0
	for row in range(0, depth):
		for col in range(0, width):
			var x = col + start_location.x + spawnData.pos.x
			var y = row + start_location.y + spawnData.pos.z
			var hill = noise.get_noise_2d(x, y);
			var point = Vector3(col, (hill * (height_scale + y * 0.01) - (slope * (abs(spawnData.pos.x + col) + abs(spawnData.pos.z + row)))), row) + spawnData.pos
			heights.push_back(point)

			add_data(row, col, spawnData.pos, surface, chunk)
			add_data(row, col+1, spawnData.pos, surface, chunk)
			add_data(row+1, col, spawnData.pos, surface, chunk)

			add_data(row, col+1, spawnData.pos, surface, chunk)
			add_data(row+1, col+1, spawnData.pos, surface, chunk)
			add_data(row+1, col, spawnData.pos, surface, chunk)
	
	print("Add data end")
	# crashes: 2
	surface.set_material(snow_material)
	var mesh = surface.commit()
	print("Mesh commit")
	chunk.set_mesh(mesh)
	print("Chunk instance")
	
	var body = PhysicsServer.body_create(PhysicsServer.BODY_MODE_STATIC)
	PhysicsServer.body_set_space(body, get_world().space)
	PhysicsServer.body_set_state(body, PhysicsServer.BODY_STATE_SLEEPING, false)
	PhysicsServer.body_set_state(body, PhysicsServer.BODY_STATE_TRANSFORM, Transform(Basis.IDENTITY, Vector3(0, 0, 0)))
	var poly = PhysicsServer.shape_create(PhysicsServer.SHAPE_CONVEX_POLYGON)
	PhysicsServer.shape_set_data(poly, heights)
	PhysicsServer.body_add_shape(body, poly)
	print("Mesh instance")

	var section = CompletedSectionData.new()
	section.mesh = chunk
	# https://docs.godotengine.org/en/stable/tutorials/threads/thread_safe_apis.html
	# Godot does not support .instance on multiple threads simultaneously
	# TODO: Single thread instancing, multi thread poly gen
	print("Mutex Lock")
	mutex.lock()
	chunks[int(spawnData.index.x)][int(spawnData.index.y)] = chunk
	completed_section_buffer.push_back(section)
	mutex.unlock()
	print("Mutex Unlock")
	call_deferred("section_completed")

func section_completed():
	thread.wait_to_finish()

func _process(delta):
#	print("Sections " , sections_to_spawn.size())

	# Spawn sections multithreaded
#	if not sections_to_spawn.empty() and not thread.is_active():
#		thread.start(self, "spawn_section_late", sections_to_spawn.pop_front())
	
	# Spawn sections frame buffer
	if not sections_to_spawn.empty():
		var spawn = sections_to_spawn.pop_front();
		chunks[spawn.z_index][spawn.x_index] = spawn_terrain_section(spawn.pos)
		
	for section in completed_section_buffer:
		add_child(section.mesh)
	completed_section_buffer.clear()
	
	
var sample_pos

func dist_to_sample(a, b):
	return a.offset.z < b.offset.z
#	return (a.offset - sample_pos).length_squared() > (b.offset - sample_pos).length_squared()

#func _exit_tree():
#	thread.wait_to_finish()


func _on_restart_pressed():
	$"/root/start_menu/start/start_game".restart_menu()
	$"/root/hill".queue_free()
#	for chunk_section in chunks:
#		for chunk in chunk_section:
#			remove_child(chunk)
#	chunks.clear()
#	gen_terrain()
