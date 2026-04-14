#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 pix = texture(tex, v_texcoord);
    
    // Calculate standard grayscale luminance first
    float luminance = dot(pix.rgb, vec3(0.299, 0.587, 0.114));
    
    // Map the luminance heavily into the Green channel, slightly into Blue, kill Red
    fragColor = vec4(0.0, luminance * 1.5, luminance * 0.2, pix.a);
}
