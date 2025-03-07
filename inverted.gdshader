shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	COLOR.rgb = 1.0 / (1.0 + pow(vec3(2,2,2), 20.0 * textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb - 10.0));
	COLOR.a = texture(TEXTURE , UV).a;
}