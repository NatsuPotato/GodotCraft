extends StaticBody3D

const CHUNK_SIZE    : int = 32
const CHUNK_SIZE_SQ : int = CHUNK_SIZE * CHUNK_SIZE

@export var MESH : MeshInstance3D
@export var COLLIDER : CollisionShape3D

var tile_data = PackedByteArray()

func _ready():
	
	# generate tile data (temp, should be done by a chunk manager)
	
	#https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html#enum-fastnoiselite-noisetype
	var noise = FastNoiseLite.new()
	noise.set_seed(RandomNumberGenerator.new().randi())
	noise.set_domain_warp_frequency(0.1)
	noise.set_noise_type(FastNoiseLite.TYPE_PERLIN)
	
	for x in CHUNK_SIZE:
		for y in CHUNK_SIZE:
			for z in CHUNK_SIZE:
				
				if (noise.get_noise_3d(x, y, z) > 0.03):
					tile_data.append(1)
				elif (noise.get_noise_3d(x, y, z) > 0):
					tile_data.append(2)
				else:
					tile_data.append(0)
	
	remesh()

func get_tile_pos_from_raycast(raycast_result:Dictionary, on_surface:bool) -> Vector3i:
	
	var tile_pos = Vector3(raycast_result.position)
	
	# push in or out of block
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
	
	tile_data[pos.x * CHUNK_SIZE_SQ + pos.y * CHUNK_SIZE + pos.z] = tile_type
	remesh()

func get_tile_type(pos:Vector3i) -> int:
	
	if (get_tile_pos_oob(pos)):
		return 0
	
	return tile_data[pos.x * CHUNK_SIZE_SQ + pos.y * CHUNK_SIZE + pos.z]

func get_tile_pos_oob(pos:Vector3i) -> bool:
	
	return pos.x >= 32 or pos.y >= 32 or pos.z >= 32 or pos.x < 0 or pos.y < 0 or pos.z < 0

func get_tile_is_transparent(pos:Vector3i) -> bool:
	
	return get_tile_type(pos) == 0

func remesh():

	# generate arrays representing the mesh
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	# naturally divided into triples that define triangles
	var collision_verts = PackedVector3Array()
	
	var index = 0
	
	for x in 32:
		for y in 32:
			for z in 32:
				
				var tile_type = get_tile_type(Vector3i(x, y, z))
				if (tile_type != 0):
					
					# hidden face optimization
					if get_tile_is_transparent(Vector3i(x + 1, y, z)):
						index = generate_quad(index, Vector3(x, y, z), 0, tile_type, verts, uvs, normals, indices, collision_verts)
					
					if get_tile_is_transparent(Vector3i(x - 1, y, z)):
						index = generate_quad(index, Vector3(x, y, z), 1, tile_type, verts, uvs, normals, indices, collision_verts)
					
					if get_tile_is_transparent(Vector3i(x, y + 1, z)):
						index = generate_quad(index, Vector3(x, y, z), 2, tile_type, verts, uvs, normals, indices, collision_verts)
					
					if get_tile_is_transparent(Vector3i(x, y - 1, z)):
						index = generate_quad(index, Vector3(x, y, z), 3, tile_type, verts, uvs, normals, indices, collision_verts)
					
					if get_tile_is_transparent(Vector3i(x, y, z + 1)):
						index = generate_quad(index, Vector3(x, y, z), 4, tile_type, verts, uvs, normals, indices, collision_verts)
						
					if get_tile_is_transparent(Vector3i(x, y, z - 1)):
						index = generate_quad(index, Vector3(x, y, z), 5, tile_type, verts, uvs, normals, indices, collision_verts)

	# create mesh and collision mesh from arrays
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
		verts           : PackedVector3Array,
		uvs             : PackedVector2Array,
		normals         : PackedVector3Array,
		indices         : PackedInt32Array,
		collision_verts : PackedVector3Array
	) -> int:
	
	var v0 : Vector3
	var v1 : Vector3
	var v2 : Vector3
	var v3 : Vector3
	
	if (rot == 0):
		v0 = pos + Vector3(1, 0, 1)
		v1 = pos + Vector3(1, 1, 0)
		v2 = pos + Vector3(1, 0, 0)
		v3 = pos + Vector3(1, 1, 1)
		
	if (rot == 1):
		v0 = pos
		v1 = pos + Vector3(0, 1, 1)
		v2 = pos + Vector3(0, 0, 1)
		v3 = pos + Vector3(0, 1, 0)
		
	if (rot == 2):
		v0 = pos + Vector3(0, 1, 0)
		v1 = pos + Vector3(1, 1, 1)
		v2 = pos + Vector3(0, 1, 1)
		v3 = pos + Vector3(1, 1, 0)
		
	if (rot == 3):
		v0 = pos
		v1 = pos + Vector3(1, 0, 1)
		v2 = pos + Vector3(1, 0, 0)
		v3 = pos + Vector3(0, 0, 1)
	
	if (rot == 4):
		v0 = pos + Vector3(0, 0, 1)
		v1 = pos + Vector3(1, 1, 1)
		v2 = pos + Vector3(1, 0, 1)
		v3 = pos + Vector3(0, 1, 1)
		
	if (rot == 5):
		v0 = pos + Vector3(1, 0, 0)
		v1 = pos + Vector3(0, 1, 0)
		v2 = pos
		v3 = pos + Vector3(1, 1, 0)
	
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
	
	if (rot == 0):
		for i in range(0, 4): normals.append(Vector3(1, 0, 0))
	elif (rot == 1):
		for i in range(0, 4): normals.append(Vector3(-1, 0, 0))
	elif (rot == 2):
		for i in range(0, 4): normals.append(Vector3(0, 1, 0))
	elif (rot == 3):
		for i in range(0, 4): normals.append(Vector3(0, -1, 0))
	elif (rot == 4):
		for i in range(0, 4): normals.append(Vector3(0, 0, 1))
	elif (rot == 5):
		for i in range(0, 4): normals.append(Vector3(0, 0, -1))

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
