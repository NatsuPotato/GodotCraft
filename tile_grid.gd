extends StaticBody3D

# For many decades all GPU's have been able to handle over 2 million polygons
# which translates to over 512x512 view distance (once you do the basic things
# like bury algorithm and view frustum culling) it would be INCREDIBLE to play
# a minecraft with infinite view distance but at this point i suggest focusing
# on game-play mechanics, difficult and cunning enemies, interesting and
# inventive objectives, robust and useful interaction mechanics, these are all
# places where Minecraft falls flat on it's face and they are all places where
# you can swoop in and succeed as a game developer!

# Basically, infinite worlds are boring actually

#add a mechanic where you can dig around and eat tiles inside the chunk, making you bigger
#put a little icon of yourself in the top right to see how fat you are
#when you consume the entire island, you win
#it's sorta a puzzle game since the bigger you get, the less high you can jump
#so you gotta find your way to the top and work your way down
#BUT there's also a time limit, so it's kinda a fast-paced puzzle to get as fast as possible before level end
#*fat as possible

const GRID_SIZE : int = 32
const GRID_SIZE_SQ : int = GRID_SIZE * GRID_SIZE

@export var MESH : MeshInstance3D
@export var COLLIDER : CollisionShape3D

var all_tile_types  := PackedByteArray()
var all_tile_meshes := []

func _ready():
	
	all_tile_meshes.resize(GRID_SIZE * GRID_SIZE * GRID_SIZE)
	
	var noise := FastNoiseLite.new()
	noise.set_seed(RandomNumberGenerator.new().randi())
	noise.set_domain_warp_frequency(0.1)
	noise.set_noise_type(FastNoiseLite.TYPE_PERLIN)
	
	# generate tile data
	for x in GRID_SIZE:
		for y in GRID_SIZE:
			for z in GRID_SIZE:
				
				if (noise.get_noise_3dv(Vector3(x, y, z) + position) > 0):
					
					if (noise.get_noise_3dv((Vector3(x, y, z) + position) * 3 + Vector3(1203, 123, -47)) > 0):
						all_tile_types.append(1)
					else:
						all_tile_types.append(2)
				else:
					all_tile_types.append(0)
	
	# initialize mesh data
	for x in GRID_SIZE:
		for y in GRID_SIZE:
			for z in GRID_SIZE:
				remesh(Vector3i(x, y, z))
	
	# show the mesh
	push_mesh()

func get_index_from_pos(pos:Vector3i):
	
	return pos.x * GRID_SIZE_SQ + pos.y * GRID_SIZE + pos.z

func get_tile_pos_from_raycast(raycast_result:Dictionary, on_surface:bool) -> Vector3i:
	
	var tile_pos = Vector3(raycast_result.position)
	
	# push in or out of tile
	if on_surface:
		tile_pos += raycast_result.normal * 0.5
	else:
		tile_pos -= raycast_result.normal * 0.5
	
	# convert to local
	tile_pos -= position
	
	return tile_pos

func set_tile_type(pos:Vector3i, tile_type:int):
	
	if (get_tile_pos_oob(pos)):
		return
	
	all_tile_types[get_index_from_pos(pos)] = tile_type
	
	remesh(pos)
	remesh_safe(pos + Vector3i( 1,  0,  0))
	remesh_safe(pos + Vector3i(-1,  0,  0))
	remesh_safe(pos + Vector3i( 0,  1,  0))
	remesh_safe(pos + Vector3i( 0, -1,  0))
	remesh_safe(pos + Vector3i( 0,  0,  1))
	remesh_safe(pos + Vector3i( 0,  0, -1))
	
	push_mesh()

func get_tile_type(pos:Vector3i) -> int:
	
	if (get_tile_pos_oob(pos)):
		return 0
	
	return all_tile_types[get_index_from_pos(pos)]

func get_tile_pos_oob(pos:Vector3i) -> bool:
	
	return pos.x >= GRID_SIZE or pos.y >= GRID_SIZE or pos.z >= GRID_SIZE or pos.x < 0 or pos.y < 0 or pos.z < 0

func get_tile_is_transparent(pos:Vector3i) -> bool:
	
	return get_tile_type(pos) == 0

# remeshes a single tile's entry in tile_mesh_data
# typically you're gonna wanna remesh every tile around a change
func remesh_safe(pos:Vector3i):
	
	if (!get_tile_pos_oob(pos)):
		remesh(pos)

func remesh(pos:Vector3i):
	
	var mesh := [
		PackedVector3Array(), # verts
		PackedVector2Array(), # uvs
		PackedVector3Array(), # normals
		PackedInt32Array(),   # indices
		PackedVector3Array()  # collision_verts
	]
	
	var tile_type = get_tile_type(pos)
	if (tile_type != 0):
		
		var index = 0
		
		# hidden face optimization
		if get_tile_is_transparent(pos + Vector3i(1, 0, 0)):
			index = generate_quad(index, pos, 0, tile_type, mesh)
		
		if get_tile_is_transparent(pos + Vector3i(-1, 0, 0)):
			index = generate_quad(index, pos, 1, tile_type, mesh)
		
		if get_tile_is_transparent(pos + Vector3i(0, 1, 0)):
			index = generate_quad(index, pos, 2, tile_type, mesh)
		
		if get_tile_is_transparent(pos + Vector3i(0, -1, 0)):
			index = generate_quad(index, pos, 3, tile_type, mesh)
		
		if get_tile_is_transparent(pos + Vector3i(0, 0, 1)):
			index = generate_quad(index, pos, 4, tile_type, mesh)
		
		if get_tile_is_transparent(pos + Vector3i(0, 0, -1)):
			index = generate_quad(index, pos, 5, tile_type, mesh)

	all_tile_meshes[get_index_from_pos(pos)] = mesh

# pushes tile_mesh_data to the world
# TODO still stutters because has to go over every tile, even though is no
# longer calculating them. if this is a problem, we'll have to make multiple
# meshes (mesh-chunks)
func push_mesh():

	# generate arrays representing the mesh
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	var collision_verts = PackedVector3Array() # naturally divided into triples that define triangles
	
	var index = 0
	
	for mesh in all_tile_meshes:
		verts.append_array(mesh[0])
		uvs.append_array(mesh[1])
		normals.append_array(mesh[2])
		collision_verts.append_array(mesh[4])
		
		# index data within the mesh is local to that one tile
		# we need to make it global to every tile
		for i in mesh[3]:
			indices.append(i + index)
		
		index += mesh[0].size()

	# create mesh and collision mesh from arrays
	if (verts.size() != 0):
		
		var surface_array = []
		surface_array.resize(Mesh.ARRAY_MAX)
		
		surface_array[Mesh.ARRAY_VERTEX] = verts
		surface_array[Mesh.ARRAY_TEX_UV] = uvs
		surface_array[Mesh.ARRAY_NORMAL] = normals
		surface_array[Mesh.ARRAY_INDEX] = indices

		if (MESH.mesh == null):
			MESH.mesh = ArrayMesh.new()
		MESH.mesh.clear_surfaces()
		MESH.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
		
		if (COLLIDER.shape == null):
			COLLIDER.shape = ConcavePolygonShape3D.new()
		COLLIDER.shape.set_faces(collision_verts)

#https://docs.godotengine.org/en/stable/tutorials/3d/procedural_geometry/arraymesh.html#doc-arraymesh
static func generate_quad(
		start_index     : int,
		pos             : Vector3, # grid space
		rot             : int, # [0, 5]
		tile_type       : int, # for UV mapping to spritemap
		mesh
	) -> int:
	
	var verts           = mesh[0]
	var uvs             = mesh[1]
	var normals         = mesh[2]
	var indices         = mesh[3]
	var collision_verts = mesh[4]
	
	var v0 : Vector3
	var v1 : Vector3
	var v2 : Vector3
	var v3 : Vector3
	
	if (rot == 0):
		v0 = pos + Vector3(1, 0, 1)
		v1 = pos + Vector3(1, 1, 0)
		v2 = pos + Vector3(1, 0, 0)
		v3 = pos + Vector3(1, 1, 1)
		
		for i in range(0, 4):
			normals.append(Vector3(1, 0, 0))
		
	if (rot == 1):
		v0 = pos
		v1 = pos + Vector3(0, 1, 1)
		v2 = pos + Vector3(0, 0, 1)
		v3 = pos + Vector3(0, 1, 0)
		
		for i in range(0, 4):
			normals.append(Vector3(-1, 0, 0))
		
	if (rot == 2):
		v0 = pos + Vector3(0, 1, 0)
		v1 = pos + Vector3(1, 1, 1)
		v2 = pos + Vector3(0, 1, 1)
		v3 = pos + Vector3(1, 1, 0)
		
		for i in range(0, 4):
			normals.append(Vector3(0, 1, 0))
		
	if (rot == 3):
		v0 = pos
		v1 = pos + Vector3(1, 0, 1)
		v2 = pos + Vector3(1, 0, 0)
		v3 = pos + Vector3(0, 0, 1)
		
		for i in range(0, 4):
			normals.append(Vector3(0, -1, 0))
	
	if (rot == 4):
		v0 = pos + Vector3(0, 0, 1)
		v1 = pos + Vector3(1, 1, 1)
		v2 = pos + Vector3(1, 0, 1)
		v3 = pos + Vector3(0, 1, 1)
		
		for i in range(0, 4):
			normals.append(Vector3(0, 0, 1))
		
	if (rot == 5):
		v0 = pos + Vector3(1, 0, 0)
		v1 = pos + Vector3(0, 1, 0)
		v2 = pos
		v3 = pos + Vector3(1, 1, 0)
		
		for i in range(0, 4):
			normals.append(Vector3(0, 0, -1))
	
	verts.append(v0)
	verts.append(v1)
	verts.append(v2)
	verts.append(v3)
	
	collision_verts.append(v0)
	collision_verts.append(v1)
	collision_verts.append(v2)
	
	collision_verts.append(v0)
	collision_verts.append(v3)
	collision_verts.append(v1)

	uvs.append(Vector2(tile_type * 0.0625, 0.0625))
	uvs.append(Vector2(tile_type * 0.0625 + 0.0625, 0))
	uvs.append(Vector2(tile_type * 0.0625 + 0.0625, 0.0625))
	uvs.append(Vector2(tile_type * 0.0625, 0))

	# connect vertices into triangles
	indices.append(start_index)
	indices.append(start_index + 1)
	indices.append(start_index + 2)
	
	indices.append(start_index)
	indices.append(start_index + 3)
	indices.append(start_index + 1)
	
	return start_index + 4
