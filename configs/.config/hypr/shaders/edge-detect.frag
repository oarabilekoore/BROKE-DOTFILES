#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec2 step = vec2(1.0 / 1920.0, 1.0 / 1080.0); // Assuming 1080p
    
    vec4 t = texture(tex, v_texcoord - vec2(0.0, step.y));
    vec4 l = texture(tex, v_texcoord - vec2(step.x, 0.0));
    vec4 r = texture(tex, v_texcoord + vec2(step.x, 0.0));
    vec4 b = texture(tex, v_texcoord + vec2(0.0, step.y));
    vec4 c = texture(tex, v_texcoord);
    
    // Find the difference between a pixel and its neighbors
    vec4 edge = abs((t + l + r + b) - 4.0 * c);
    
    // Boost the brightness of the edges
    fragColor = vec4(edge.rgb * 6.0, 1.0); 
}
