#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 pix = texture(tex, v_texcoord);
    
    // Sepia tone matrix conversion
    float r = (pix.r * 0.393) + (pix.g * 0.769) + (pix.b * 0.189);
    float g = (pix.r * 0.349) + (pix.g * 0.686) + (pix.b * 0.168);
    float b = (pix.r * 0.272) + (pix.g * 0.534) + (pix.b * 0.131);
    
    fragColor = vec4(r, g, b, pix.a);
}
