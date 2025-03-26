
/*
shader_type spatial;
render_mode unshaded, depth_draw_never,cull_front;

uniform vec2 speed = vec2( 0.2, 0.2 );
uniform vec4 barrier_color : source_color = vec4( 0.05, 0.8, 1.0, 1.0 );
uniform float barrier_force = 1.0;
uniform float barrier_noise_force = 0.3;
uniform float barrier_fog_noise_force = 0.01;
uniform sampler2D barrier_noise : hint_normal;
uniform sampler2D screen_texture : hint_screen_texture; // Use hint_screen_texture instead

void fragment( )
{
   float rim = pow( 1.0 - dot( NORMAL, VIEW ), 4.0 ) * barrier_force;

    vec2 p = texture( barrier_noise, -UV ).xy + TIME * speed;
    float line_noise = clamp( ( sin( texture( barrier_noise, p ).r * 3.1415926535 ) - 0.995 ) * 90.0, 0.0, 1.0 ) * barrier_noise_force - barrier_noise_force * 0.5;
    vec3 line_color = texture( screen_texture, SCREEN_UV + line_noise ).rgb;
    vec3 fog_color = texture( screen_texture, SCREEN_UV + texture( barrier_noise, vec2( UV.x * 8.0 - TIME * speed.x, UV.y * 8.0 ) ).r * barrier_fog_noise_force - barrier_fog_noise_force * 0.5 ).rgb;

    ALBEDO = mix( fog_color.rgb, line_color.rgb, ( abs(line_noise) < 0.1 ) ? 1.0 : 0.0 ) + barrier_color.rgb * rim;

	vec4 tt=texture( screen_texture, SCREEN_UV);
	ALBEDO = tt.rgb;
    ALPHA = 1.*/

	shader_type spatial;
render_mode unshaded, depth_draw_never, cull_front;

uniform vec4 barrier_color : source_color = vec4(0.05, 0.8, 1.0, 1.0);
uniform float wave_strength = 0.1;
uniform float wave_speed = 1.0;
uniform float rim_width = 1.0;

void vertex() {
    VERTEX += NORMAL * sin(TIME*wave_speed + UV.y * 10.0) * wave_strength;
}

void fragment() {
    float rim = pow(1.0 - dot(NORMAL, VIEW), 4.0/rim_width);
    ALBEDO = barrier_color.rgb * rim;
    ALPHA = barrier_color.a * rim;
}