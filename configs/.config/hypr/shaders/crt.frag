#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 pix = texture(tex, v_texcoord);
    
    // Multiply the y-coordinate by a high frequency to create horizontal bands
    // Adjust the 800.0 higher or lower depending on your screen resolution
    float scanline = sin(v_texcoord.y * 1200.0) * 0.05;
    
    // Darken the pixels where the "scanline" hits
    pix.rgb -= scanline;
    
    fragColor = pix;
}
