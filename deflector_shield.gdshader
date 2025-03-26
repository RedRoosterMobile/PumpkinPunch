shader_type spatial;
render_mode unshaded, depth_draw_opaque, cull_front;

uniform vec4 shield_color : source_color = vec4(0.05, 0.8, 1.0, 0.5); // Cyan with some transparency
uniform float pulse_speed = 2.0; // Speed of the outward pulse
uniform float pulse_strength = 0.1; // How much the shield curves outward
uniform float rim_strength = 1.5; // Glow at the edges
uniform float edge_lift_strength = 1.0;

void vertex() {
    // Create a pulsing, curved displacement outward
    float pulse = sin(TIME * pulse_speed + UV.y * 5.0) * pulse_strength;

	vec2 centered_uv = UV - vec2(0.5);
    float distance_from_center = length(centered_uv);
    float edge_factor = smoothstep(0.2, 0.5, distance_from_center);
	VERTEX.z -= edge_factor * edge_lift_strength;

    VERTEX += NORMAL * pulse; // Push vertices outward along normals
}


void fragment() {
    // Rim effect for a glowing edge
    float rim = pow(1.0 - dot(NORMAL, VIEW), 2.0) * rim_strength;

    // Simple radial fade based on UV to suggest energy dissipating outward
    float radial = length(UV - vec2(0.5, 0.5)); // Distance from center
    float fade = smoothstep(0.5, 0.0, radial); // Fade from center to edge

    // Combine effects
    ALBEDO = shield_color.rgb * (rim + fade);
    ALPHA = shield_color.a * fade * (rim + 0.5); // Transparency fades outward
}
