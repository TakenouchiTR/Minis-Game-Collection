shader_type canvas_item;

// Define properties
uniform vec2 sprite_scale = vec2(1.0, 1.0);
uniform float edge_distance : hint_range(0.0, 50.0) = 1.0;
uniform vec4 inner_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Red
uniform vec4 outer_color : source_color = vec4(0.0, 1.0, 0.0, 1.0); // Green

void fragment() {
    vec4 src_color = texture(TEXTURE, UV);
    if (src_color.a == 0.0) {
        discard; // Skip transparent pixels
    }

    bool edge_pixel = false;
    int int_edge_distance = int(edge_distance / min(sprite_scale.x, sprite_scale.y));
    vec2 step = 1.0 / vec2(textureSize(TEXTURE, 0));

    for (int x = -int_edge_distance; x <= int_edge_distance; ++x) {
        for (int y = -int_edge_distance; y <= int_edge_distance; ++y) {
            if (abs(x) + abs(y) > int_edge_distance) {
                continue; // Skip pixels outside the Chebyshev distance
            }

            vec2 offset = vec2(float(x), float(y)) * step;
            vec2 neighbor_uv = UV + offset;

            // Check if the neighbor_uv is out of the texture bounds
            if (neighbor_uv.x < 0.0 || neighbor_uv.y < 0.0 || neighbor_uv.x > 1.0 || neighbor_uv.y > 1.0) {
                edge_pixel = true;
                break;
            }

            vec4 neighbor_color = texture(TEXTURE, neighbor_uv);
            if (neighbor_color.a == 0.0) {
                edge_pixel = true;
                break;
            }
        }
        if (edge_pixel) {
            break;
        }
    }

    // Choose the color based on the edge_pixel flag
    COLOR = edge_pixel ? outer_color : inner_color;
}