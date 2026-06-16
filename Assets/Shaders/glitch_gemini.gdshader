/* Glitch Effect Shader - Alpha Locked for Godot 4 Sprites */
shader_type canvas_item;

uniform float shake_power = 0.03;
uniform float shake_rate : hint_range( 0.0, 1.0 ) = 0.2;
uniform float shake_speed = 5.0;
uniform float shake_block_size = 30.5;
uniform float shake_color_rate : hint_range( 0.0, 1.0 ) = 0.01;

float random( float seed ) {
	return fract( 543.2543 * sin( dot( vec2( seed, seed ), vec2( 3525.46, -54.3415 ) ) ) );
}

void fragment() {
	float enable_shift = float( random( trunc( TIME * shake_speed ) ) < shake_rate );

	vec2 fixed_uv = UV;
	fixed_uv.x += ( random( ( trunc( UV.y * shake_block_size ) / shake_block_size ) + TIME ) - 0.5 ) * shake_power * enable_shift;

	// 1. Sample the shifted glitch colors
	vec4 pixel_color = texture(TEXTURE, fixed_uv);
	
	pixel_color.r = mix( pixel_color.r , texture( TEXTURE, fixed_uv + vec2( shake_color_rate, 0.0 ) ).r , enable_shift );
	pixel_color.b = mix( pixel_color.b , texture( TEXTURE, fixed_uv + vec2( -shake_color_rate, 0.0 ) ).b , enable_shift );
	
	// 2. THE FIX: Grab the transparency of the perfectly normal, un-glitched sprite
	vec4 original_color = texture(TEXTURE, UV);
	
	// 3. Force the glitch to stay inside the exact silhouette of the original sprite!
	pixel_color.a = original_color.a;

	COLOR = pixel_color;
}