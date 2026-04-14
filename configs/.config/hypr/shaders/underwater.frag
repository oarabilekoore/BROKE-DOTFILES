#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec2 coord = v_texcoord;
    
    // Wavy distortion on the X axis based on the Y position
    coord.x += sin(coord.y * 60.0) * 0.003;
    
    vec4 pix = texture(tex, coord);
    
    // Aqua tint
    fragColor = vec4(pix.r * 0.8, pix.g * 1.1, pix.b * 1.2, 1.0);
}
