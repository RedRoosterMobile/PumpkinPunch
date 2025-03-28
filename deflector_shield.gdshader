shader_type spatial;
render_mode unshaded, depth_draw_opaque, cull_front;

uniform vec4 shield_color : source_color = vec4(0.05, 0.8, 1.0, 0.5);
uniform float pulse_speed = 2.0;
uniform float pulse_strength = 0.1;
uniform float rim_strength = 1.5;
uniform float edge_lift_strength = 1.0;
uniform float bubble_speed = 1.0;    // Speed of bubble movement
uniform float bubble_size = 0.1;     // Maximum size of bubbles
uniform float bubble_frequency = 3.0; // Number of simultaneous bubble rings

void vertex() {
    // Base pulse effect
    float pulse = sin(TIME * pulse_speed + UV.y * 5.0) * pulse_strength;

    // Edge lift
    vec2 centered_uv = UV - vec2(0.5);
    float distance_from_center = length(centered_uv);
    float edge_factor = smoothstep(0.2, 0.5, distance_from_center);
    VERTEX.z -= edge_factor * edge_lift_strength;

    VERTEX += NORMAL * pulse;
}

void fragment() {
    vec2 uv = UV - vec2(0.5); // Center the UV coordinates
    float dist = length(uv);  // Distance from center

    // Create multiple bubble rings
    float time = TIME * bubble_speed;
    float bubble = 0.0;

    // Generate multiple bubbles based on frequency
    for (float i = 0.0; i < bubble_frequency; i += 1.0) {
        float phase = i / bubble_frequency; // Offset each bubble
        float bubble_progress = fract(time + phase); // 0 to 1 cycle for each bubble
        float bubble_dist = bubble_progress * 0.5; // Scale to match UV space

        // Create bubble ring
        float ring = smoothstep(0.0, bubble_size, bubble_dist - dist) *
                    (1.0 - smoothstep(bubble_size, bubble_size * 2.0, bubble_dist - dist));
        bubble += ring * (1.0 - dist * 2.0); // Add to total, fade at edges
    }

    // Rim effect
    float rim = pow(1.0 - dot(NORMAL, VIEW), 2.0) * rim_strength;

    // Base radial fade
    float fade = smoothstep(0.5, 0.0, dist);

    // Combine effects
    float bubble_intensity = bubble * 2.0; // Amplify bubble visibility
    ALBEDO = shield_color.rgb * (rim + fade + bubble_intensity);
    ALPHA = shield_color.a * (fade + bubble) * (rim + 0.5);
}