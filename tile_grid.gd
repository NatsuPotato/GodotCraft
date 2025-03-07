extends MeshInstance3D

func _ready():
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	verts.append(Vector3(0, 0, 0))
	normals.append(Vector3(0, 0, 1))
	uvs.append(Vector2(0, 0))
	
	verts.append(Vector3(1, 0, 0))
	normals.append(Vector3(0, 0, 1))
	uvs.append(Vector2(1, 0))
	
	verts.append(Vector3(1, 1, 0))
	normals.append(Vector3(0, 0, 1))
	uvs.append(Vector2(1, 1))

	# create triangle
	indices.append(0)
	indices.append(1)
	indices.append(2)

	# assign arrays to surface array
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	# create mesh from array
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

func _process(delta: float) -> void:
	
	rotation.y += delta
