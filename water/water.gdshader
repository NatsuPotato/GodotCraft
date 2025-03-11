shader_type spatial;

render_mode unshaded;

uniform float slide_speed;
uniform float wobble_speed;
uniform float wobble_intensity;
uniform float texture_scale;
uniform sampler2D water : repeat_enable;

void vertex() {

	VERTEX.y += sin(TIME * wobble_speed) * 0.5 + 0.5;
}

void fragment() {

	ALBEDO = texture(
		water,
		vec2(
			(UV.x + sin(TIME * wobble_speed) * wobble_intensity + TIME * slide_speed) * texture_scale,
			(UV.y + cos(TIME * wobble_speed * 0.5) * wobble_intensity) * 2.0 * texture_scale
		)
	).xyz;
	ALPHA = 0.7;
}