#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 pix = texture(tex, v_texcoord);
    
    // Find the distance from the current pixel to the center of the screen (0.5, 0.5)
    vec2 center = v_texcoord - vec2(0.5);
    float dist = length(center);
    
    // Smoothly interpolate the darkness based on distance from the center
    // 0.8 is the outer edge (fully dark), 0.3 is the inner radius (fully bright)
    float vignette = smoothstep(0.8, 0.3, dist); 
    
    // Apply the vignette multiplier
    fragColor = vec4(pix.rgb * vignette, pix.a);
}
