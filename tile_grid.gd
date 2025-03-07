extends MeshInstance3D

#https://docs.godotengine.org/en/stable/tutorials/3d/procedural_geometry/arraymesh.html#doc-arraymesh

static func generate_quad(
		start_index : int,
		pos         : Vector3, # grid space
		rot         : int, # [0, 5]
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

	uvs.append(Vector2(0, 1))
	uvs.append(Vector2(1, 0))
	uvs.append(Vector2(1, 1))
	uvs.append(Vector2(0, 0))

	# connect vertices into triangles
	indices.append(start_index)
	indices.append(start_index + 1)
	indices.append(start_index + 2)
	
	indices.append(start_index)
	indices.append(start_index + 3)
	indices.append(start_index + 1)
	
	return start_index + 4

func _ready():
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	#https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html#enum-fastnoiselite-noisetype
	var noise = FastNoiseLite.new()
	noise.set_seed(RandomNumberGenerator.new().randi())
	noise.set_noise_type(FastNoiseLite.TYPE_PERLIN)
	
	var index = 0
	for x in range(0, 100):
		for y in range(0, 20):
			for z in range(0, 100):
				for rot in range(0, 6):
					if (noise.get_noise_3d(x, y, z) - y * 0.01 > 0):
						index = generate_quad(index, Vector3(x, y, z), rot, verts, uvs, normals, indices)

	# assign arrays to surface array
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	# create mesh from array
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
