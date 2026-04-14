#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 pix = texture(tex, v_texcoord);
    // Subtract current pixel color from 1.0 (pure white) to invert
    fragColor = vec4(vec3(1.0) - pix.rgb, pix.a);
}
