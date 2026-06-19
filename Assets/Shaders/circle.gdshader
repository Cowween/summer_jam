shader_type canvas_item;

uniform float circle_size : hint_range(0.0, 1.0) = 0.0;
uniform vec4 fade_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    // Calculate distance from the center (0.5, 0.5)
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center);
    
    // Set circle size based on screen aspect ratio
    float aspect_ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
    vec2 scaled_uv = (UV - center) * vec2(1.0, aspect_ratio) + center;
    float scaled_dist = distance(scaled_uv, center);
    
    // Smooth edges and set alpha
    float mask = smoothstep(circle_size, circle_size + 0.05, scaled_dist);
    COLOR = vec4(fade_color.rgb, mask);
}