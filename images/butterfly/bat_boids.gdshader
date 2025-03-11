shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D tex;
uniform vec4 color1 : source_color;
uniform vec4 color2 : source_color;
uniform float displ_amnt = 0.8;
uniform float displ_speed = 20.0;
uniform float pi = 3.14159265359;

void vertex()
{
    float mask = 1.0 - sin(pi * UV.x);
    float rand_val = COLOR.x * 10.0;
    VERTEX.y += sin(rand_val + TIME * displ_speed) * displ_amnt * mask;
}

void fragment()
{
    float rand_val = COLOR.x;
    vec4 col = texture(tex, UV) * mix(color1, color2, rand_val);
    ALPHA_SCISSOR_THRESHOLD = 0.01;
    ALPHA = col.a;
    ALBEDO = col.rgb;
}