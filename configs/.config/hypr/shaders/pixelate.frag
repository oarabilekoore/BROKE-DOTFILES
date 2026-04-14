#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    float pixels = 150.0; // Lower number = chunkier pixels
    float dx = 16.0 * (1.0 / pixels); // Assumes 16:9 aspect ratio roughly
    float dy = 9.0 * (1.0 / pixels);
    
    vec2 coord = vec2(dx * floor(v_texcoord.x / dx), dy * floor(v_texcoord.y / dy));
    fragColor = texture(tex, coord);
}
