shader_type spatial;

render_mode unshaded;

// reference: https://godotshaders.com/shader/make-the-water-line-darker-v1-0/

uniform float water_height = 5.25;
uniform float fade_distance = 5.0;
uniform vec3 fade_color: source_color;
uniform float wobble_speed = 2.0;

varying float elevation;

void vertex() {

    elevation = (mat3(MODEL_MATRIX) * -VERTEX).y;
    elevation = -(elevation - NODE_POSITION_WORLD.y + water_height + sin(TIME * wobble_speed) * 0.25);
}

void fragment() {

	if (elevation > 0.0) discard;

	ALBEDO = mix(vec3(1.,1.,1.), fade_color, clamp(-elevation / fade_distance, 0.0, 1.0));
}