extends EditorScript
tool

func _run():
	terrain = get_scene().get_node("terrain")
	for child in terrain.get_children():
		terrain.remove_child(child)
	gen_terrain()
	
export(int) var width = 32
export(int) var depth = 32
export(float) var height_scale = 5.0
export(float) var slope = 0.8
var noise = OpenSimplexNoise.new()
var chunk_prefab = preload("res://terrain_section.tscn")
export(Material) var snow_material = preload("res://terrain_snow_material.tres")
var start_location
var st = SurfaceTool.new()
var tree_prefab = preload("res://tree.tscn")
var snowman_prefab = preload("res://snowman_doll.tscn")
var terrain

class SectionSpawnData:
	var pos : Vector3
	var index : Vector2
	var thread
	
class CompletedSectionData:
	var mesh
	var collision

func gen_terrain():
	randomize()
	noise.seed = randi()
	start_location = Vector2(randf() * 1000, randf() * 1000)
	print(start_location)
	noise.octaves = 1
	noise.period = 64.0
	noise.persistence = 0.8
	
	var origin = Vector3(0.0, 0.0, 0.0)
	
	for z in range(-3, 3):
		var row = []
		for x in range(-3, 3):
			spawn_terrain_section(origin + Vector3(x * (width - 1), 0.0, z * (depth - 1)))

func add_data(var row, var col, var offset, var surface):
	var x = col + start_location.x + offset.x
	var y = row + start_location.y + offset.z
	var hill = noise.get_noise_2d(x, y);
	var point = Vector3(col, (hill * (height_scale + y * 0.01) - (slope * (abs(offset.x + col) + abs(offset.z + row)))), row) + offset
	surface.add_vertex(point)
#	if offset.z > 50:
#		if randf() > 0.9999:
#			var tree = tree_prefab.instance()
#			tree.global_transform.origin = point
#			tree.rotate_x(1 - slope + (randf() * 0.1))
#			var tree_size = 2 + randf() * (2 + abs(offset.z)/200.0)
#			tree.scale = Vector3(tree_size, tree_size, tree_size)
#			get_scene().add_child(tree)
#			tree.set_owner(get_scene())
#		elif randf() < 0.0001:
#			var snowman = snowman_prefab.instance()
#			snowman.global_transform.origin = point
#			snowman.rotate_x(1 - slope + (randf() * 0.1))
#			get_scene().add_child(snowman)
#			snowman.set_owner(get_scene())
	st.add_uv(Vector2(col/float(width), row/float(depth)))

func spawn_terrain_section(var pos):
	var heights = []
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var i = 0
	for row in range(0, depth):
		for col in range(0, width):
			var x = col + start_location.x + pos.x
			var y = row + start_location.y + pos.z
			var hill = noise.get_noise_2d(x, y);
			var point = Vector3(col, (hill * (height_scale + y * 0.01) - (slope * (abs(pos.x + col) + abs(pos.z + row)))), row) + pos
			heights.push_back(point)

			add_data(row, col, pos, st)
			add_data(row, col+1, pos, st)
			add_data(row+1, col, pos, st)
			
			add_data(row, col+1, pos, st)
			add_data(row+1, col+1, pos, st)
			add_data(row+1, col, pos, st)

	st.set_material(snow_material)
	var mesh = st.commit()
	
	var chunk = chunk_prefab.instance()
	chunk.set_mesh(mesh)
	var chunk_collision = StaticBody.new()
	var shape = CollisionShape.new()
	shape.set_shape(mesh.create_convex_shape())
#	chunk.add_child(chunk_collision)
	
	get_scene().add_child(chunk_collision)
	chunk_collision.set_owner(get_scene())
	chunk_collision.add_child(shape)
	shape.set_owner(get_scene())
	
#	get_scene().add_child(shape)
	
	get_scene().add_child(chunk)
	chunk.set_owner(get_scene())
#	get_scene().remove_child(chunk)
#	terrain.add_child(chunk)
