shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)),
             dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

// use texture instead for performance
float noise(vec2 p) {
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;

    vec2 i = floor(p + (p.x + p.y) * K1);

    vec2 a = p - i + (i.x + i.y) * K2;
    vec2 o = (a.x > a.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + 2.0 * K2;

    vec3 h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);

    vec3 n = h * h * h * h * vec3(dot(a, hash(i + 0.0)),
                                   dot(b, hash(i + o)),
                                   dot(c, hash(i + 1.0)));

    return dot(n, vec3(70.0));
}

float fbm(vec2 uv) {
    float f;
	
    //mat2 m = mat2(1.6, 1.2, -1.2, 1.6);
	mat2 m = mat2(vec2(1.6, 1.2), vec2(-1.2, 1.6));

    f = 0.5000 * noise(uv);
    uv = m * uv;
    f += 0.1250 * noise(uv);
    uv = m * uv;
    f += 0.0625 * noise(uv);
    uv = m * uv;
    f = 0.5 + 0.5 * f;
    return f;
}

void fragment() {
    vec2 uv = UV;

    vec2 q = uv;
    q.x *= 3.0;
    q.y *= 2.0;

    float strength = floor(q.x + 1.0);
    float T3 = max(3.0, 1.25 * strength) * TIME;

    q.x -= 1.5;
    q.y -= 0.25;

    float n = fbm(strength * q - vec2(0.0, T3));

    float c = 1.0 - 16.0 * pow(max(0.0, length(q * vec2(1.8 + q.y * 1.5, 0.75)) - n * max(0.0, q.y + 0.25)), 1.2);
    float c1 = n * c * (1.5 - pow(1.25 * uv.y, 4.0));
    c1 = clamp(c1, 0.0, 1.0);

    vec3 col = vec3(1.5 * c1, 1.5 * pow(c1, 3.0), pow(c1, 6.0));

    float a = c * (1.0 - pow(uv.y, 3.0));
	EMISSION = mix(vec3(0.0), col, a); // Use EMISSION instead of COLOR
    ALPHA = a; // Set transparency
	ALBEDO = (mix(vec3(0.0), col, a));
}
/*
void vertex() {
    vec2 uv = UV;
    float t = TIME;

    // Compute noise values for X and Z displacement
    float noise_y = fbm(vec2(uv.y * 5.0, t * 0.5));
    float noise_z = fbm(vec2(uv.y * 5.0 + 100.0, t * 0.5));

    // Displacement amplitude, stronger at the top (uv.y = 1.0)
    float amplitude = 0.1 * uv.y; // Adjust amplitude as needed

    // Adjust noise range from [0,1] to [-1,1]
    float displacement_y = (noise_y - 0.5) * 2.0 * amplitude;
    float displacement_z = (noise_z - 0.5) * 2.0 * amplitude;

    // Apply displacement
    VERTEX.y += displacement_y;
    VERTEX.z += displacement_z;
}
*/
