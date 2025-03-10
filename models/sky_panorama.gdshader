shader_type sky;

uniform sampler2D source_panorama : filter_linear, source_color, hint_default_black;
// uniform sampler2D noise_panorama : filter_linear, source_color, hint_default_black;

uniform float exposure : hint_range(0, 128) = 1.0;

// like a fragment shader
void sky() {
  vec2 new_coord = SKY_COORDS;
  //new_coord.x += 0.0025 * TIME;
  //COLOR = (texture(source_panorama, SKY_COORDS).rgb + 0.2 * texture(noise_panorama, new_coord).rgb) * exposure;

  COLOR = (texture(source_panorama, SKY_COORDS).rgb*exposure);
}
