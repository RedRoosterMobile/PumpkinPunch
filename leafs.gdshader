shader_type particles;

// Render mode to keep particle data between frames
render_mode keep_data;

// Uniforms to control leaf behavior
uniform float fall_speed : hint_range(0.1, 10.0) = 2.0;
uniform float sway_amplitude : hint_range(0.0, 2.0) = 0.5;
uniform float rotation_speed : hint_range(0.0, 5.0) = 1.0;
uniform vec3 wind_direction = vec3(1.0, 0.0, 0.0);

// Start function - initializes particles
void start() {
    // Randomize initial position (you can adjust these ranges)
    vec3 start_pos = vec3(
        float(RANDOM_SEED) * 10.0 - 5.0, // X: -5 to 5
        float(RANDOM_SEED + 1u) * 10.0,   // Y: 0 to 10
        float(RANDOM_SEED + 2u) * 10.0 - 5.0 // Z: -5 to 5
    );

    // Set initial transform
    TRANSFORM[3].xyz = start_pos;

    // Random initial rotation
    float angle = float(RANDOM_SEED + 3u) * TAU;
    TRANSFORM[0] = vec4(cos(angle), 0.0, -sin(angle), 0.0);
    TRANSFORM[2] = vec4(sin(angle), 0.0, cos(angle), 0.0);

    // Random initial velocity
    VELOCITY = vec3(
        (float(RANDOM_SEED + 4u) - 0.5) * 2.0,
        -fall_speed,
        (float(RANDOM_SEED + 5u) - 0.5) * 2.0
    );

    // Random lifetime between 5 and 10 seconds
    //LIFETIME = 5.0 + float(RANDOM_SEED + 6u) * 5.0;
}

// Process function - updates particles each frame
void process() {


    // Apply gravity and wind
    VELOCITY.y = -fall_speed;
    VELOCITY += normalize(wind_direction) * 0.5;

    // Update position
    TRANSFORM[3].xyz += VELOCITY * DELTA;

    // Add swaying motion
    float sway = sin(TIME + float(NUMBER)) * sway_amplitude;
    TRANSFORM[3].x += sway;

    // Add rotation
    float rot = rotation_speed * DELTA;
    mat4 rotation = mat4(
        vec4(cos(rot), 0.0, sin(rot), 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(-sin(rot), 0.0, cos(rot), 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );
    TRANSFORM *= rotation;

    // Reset particle when it falls too low
    if (TRANSFORM[3].y < -10.0) {
        ACTIVE = false;
    }
}