extends Node3D

# For many decades all GPU's have been able to handle over 2 million polygons
# which translates to over 512x512 view distance (once you do the basic things
# like bury algorithm and view frustum culling) it would be INCREDIBLE to play
# a minecraft with infinite view distance but at this point i suggest focusing
# on game-play mechanics, difficult and cunning enemies, interesting and
# inventive objectives, robust and useful interaction mechanics, these are all
# places where Minecraft falls flat on it's face and they are all places where
# you can swoop in and succeed as a game developer!

# Basically, infinite worlds are boring actually

const CHUNK_SCENE := preload("res://chunk.tscn")

var generator_threads := []
var requested_chunk_positions := []

var noise : FastNoiseLite

func _ready() -> void:
	
	for cx in 16:
		for cy in 16:
			for cz in 16:
				requested_chunk_positions.append(Vector3(cx, cy, cz))
	
	#https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html#enum-fastnoiselite-noisetype
	noise = FastNoiseLite.new()
	noise.set_seed(RandomNumberGenerator.new().randi())
	noise.set_domain_warp_frequency(0.1)
	noise.set_noise_type(FastNoiseLite.TYPE_PERLIN)

func _process(_delta:float) -> void:
	
	# wait on terminated threads
	for i in generator_threads.size():
		
		if i >= generator_threads.size():
			break
		
		var thread = generator_threads[i]
		
		if !thread.is_alive():
			thread.wait_to_finish()
			generator_threads.remove_at(i)
	
	if (requested_chunk_positions.size() > 0 and generator_threads.size() < 16):
		
		print(get_child_count() + 1)
		
		var thread = Thread.new()
		thread.start(generate_chunk.bind(requested_chunk_positions.pop_back()))
		generator_threads.append(thread)

func generate_chunk(chunk_pos:Vector3i):
	
	var chunk := CHUNK_SCENE.instantiate()
	
	chunk.position = chunk_pos * chunk.CHUNK_SIZE
	chunk.populate(noise)
	
	call_deferred("add_child", chunk)
