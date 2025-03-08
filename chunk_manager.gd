extends Node3D

const CHUNK_SCENE := preload("res://chunk.tscn")

var generator_threads := []
var live_chunk_positions := []

var noise : FastNoiseLite

func _ready() -> void:
	
	#https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html#enum-fastnoiselite-noisetype
	noise = FastNoiseLite.new()
	noise.set_seed(RandomNumberGenerator.new().randi())
	noise.set_domain_warp_frequency(0.1)
	noise.set_noise_type(FastNoiseLite.TYPE_PERLIN)
	
func _process(delta:float) -> void:
	
	# wait on terminated threads
	for i in generator_threads.size():
		
		if i >= generator_threads.size():
			break
		
		var thread = generator_threads[i]
		
		if !thread.is_alive():
			thread.wait_to_finish()
			generator_threads.remove_at(i)
	
	# temp, pick a random position, if it doesn't already have a chunk, spawn a thread
	if (generator_threads.size() < 16):
		
		var desired_chunk_pos := Vector3i(randi_range(0, 3), randi_range(0, 3), randi_range(0, 3))
		
		if live_chunk_positions.find(desired_chunk_pos) == -1:
			
			live_chunk_positions.append(desired_chunk_pos)
			
			var thread = Thread.new()
			thread.start(generate_chunk.bind(desired_chunk_pos))
			generator_threads.append(thread)
	
func generate_chunk(chunk_pos:Vector3i):
	
	var chunk := CHUNK_SCENE.instantiate()
	
	chunk.position = chunk_pos * chunk.CHUNK_SIZE
	chunk.populate(noise)
	
	call_deferred("add_child", chunk)
