shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded;

uniform sampler2D noise_texture_1; // Top layer noise (most transparent)
uniform sampler2D noise_texture_2; // Middle layer noise
uniform sampler2D noise_texture_3; // Bottom layer noise

uniform vec2 direction_1 = vec2(1.0, 0.0); // Direction of top layer
uniform vec2 direction_2 = vec2(1.0, 0.0); // Direction of middle layer
uniform vec2 direction_3 = vec2(1.0, 0.0); // Direction of bottom layer

uniform vec3 color_1 : source_color = vec3(1.0, 1.0, 1.0); // Top layer color
uniform vec3 color_2 : source_color = vec3(0.9, 0.9, 0.9); // Middle layer color
uniform vec3 color_3 : source_color = vec3(0.8, 0.8, 0.8); // Bottom layer color

uniform float speed_1 = 0.1;      // Speed of the top layer
uniform float speed_2 = 0.15;     // Speed of the middle layer
uniform float speed_3 = 0.2;      // Speed of the bottom layer

uniform float opacity = 0.75;     // Overall opacity multiplier
uniform float height_scale = 0.5; // Controls the height of the vertex displacement


void fragment() {
    // Get UV coordinates
    vec2 uv = UV;

    // Animate UVs for each layer using time and their specific directions
    vec2 uv1 = uv + direction_1 * TIME * speed_1;
    vec2 uv2 = uv + direction_2 * TIME * speed_2;
    vec2 uv3 = uv + direction_3 * TIME * speed_3;

    // Sample noise textures
    float noise1 = texture(noise_texture_1, uv1).r; // Top layer
    float noise2 = texture(noise_texture_2, uv2).r; // Middle layer
    float noise3 = texture(noise_texture_3, uv3).r; // Bottom layer

    // Use vertex height to influence layer blending
    float height = noise1 * height_scale;
    float normalized_height = clamp(height / height_scale, 0.0, 1.0);

    // Calculate opacity for each layer
    float alpha1 = noise1 * 1.0 * opacity * (1.0 - normalized_height);      // Top: fades at bottom
    float alpha2 = noise2 * 1.0 * opacity * (1.0 - abs(normalized_height - 0.5)); // Middle: peaks in middle
    float alpha3 = noise3 * 0.6 * opacity * normalized_height;             // Bottom: fades at top

    // Combine colors with their respective alphas
    vec3 final_color = vec3(0.0);
    final_color += color_1 * noise1 * alpha1;
    final_color += color_2 * noise2 * alpha2;
    final_color += color_3 * noise3 * alpha3;

    // Calculate total alpha
    float total_alpha = alpha1 + alpha2 + alpha3;
    total_alpha = clamp(total_alpha, 0.0, 0.8);

    // Output final color and transparency
    ALBEDO = final_color;
    ALPHA = total_alpha;
}