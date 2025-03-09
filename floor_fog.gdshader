shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, unshaded;

uniform sampler2D noise_texture_1; // First noise texture
uniform sampler2D noise_texture_2; // Second noise texture
uniform sampler2D noise_texture_3; // Third noise texture

uniform float speed_1 = 0.1; // Speed of the first layer
uniform float speed_2 = 0.15; // Speed of the second layer
uniform float speed_3 = 0.2; // Speed of the third layer

uniform float opacity = 0.5; // Overall opacity of the fog

void fragment() {
    // Get UV coordinates
    vec2 uv = UV;

    // Animate UVs for each layer using time
    vec2 uv1 = uv + vec2(TIME * speed_1, TIME * speed_1 * 0.5);
    vec2 uv2 = uv + vec2(TIME * speed_2, TIME * speed_2 * 0.7);
    vec2 uv3 = uv + vec2(TIME * speed_3, TIME * speed_3 * 0.3);

    // Sample noise textures
    float noise1 = texture(noise_texture_1, uv1).r;
    float noise2 = texture(noise_texture_2, uv2).r;
    float noise3 = texture(noise_texture_3, uv3).r;

    // Blend the noise layers
    float fog_density = (noise1 + noise2 + noise3) / 3.0;

    // Set the color and transparency
    ALBEDO = vec3(0.8, 0.9, 1.0); // Light bluish fog color (adjust as needed)
    ALPHA = fog_density * opacity; // Transparency based on noise and overall opacity
}