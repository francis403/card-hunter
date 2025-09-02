shader_type canvas_item;

uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.8;
uniform vec3 vignette_color : source_color = vec3(0.4, 0.3, 0.2);

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 center = vec2(0.5, 0.5);
    
    // Calculate distance from center
    float distance = length(uv - center);
    
    // Create vignette effect
    float vignette = smoothstep(0.0, vignette_intensity, distance);
    vignette = pow(vignette, 1.5);
    
    // Apply vignette
    COLOR = vec4(vignette_color, vignette * vignette_opacity);
}