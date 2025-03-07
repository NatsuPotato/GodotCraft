extends MeshInstance3D

#https://docs.godotengine.org/en/stable/tutorials/3d/procedural_geometry/arraymesh.html#doc-arraymesh

func generate_quad(
		start_index : int,
		verts       : PackedVector3Array,
		uvs         : PackedVector2Array,
		normals     : PackedVector3Array,
		indices     : PackedInt32Array
	) -> int:
	
	verts.append(Vector3(0, 0, 0))
	normals.append(Vector3(0, 0, 1))
	uvs.append(Vector2(0, 1))
	
	verts.append(Vector3(1, 1, 0))
	normals.append(Vector3(0, 0, 1))
	uvs.append(Vector2(1, 0))
	
	verts.append(Vector3(1, 0, 0))
	normals.append(Vector3(0, 0, 1))
	uvs.append(Vector2(1, 1))
	
	verts.append(Vector3(0, 1, 0))
	normals.append(Vector3(0, 0, 1))
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
	
	generate_quad(0, verts, uvs, normals, indices)

	# assign arrays to surface array
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	# create mesh from array
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

func _process(delta: float) -> void:
	
	rotation.y += delta
