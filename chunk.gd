extends StaticBody3D

@export var MESH : MeshInstance3D
@export var COLLIDER : CollisionShape3D

# TODO hidden face optimization
# TODO add dynamic collision generation

var tile_data = PackedByteArray()

func _ready():
	
	# generate tile data (temp, should be done by a chunk manager)
	
	#https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html#enum-fastnoiselite-noisetype
	var noise = FastNoiseLite.new()
	noise.set_seed(RandomNumberGenerator.new().randi())
	noise.set_domain_warp_frequency(0.1)
	noise.set_noise_type(FastNoiseLite.TYPE_PERLIN)
	
	for x in 32:
		for y in 32:
			for z in 32:
				
				if (noise.get_noise_3d(x, y, z) > 0.03):
					tile_data.append(1)
				elif (noise.get_noise_3d(x, y, z) > 0):
					tile_data.append(2)
				else:
					tile_data.append(0)
	
	remesh()

func remesh():
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	var index = 0
	
	for x in 32:
		for y in 32:
			for z in 32:
				
				var tile_type = tile_data[x * 1024 + y * 32 + z]
				if (tile_type != 0):
					for rot in range(0, 6):
						index = generate_quad(index, Vector3(x, y, z), rot, tile_type, verts, uvs, normals, indices)

	# assign arrays to surface array
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	# create mesh from array
	MESH.mesh = ArrayMesh.new()
	MESH.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

#https://docs.godotengine.org/en/stable/tutorials/3d/procedural_geometry/arraymesh.html#doc-arraymesh
static func generate_quad(
		start_index : int,
		pos         : Vector3, # grid space
		rot         : int, # [0, 5]
		tile_type   : int, # for UV mapping to spritemap
		verts       : PackedVector3Array,
		uvs         : PackedVector2Array,
		normals     : PackedVector3Array,
		indices     : PackedInt32Array
	) -> int:
		
	if (rot == 0):
		verts.append(pos + Vector3(1, 0, 1))
		verts.append(pos + Vector3(1, 1, 0))
		verts.append(pos + Vector3(1, 0, 0))
		verts.append(pos + Vector3(1, 1, 1))
		
	if (rot == 1):
		verts.append(pos)
		verts.append(pos + Vector3(0, 1, 1))
		verts.append(pos + Vector3(0, 0, 1))
		verts.append(pos + Vector3(0, 1, 0))
		
	if (rot == 2):
		verts.append(pos + Vector3(0, 1, 0))
		verts.append(pos + Vector3(1, 1, 1))
		verts.append(pos + Vector3(0, 1, 1))
		verts.append(pos + Vector3(1, 1, 0))
		
	if (rot == 3):
		verts.append(pos + Vector3(0, 0, 0))
		verts.append(pos + Vector3(1, 0, 1))
		verts.append(pos + Vector3(1, 0, 0))
		verts.append(pos + Vector3(0, 0, 1))
	
	if (rot == 4):
		verts.append(pos + Vector3(0, 0, 1))
		verts.append(pos + Vector3(1, 1, 1))
		verts.append(pos + Vector3(1, 0, 1))
		verts.append(pos + Vector3(0, 1, 1))
		
	if (rot == 5):
		verts.append(pos + Vector3(1, 0, 0))
		verts.append(pos + Vector3(0, 1, 0))
		verts.append(pos)
		verts.append(pos + Vector3(1, 1, 0))
	
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

	uvs.append(Vector2(tile_type, 1))
	uvs.append(Vector2(tile_type + 1, 0))
	uvs.append(Vector2(tile_type + 1, 1))
	uvs.append(Vector2(tile_type, 0))

	# connect vertices into triangles
	indices.append(start_index)
	indices.append(start_index + 1)
	indices.append(start_index + 2)
	
	indices.append(start_index)
	indices.append(start_index + 3)
	indices.append(start_index + 1)
	
	return start_index + 4
