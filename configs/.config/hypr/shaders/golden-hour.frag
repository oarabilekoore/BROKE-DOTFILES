#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 pix = texture(tex, v_texcoord);
    
    // Warm multiplier
    vec3 warm = vec3(1.1, 0.95, 0.8);
    vec3 color = pix.rgb * warm;
    
    // Boost contrast slightly
    color = mix(vec3(0.5), color, 1.15);
    
    fragColor = vec4(color, 1.0);
}
