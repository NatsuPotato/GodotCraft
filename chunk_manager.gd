extends Node3D

const CHUNK_SCENE := preload("res://chunk.tscn")
var generator_thread : Thread

func _ready() -> void:
	
	generator_thread = Thread.new()
	
	generator_thread.start(generate_chunks)
	
func _update() -> void:
	
	if !generator_thread.is_alive():
		generator_thread.wait_to_finish()
	
func generate_chunks():
	
	#https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html#enum-fastnoiselite-noisetype
	var noise = FastNoiseLite.new()
	noise.set_seed(RandomNumberGenerator.new().randi())
	noise.set_domain_warp_frequency(0.1)
	noise.set_noise_type(FastNoiseLite.TYPE_PERLIN)
	
	for cx in 16:
		for cy in range(-8, 0):
			for cz in 16:
				
				print(str(cx * 128 + (cy + 8) * 16 + cz + 1) + "/2048")
	
				var chunk := CHUNK_SCENE.instantiate()
				
				chunk.position = Vector3i(cx, cy, cz) * chunk.CHUNK_SIZE
				chunk.populate(noise)
				
				call_deferred("add_child", chunk)
	
	print(int(Time.get_ticks_usec() / 100000.0) / 10.0)
