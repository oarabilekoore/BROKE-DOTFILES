#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    float offset = 0.004; // Adjust this for a stronger/weaker split
    float r = texture(tex, vec2(v_texcoord.x + offset, v_texcoord.y)).r;
    float g = texture(tex, v_texcoord).g;
    float b = texture(tex, vec2(v_texcoord.x - offset, v_texcoord.y)).b;
    
    fragColor = vec4(r, g, b, 1.0);
}
