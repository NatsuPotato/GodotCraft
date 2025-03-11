shader_type spatial;

render_mode unshaded;

// reference: https://godotshaders.com/shader/make-the-water-line-darker-v1-0/

uniform float water_height = 5.5;
uniform float fade_distance = 5.0;
uniform vec3 fade_color: source_color;

varying float elevation;

void vertex() {
    elevation = (mat3(MODEL_MATRIX) * -VERTEX).y;
    elevation = -(elevation - NODE_POSITION_WORLD.y + water_height);
}

void fragment() {

	if (elevation > 0.0) discard;

	ALBEDO = mix(vec3(1.,1.,1.), fade_color, clamp(-elevation / fade_distance, 0.0, 1.0));
}