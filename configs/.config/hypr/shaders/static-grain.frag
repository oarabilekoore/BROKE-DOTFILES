#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 pix = texture(tex, v_texcoord);
    
    // Generate pseudo-random noise based on coordinates
    float noise = fract(sin(dot(v_texcoord, vec2(12.9898, 78.233))) * 43758.5453);
    
    // Subtract noise to create grain
    vec3 color = pix.rgb - (noise * 0.15);
    
    fragColor = vec4(color, 1.0);
}
