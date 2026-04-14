#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    float numColors = 6.0; // Number of color steps
    vec3 c = texture(tex, v_texcoord).rgb;
    
    c = c * numColors;
    c = floor(c);
    c = c / numColors;
    
    fragColor = vec4(c, 1.0);
}
