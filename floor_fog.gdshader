shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, unshaded;

uniform sampler2D noise_texture_1; // Top layer noise (most transparent)
uniform sampler2D noise_texture_2; // Middle layer noise
uniform sampler2D noise_texture_3; // Bottom layer noise

uniform float speed_1 = 0.1;  // Speed of the top layer
uniform float speed_2 = 0.15; // Speed of the middle layer
uniform float speed_3 = 0.2;  // Speed of the bottom layer

uniform float opacity = 0.75;  // Overall opacity multiplier

void fragment() {
    // Get UV coordinates
    vec2 uv = UV;

    // Animate UVs for each layer using time
    vec2 uv1 = uv + vec2(TIME * speed_1, TIME * speed_1 * 0.5);
    vec2 uv2 = uv + vec2(TIME * speed_2, TIME * speed_2 * 0.7);
    vec2 uv3 = uv + vec2(TIME * speed_3, TIME * speed_3 * 0.3);

    // Sample noise textures
    float noise1 = texture(noise_texture_1, uv1).r; // Top layer
    float noise2 = texture(noise_texture_2, uv2).r; // Middle layer
    float noise3 = texture(noise_texture_3, uv3).r; // Bottom layer

    // Use vertex height to determine layer influence
    // Assuming the quad's height ranges from 0 (bottom) to some small value like 0.2 (top)
    float height = clamp(VERTEX.z / 0.2, 0.0, 1.0); // Normalize height (adjust 0.2 based on your quad's Y position)

    // Define opacity for each layer
    float alpha1 = noise1 * 0.2 * opacity * (1.0 - height);      // Top: most transparent, fades at bottom
    float alpha2 = noise2 * 0.4 * opacity * (1.0 - abs(height - 0.5)); // Middle: peaks in the middle
    float alpha3 = noise3 * 0.6 * opacity * height;             // Bottom: most opaque, fades at top

    // Combine the layers
    float total_alpha = alpha1 + alpha2 + alpha3;
    total_alpha = clamp(total_alpha, 0.0, 0.8); // Cap total opacity to allow light through

    // Set the color and transparency
    ALBEDO = vec3(0.8, 0.9, 1.0); // Light bluish fog color
    ALPHA = total_alpha;          // Final transparency
}