#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec2 uv = v_texcoord - 0.5;
    float z = sqrt(1.0 - uv.x * uv.x - uv.y * uv.y);
    float a = 1.0 / (z * tan(1.2)); // Adjust 1.2 for more or less distortion
    
    vec2 coord = (uv * a) + 0.5;
    
    // Black out pixels that fall off the distorted edge
    if(coord.x < 0.0 || coord.x > 1.0 || coord.y < 0.0 || coord.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        fragColor = texture(tex, coord);
    }
}
