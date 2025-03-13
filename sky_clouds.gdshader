shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded;

uniform sampler2D noise_texture_1;
uniform sampler2D noise_texture_2;
uniform sampler2D noise_texture_3;

uniform vec2 direction_1 = vec2(1.0, 0.0);
uniform vec2 direction_2 = vec2(1.0, 0.0);
uniform vec2 direction_3 = vec2(1.0, 0.0);

uniform vec3 color_1 : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 color_2 : source_color = vec3(0.9, 0.9, 0.9);
uniform vec3 color_3 : source_color = vec3(0.8, 0.8, 0.8);

uniform float speed_1 = 0.1;
uniform float speed_2 = 0.15;
uniform float speed_3 = 0.2;

uniform float opacity = 0.75;
uniform float height_scale = 0.5;
uniform float edge_lift_strength = 1.0;

uniform vec3 emission_color : source_color = vec3(0.8, 0.8, 1.0); // Emission color (e.g., soft blue glow)
uniform float emission_strength = 0.5; // Strength of emission

void vertex() {
    vec2 centered_uv = UV - vec2(0.5);
    float distance_from_center = length(centered_uv);
    float edge_factor = smoothstep(0.3, 0.5, distance_from_center);
    VERTEX.y += edge_factor * edge_lift_strength;
}

void fragment() {
    vec2 uv = UV;

    vec2 uv1 = uv + direction_1 * TIME * speed_1;
    vec2 uv2 = uv + direction_2 * TIME * speed_2;
    vec2 uv3 = uv + direction_3 * TIME * speed_3;

    float noise1 = texture(noise_texture_1, uv1).r;
    float noise2 = texture(noise_texture_2, uv2).r;
    float noise3 = texture(noise_texture_3, uv3).r;

    float height = noise1 * height_scale;
    float normalized_height = clamp(height / height_scale, 0.0, 1.0);

    float alpha1 = noise1 * 1.0 * opacity * (1.0 - normalized_height);
    float alpha2 = noise2 * 1.0 * opacity * (1.0 - abs(normalized_height - 0.5));
    float alpha3 = noise3 * 0.6 * opacity * normalized_height;

    vec3 final_color = vec3(0.0);
    final_color += color_1 * noise1 * alpha1;
    final_color += color_2 * noise2 * alpha2;
    final_color += color_3 * noise3 * alpha3;

    float total_alpha = alpha1 + alpha2 + alpha3;
    total_alpha = clamp(total_alpha, 0.0, 0.8);

    // Calculate emission
    vec3 emission = emission_color * emission_strength * total_alpha; // Emission scales with cloud density

    ALBEDO = final_color*emission_strength;
    ALPHA = total_alpha;
    EMISSION = final_color; // Output emission
}